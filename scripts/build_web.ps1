# Builds the game and the admin panel for Caddy. Resources are bundled: the demo needs no CDN and sends nothing to third parties.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..\app')
dart run tool/sync_content.dart
flutter build web --release --no-web-resources-cdn -o build/web
flutter build web --release --no-web-resources-cdn -t lib/main_admin.dart --base-href /admin/ -o build/admin
