#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$project = Join-Path $repoRoot 'src/HelloWorldApi/HelloWorldApi.csproj'
$publishDir = Join-Path $repoRoot 'artifacts/HelloWorldApi'

dotnet restore $project
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

dotnet publish $project --configuration Release --output $publishDir --no-restore
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
