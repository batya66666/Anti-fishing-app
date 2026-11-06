# Builds the game and the admin panel for Caddy. Resources are bundled: the demo needs no CDN and sends nothing to third parties.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..\app')
# PowerShell does not stop by itself when a native program fails: an old build would go on stage unnoticed.
function Invoke-Step([scriptblock]$Step) {
    & $Step
    if ($LASTEXITCODE -ne 0) { throw "Build failed: $Step" }
}
Invoke-Step { dart run tool/sync_content.dart }
Invoke-Step { flutter build web --release --no-web-resources-cdn -o build/web }
Invoke-Step { flutter build web --release --no-web-resources-cdn -t lib/main_admin.dart --base-href /admin/ -o build/admin }
