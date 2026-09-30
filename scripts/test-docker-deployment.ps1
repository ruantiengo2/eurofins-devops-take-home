#requires -Version 7.0
param([Parameter(Mandatory)][string]$Image)
$ErrorActionPreference = 'Stop'
$webName = 'validation-web-' + [guid]::NewGuid().ToString('N')
$exampleName = 'validation-example-' + [guid]::NewGuid().ToString('N')
try {
    & "$PSScriptRoot/deploy-docker.ps1" -Image $Image -ContainerName $webName -HostPort 18080
    foreach ($endpoint in @(@('/', 'Hello World!'), @('/health', 'Healthy'))) {
        $response = $null
        for ($attempt = 0; $attempt -lt 30; $attempt++) {
            try {
                $response = Invoke-WebRequest "http://localhost:18080$($endpoint[0])" -TimeoutSec 2
                break
            } catch { Start-Sleep -Seconds 1 }
        }
        if (-not $response -or $response.StatusCode -ne 200 -or $response.Content.Trim() -ne $endpoint[1]) {
            throw "Endpoint validation failed: $($endpoint[0])"
        }
        Write-Host "PASS deployed $($endpoint[0]): HTTP 200; $($endpoint[1])"
    }
    $before = docker inspect --format '{{.Id}}' $webName
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect deployed container' }
    $rejected = $false
    try { & "$PSScriptRoot/deploy-docker.ps1" -Image $Image -ContainerName $webName -HostPort 18080 }
    catch { if ($_.Exception.Message -notmatch 'already exists') { throw }; $rejected = $true }
    $after = docker inspect --format '{{.Id}}' $webName
    if ($LASTEXITCODE -ne 0 -or -not $rejected -or $before -ne $after) { throw 'Existing-container protection failed' }
    Write-Host 'PASS repeat deployment rejected without replacing container'
    & "$PSScriptRoot/deploy-docker.ps1" -UseHelloWorld -ContainerName $exampleName
    Write-Host 'PASS official hello-world: expected greeting and exit code 0'
    docker image inspect --format '{{json .RepoDigests}}' $Image
    if ($LASTEXITCODE -ne 0) { throw 'Cannot record image digest' }
} finally {
    foreach ($name in @($webName, $exampleName)) {
        docker logs $name
        docker rm --force $name
    }
}
