#!/usr/bin/env pwsh
#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'Run this script on Windows with IIS installed.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$packagePath = Join-Path $repoRoot 'artifacts/HelloWorldApi.zip'
$deploymentDir = 'C:\inetpub\HelloWorldApi'

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

Expand-Archive -LiteralPath $packagePath -DestinationPath $deploymentDir -Force

Write-Host "Application files extracted to $deploymentDir"
