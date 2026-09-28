#Requires -RunAsAdministrator
#Requires -PSEdition Desktop
param(
    [string]$PublishDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'artifacts/HelloWorldMonitor/win-x64'),
    [string]$DeploymentDir = (Join-Path $env:ProgramFiles 'HelloWorldMonitor'),
    [Parameter(Mandatory = $true)]
    [uri]$MonitorUrl
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

New-Item -Path $DeploymentDir -ItemType Directory -Force | Out-Null
Get-ChildItem -LiteralPath $PublishDir -Force | Copy-Item -Destination $DeploymentDir -Recurse
$executable = Join-Path $DeploymentDir 'HelloWorldMonitor.exe'
if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw "Deployed executable not found: $executable" }
# Quote both paths and URLs; the service runs the Windows apphost, not dotnet.exe.
$binaryPath = '"{0}" --Monitor:Url "{1}"' -f $executable, $MonitorUrl.AbsoluteUri

# This initial deployment uses the Windows default LocalSystem account.
# A specified account and recovery policy are separate Step 4 tasks.
New-Service -Name $serviceName -DisplayName $serviceName -BinaryPathName $binaryPath -StartupType Automatic -Description 'Checks the HelloWorld website every 60 seconds.' | Out-Null
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
