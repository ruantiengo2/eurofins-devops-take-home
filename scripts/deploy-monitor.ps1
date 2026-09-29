#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
param(
    [string]$PublishDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'artifacts/HelloWorldMonitor/win-x64'),
    [string]$DeploymentDir = (Join-Path $env:ProgramFiles 'HelloWorldMonitor'),
    [Parameter(Mandatory = $true)]
    [uri]$MonitorUrl,
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'
$serviceName = 'HelloWorldMonitor'

if (-not [Environment]::Is64BitProcess) { throw 'Run this script in 64-bit Windows PowerShell.' }
if (-not $MonitorUrl.IsAbsoluteUri -or $MonitorUrl.Scheme -notin @('http', 'https')) {
    throw 'MonitorUrl must be an absolute HTTP or HTTPS URL.'
}
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    throw "Service '$serviceName' already exists. No files or service settings were changed."
}
$PublishDir = (Resolve-Path -LiteralPath $PublishDir).Path
$DeploymentDir = [IO.Path]::GetFullPath($DeploymentDir)
foreach ($file in @('HelloWorldMonitor.exe', 'HelloWorldMonitor.dll', 'HelloWorldMonitor.deps.json', 'HelloWorldMonitor.runtimeconfig.json', 'appsettings.json')) {
    if (-not (Test-Path -LiteralPath (Join-Path $PublishDir $file) -PathType Leaf)) {
        throw "Published file missing: $file. Run publish-monitor.ps1 first."
    }
}
$exeBytes = [IO.File]::ReadAllBytes((Join-Path $PublishDir 'HelloWorldMonitor.exe'))
if ($exeBytes.Length -lt 2 -or $exeBytes[0] -ne 0x4D -or $exeBytes[1] -ne 0x5A) {
    throw 'HelloWorldMonitor.exe is not a Windows executable. Publish for win-x64.'
}
$dotnet = Join-Path $env:ProgramFiles 'dotnet/dotnet.exe'
if (-not (Test-Path -LiteralPath $dotnet -PathType Leaf)) { throw 'Install the .NET 10 x64 runtime first.' }
$runtimes = & $dotnet --list-runtimes
if ($LASTEXITCODE -ne 0 -or -not ($runtimes -match '^Microsoft.NETCore.App 10\.0\.\d+ ')) {
    throw 'The .NET 10 x64 runtime is required.'
}
if ((Test-Path -LiteralPath $DeploymentDir) -and @(Get-ChildItem -LiteralPath $DeploymentDir -Force).Count) {
    throw 'DeploymentDir must be empty for this initial installation. Existing files were not changed.'
}

# Resolve the account before changing files or policy; use its SID for ACLs.
$accountName = $Credential.UserName
if ($accountName.StartsWith('.\')) { $accountName = "$env:COMPUTERNAME\$($accountName.Substring(2))" }
elseif ($accountName -notmatch '[\\@]') { $accountName = "$env:COMPUTERNAME\$accountName" }
$account = New-Object System.Security.Principal.NTAccount($accountName)
$sid = $account.Translate([System.Security.Principal.SecurityIdentifier])
$accountName = $sid.Translate([System.Security.Principal.NTAccount]).Value
$serviceCredential = [System.Management.Automation.PSCredential]::new($accountName, $Credential.Password)
if (-not ('ServiceLogonRight' -as [type])) { Add-Type -Path (Join-Path $PSScriptRoot 'ServiceLogonRight.cs') }
[ServiceLogonRight]::Grant($sid.Value)

New-Item -Path $DeploymentDir -ItemType Directory -Force | Out-Null
Get-ChildItem -LiteralPath $PublishDir -Force | Copy-Item -Destination $DeploymentDir -Recurse

# Protect application binaries from modification by the service account.
# This is a new, empty deployment directory, not an existing shared directory.
$acl = New-Object System.Security.AccessControl.DirectorySecurity
$acl.SetAccessRuleProtection($true, $false)
$inheritance = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
foreach ($adminSid in @('S-1-5-18', 'S-1-5-32-544')) {
    $identity = New-Object System.Security.Principal.SecurityIdentifier($adminSid)
    $acl.AddAccessRule([System.Security.AccessControl.FileSystemAccessRule]::new($identity, 'FullControl', $inheritance, 'None', 'Allow'))
}
$acl.AddAccessRule([System.Security.AccessControl.FileSystemAccessRule]::new($sid, 'ReadAndExecute', $inheritance, 'None', 'Allow'))
Set-Acl -LiteralPath $DeploymentDir -AclObject $acl
# Pre-create the log: only this file needs write access, not the executable folder.
$logPath = Join-Path $DeploymentDir 'status.log'
if (-not (Test-Path -LiteralPath $logPath)) { New-Item -Path $logPath -ItemType File | Out-Null }
$logAcl = Get-Acl -LiteralPath $logPath
$logAcl.AddAccessRule([System.Security.AccessControl.FileSystemAccessRule]::new($sid, 'Modify', 'Allow'))
Set-Acl -LiteralPath $logPath -AclObject $logAcl
# Register the logger source while elevated, before the unprivileged service uses it.
if (-not [Diagnostics.EventLog]::SourceExists('HelloWorldMonitor')) {
    New-EventLog -LogName Application -Source 'HelloWorldMonitor'
}
$executable = Join-Path $DeploymentDir 'HelloWorldMonitor.exe'
if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw "Deployed executable not found: $executable" }
# Quote both paths and URLs; the service runs the Windows apphost, not dotnet.exe.
$binaryPath = '"{0}" --Monitor:Url "{1}"' -f $executable, $MonitorUrl.AbsoluteUri

# The password remains in PSCredential; Windows stores the service credential.
New-Service -Name $serviceName -DisplayName $serviceName -BinaryPathName $binaryPath -StartupType Automatic -Credential $serviceCredential -Description 'Checks the HelloWorld website every 60 seconds.' | Out-Null
# SC uses milliseconds. The last action repeats for subsequent failures.
$sc = Join-Path $env:SystemRoot 'System32/sc.exe'
& $sc failure $serviceName reset= 86400 actions= restart/300000/restart/300000/restart/300000
if ($LASTEXITCODE -ne 0) { throw "Configuring service recovery failed: $LASTEXITCODE" }
& $sc failureflag $serviceName 1
if ($LASTEXITCODE -ne 0) { throw "Enabling recovery for non-crash failures failed: $LASTEXITCODE" }
try {
    Start-Service -Name $serviceName
    (Get-Service -Name $serviceName).WaitForStatus('Running', [TimeSpan]::FromSeconds(30))
    Start-Sleep -Seconds 2
    if ((Get-Service -Name $serviceName).Status -ne 'Running') { throw 'The monitor stopped after startup.' }
} catch {
    throw "Service installed but startup failed: $($_.Exception.Message) Check '$DeploymentDir\status.log', the target URL and certificate trust."
}
Write-Host "Service '$serviceName' is running with Automatic startup."
Write-Host "Executable: $executable"
Write-Host "Log: $(Join-Path $DeploymentDir 'status.log')"
