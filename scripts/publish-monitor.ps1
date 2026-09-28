param(
    [string]$OutputDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'artifacts/HelloWorldMonitor/win-x64')
)

$ErrorActionPreference = 'Stop'
$project = Join-Path (Split-Path -Parent $PSScriptRoot) 'src/HelloWorldMonitor/HelloWorldMonitor.csproj'
$OutputDir = [IO.Path]::GetFullPath($OutputDir)

Get-Command dotnet -ErrorAction Stop | Out-Null
& dotnet publish $project --configuration Release --runtime win-x64 --self-contained false -p:UseAppHost=true --output $OutputDir
if ($LASTEXITCODE -ne 0) { throw "Monitor publish failed: $LASTEXITCODE" }

$executable = Join-Path $OutputDir 'HelloWorldMonitor.exe'
if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw "Published Windows executable not found: $executable"
}
Write-Host "Published Windows x64 monitor: $executable"
Write-Host 'The target machine needs the .NET 10 x64 runtime. Deploy the entire output directory.'
