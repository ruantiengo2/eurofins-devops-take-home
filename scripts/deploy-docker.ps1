#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidatePattern('^[^\s-][^\s]*$')]
    [string]$Image = 'ghcr.io/ruantiengo/eurofins-devops-takehome:latest',
    [ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9_.-]*$')]
    [string]$ContainerName = 'helloworld-api',
    [ValidateRange(1, 65535)]
    [int]$HostPort = 18080,
    [switch]$UseHelloWorld
)

$ErrorActionPreference = 'Stop'
# Check native exit codes explicitly on both Windows PowerShell and PowerShell 7.
$PSNativeCommandUseErrorActionPreference = $false

function Invoke-Docker {
    param([string[]]$DockerArguments)
    $result = & docker @DockerArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Docker '$($DockerArguments[0])' failed (exit $LASTEXITCODE). Check the engine, permissions, image reference and registry login."
    }
    return $result
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker CLI was not found. Install Docker and start a Linux container engine before deployment.'
}
if ($UseHelloWorld) {
    if ($PSBoundParameters.ContainsKey('Image')) {
        throw 'Use either -Image or -UseHelloWorld, not both.'
    }
    $Image = 'hello-world:latest'
    if (-not $PSBoundParameters.ContainsKey('ContainerName')) { $ContainerName = 'helloworld-example' }
}
$exampleImage = $Image -match '^(docker\.io/)?(library/)?hello-world(?::[^/]+|@sha256:[a-fA-F0-9]{64})?$'

$engineOS = (Invoke-Docker -DockerArguments @('info', '--format', '{{.OSType}}') | Out-String).Trim()
if ($engineOS -ne 'linux') { throw 'This deployment requires a Linux container engine (also on Windows).' }
$names = @(Invoke-Docker -DockerArguments @('container', 'ls', '--all', '--format', '{{.Names}}'))
if ($names -contains $ContainerName) {
    throw "Container '$ContainerName' already exists. Inspect and remove it explicitly or choose another -ContainerName."
}

Invoke-Docker -DockerArguments @('pull', $Image) | Out-Host
$runArguments = @('run', '--detach', '--name', $ContainerName)
if (-not $exampleImage) { $runArguments += @('--publish', "${HostPort}:8080") }
$runArguments += $Image
$containerId = (Invoke-Docker -DockerArguments $runArguments | Out-String).Trim()
Write-Host "Created container $containerId from $Image."
# Keep the container, including failures, for inspection. Never remove an existing container.
if ($exampleImage) {
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    do {
        $state = (Invoke-Docker -DockerArguments @('inspect', '--format', '{{json .State}}', $containerId) | Out-String) | ConvertFrom-Json
        if (-not $state.Running) { break }
        Start-Sleep -Seconds 1
    } while ([DateTime]::UtcNow -lt $deadline)
    if ($state.Running) { throw "Example container did not finish within 30 seconds. Inspect docker logs $ContainerName." }
    $logs = Invoke-Docker -DockerArguments @('logs', $containerId) | Out-String
    Write-Host $logs
    if ($state.ExitCode -ne 0 -or $logs -notmatch 'Hello from Docker!') {
        throw "Example failed: exit code $($state.ExitCode) or expected greeting missing."
    }
    Write-Host 'Docker hello-world completed successfully; it has no HTTP endpoints.'
} else {
    Start-Sleep -Seconds 2
    $running = (Invoke-Docker -DockerArguments @('inspect', '--format', '{{.State.Running}}', $containerId) | Out-String).Trim()
    if ($running -ne 'true') { throw "Container stopped after startup. Inspect docker logs $ContainerName." }
    Write-Host "Container is running. On the Docker host, verify http://localhost:$HostPort/ and http://localhost:$HostPort/health."
    Write-Host 'Port is published on all host interfaces; access depends on host networking/firewall. Running state alone does not confirm HTTP readiness.'
}

