# Starts the game for everybody on this laptop's Wi-Fi and prints the address to open.
# Usage: .\scripts\start_wifi.ps1            uses the web build that is already there
#        .\scripts\start_wifi.ps1 -Build     rebuilds the web apps and the server first
param([switch]$Build)
$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..'
Set-Location $root

# The Wi-Fi adapter with a gateway. VPNs and virtual adapters are not what the phones can reach.
$wifi = Get-NetIPConfiguration |
    Where-Object { $_.IPv4Address -and $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' -and $_.NetAdapter.PhysicalMediaType -match 'Native 802.11|Wireless' } |
    Select-Object -First 1
if (-not $wifi) { throw 'No connected Wi-Fi found. Connect to the Wi-Fi first (a phone hotspot works too).' }
$ip = $wifi.IPv4Address.IPAddress | Select-Object -First 1
$url = "http://$ip"

# QR codes in the admin panel use this, also when the panel itself is opened through localhost.
$envFile = Join-Path $root '.env'
$lines = @(Get-Content $envFile | Where-Object { $_ -notmatch '^KOEDER_PUBLIC_URL=' })
$lines += "KOEDER_PUBLIC_URL=$url"
[System.IO.File]::WriteAllLines((Resolve-Path $envFile), $lines, (New-Object System.Text.UTF8Encoding $false))

if ($Build) {
    & (Join-Path $PSScriptRoot 'build_web.ps1')
    Set-Location $root
    docker compose up -d --build
} else {
    docker compose up -d
}
if ($LASTEXITCODE -ne 0) { throw 'docker compose failed. Is Docker Desktop running?' }

Write-Host ''
Write-Host 'Waiting for the server...'
$healthy = $false
foreach ($i in 1..40) {
    try {
        if ((Invoke-WebRequest "$url/actuator/health" -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200) { $healthy = $true; break }
    } catch { }
    Start-Sleep -Seconds 3
}
if (-not $healthy) { throw "The server does not answer on $url. See: docker compose logs backend" }

Write-Host ''
Write-Host '  KOEDER is running on your Wi-Fi' -ForegroundColor Green
Write-Host "  Network:  $($wifi.NetProfile.Name)"
Write-Host "  Game:     $url/" -ForegroundColor Cyan
Write-Host "  Admin:    $url/admin/"
Write-Host ''
Write-Host '  Everybody on this Wi-Fi opens the game address in a browser.'
Write-Host '  If a phone cannot reach it, the network probably isolates its clients (common on guest and'
Write-Host '  university Wi-Fi). Nothing on this laptop can change that: use a phone hotspot instead.'
Write-Host '  There is no HTTPS on this address, so nobody should use a real password here.'
