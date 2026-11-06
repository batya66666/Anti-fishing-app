#!/bin/sh
# Builds the game and the admin panel for Caddy. Resources are bundled: the demo needs no CDN and sends nothing to third parties.
set -e
cd "$(dirname "$0")/../app"
dart run tool/sync_content.dart
flutter build web --release --no-web-resources-cdn -o build/web
flutter build web --release --no-web-resources-cdn -t lib/main_admin.dart --base-href /admin/ -o build/admin
