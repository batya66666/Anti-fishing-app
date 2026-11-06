#!/bin/sh
# Regenerates the Dart API client from the OpenAPI contract of the running backend.
# Usage: start the backend, then run scripts/gen_api.sh [http://localhost:8080]
set -e
cd "$(dirname "$0")/.."
BASE="${1:-http://localhost}"
curl -fsS "$BASE/v3/api-docs" -o docs/openapi.json
mkdir -p app/packages/koeder_api && find app/packages/koeder_api -mindepth 1 -delete
npx --yes @openapitools/openapi-generator-cli@2.25.0 generate -c docs/openapi-generator.yaml
cd app/packages/koeder_api
rm -rf test doc
# copy_with_extension_gen produces code the formatter of this SDK rejects. The app does not use copyWith, so it goes.
find lib/src/model -name '*.dart' -exec sed -i -e '/copy_with_extension/d' -e '/@CopyWith()/d' {} +
sed -i -e '/copy_with_extension/d' pubspec.yaml
# json_serializable emits null-aware map elements, which need the language version the app already uses.
sed -i -e "s/sdk: '>=3.5.0 <4.0.0'/sdk: ^3.8.1/" pubspec.yaml
dart pub get
dart run build_runner build --delete-conflicting-outputs
