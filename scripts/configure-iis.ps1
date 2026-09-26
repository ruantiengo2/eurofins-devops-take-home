#Requires -RunAsAdministrator
#Requires -PSEdition Desktop

param(
    [Parameter(Mandatory = $true)]
    [string]$DeploymentDir,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'Run this script on Windows with IIS installed.'
}

Import-Module WebAdministration -ErrorAction Stop

$siteName = 'HelloWorldApi'
$appPoolName = 'HelloWorldApiPool'
$httpPort = 8080
$httpsPort = 8443
$certificateName = 'HelloWorldApi localhost development'

if (-not (Test-Path -LiteralPath $DeploymentDir -PathType Container)) {
    throw "Deployment directory not found: $DeploymentDir"
}

# Create or update the pool using the account supplied by the deployment script.
$appPoolPath = "IIS:\AppPools\$appPoolName"
if (-not (Test-Path $appPoolPath)) {
    New-WebAppPool -Name $appPoolName | Out-Null
}

# ASP.NET Core uses its own runtime (No Managed Code in IIS Manager).
Set-ItemProperty -Path $appPoolPath -Name managedRuntimeVersion -Value ''

# Identity type 3 means SpecificUser. IIS needs the password to configure it.
Set-ItemProperty -Path $appPoolPath -Name processModel -Value @{
    identityType = 3
    userName = $Credential.UserName
    password = $Credential.GetNetworkCredential().Password
}

# Reuse the existing site when running the script again.
if (-not (Test-Path "IIS:\Sites\$siteName")) {
    New-Website -Name $siteName -Port $httpPort -PhysicalPath $DeploymentDir
} else {
    Write-Host "Website '$siteName' already exists. Keeping its current configuration."
}

# Use localhost and SNI so this certificate binding belongs to this hostname.
$binding = Get-WebBinding -Name $siteName -Protocol https -Port $httpsPort -HostHeader 'localhost'
if (-not $binding) {
    New-WebBinding -Name $siteName -Protocol https -Port $httpsPort -IPAddress '*' -HostHeader 'localhost' -SslFlags 1
    $binding = Get-WebBinding -Name $siteName -Protocol https -Port $httpsPort -HostHeader 'localhost'
}

# Preserve a certificate already assigned to this binding.
if (-not $binding.certificateHash) {
    $certificate = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object {
        $_.FriendlyName -eq $certificateName -and
        $_.HasPrivateKey -and
        $_.NotBefore -le (Get-Date) -and
        $_.NotAfter -gt (Get-Date) -and
        $_.DnsNameList.Unicode -contains 'localhost'
    } | Sort-Object NotAfter -Descending | Select-Object -First 1

    if (-not $certificate) {
        $certificate = New-SelfSignedCertificate -DnsName 'localhost' -CertStoreLocation 'Cert:\LocalMachine\My' -FriendlyName $certificateName -NotAfter (Get-Date).AddYears(1)
    }

    $binding.AddSslCertificate($certificate.Thumbprint, 'My')
}

Write-Host "IIS site configured: https://localhost:$httpsPort"
Write-Host 'The generated certificate is for local testing and is not automatically trusted by browsers.'
