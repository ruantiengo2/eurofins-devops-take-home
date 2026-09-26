#Requires -RunAsAdministrator
#Requires -PSEdition Desktop

$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'Run this script on Windows with IIS installed.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$packagePath = Join-Path $repoRoot 'artifacts/HelloWorldApi.zip'
$deploymentDir = 'C:\inetpub\HelloWorldApi'
$groupName = 'HelloWorldApiUsers'
$userName = 'HelloWorldUser' # Existing local account on the Windows server.

# Check IIS and its PowerShell management tools.
if (-not (Get-Service -Name W3SVC -ErrorAction SilentlyContinue)) {
    throw 'IIS is not installed. Install IIS before running this script.'
}

Import-Module WebAdministration -ErrorAction Stop

# The Hosting Bundle provides the IIS module and the ASP.NET Core runtime.
if (-not (Get-WebGlobalModule -Name AspNetCoreModuleV2)) {
    throw 'ASP.NET Core Module is missing. Install or repair the .NET 10 Hosting Bundle after installing IIS.'
}

$dotnetPath = Join-Path $env:ProgramFiles 'dotnet/dotnet.exe'
if (-not (Test-Path -LiteralPath $dotnetPath -PathType Leaf)) {
    throw '.NET is missing. Install the .NET 10 Hosting Bundle.'
}

$runtimes = & $dotnetPath --list-runtimes
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not ($runtimes -match '^Microsoft.AspNetCore.App 10\.0\.\d+ ') -or
    -not ($runtimes -match '^Microsoft.NETCore.App 10\.0\.\d+ ')) {
    throw 'The .NET 10 runtimes are missing. Install the .NET 10 Hosting Bundle.'
}

# Download the HelloWorldApi artifact from CI and save it at $packagePath.
if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) {
    throw "Application package not found: $packagePath"
}

# Check the account before changing files or permissions.
Import-Module Microsoft.PowerShell.LocalAccounts -ErrorAction Stop
$user = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue
if (-not $user) {
    throw "Local user '$userName' does not exist. Set userName to an existing local account."
}
if (-not $user.Enabled) {
    throw "Local user '$userName' is disabled. Use an enabled account."
}

# Pass the credential in memory to the IIS configuration script.
$password = Read-Host "Password for $env:COMPUTERNAME\$userName" -AsSecureString
$credential = [System.Management.Automation.PSCredential]::new(
    "$env:COMPUTERNAME\$userName", $password
)

Expand-Archive -LiteralPath $packagePath -DestinationPath $deploymentDir -Force

# Reuse the group if it already exists.
$group = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue
if (-not $group) {
    $group = New-LocalGroup -Name $groupName -Description 'Read and execute access to HelloWorldApi'
}

$members = Get-LocalGroupMember -Group $groupName
if ($user.SID.Value -notin $members.SID.Value) {
    Add-LocalGroupMember -Group $groupName -Member $user
}

# RX = read and execute; OI/CI = inherit on files and subdirectories.
$permission = "*$($group.SID.Value):(OI)(CI)(RX)"
icacls.exe $deploymentDir /grant:r $permission /T
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Application files extracted to $deploymentDir"

& (Join-Path $PSScriptRoot 'configure-iis.ps1') -DeploymentDir $deploymentDir -Credential $credential
