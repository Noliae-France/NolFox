#!/usr/bin/env bash
# Build + packaging NolFox. À lancer après fetch.sh et brand.sh.
set -euo pipefail
cd "$(dirname "$0")/../build/firefox-source"

./mach --no-interactive bootstrap --application-choice browser
./mach build
./mach package

# La distribution (policies.json) doit être presente a côté du binaire
DIST_BIN="$(echo obj-*/dist)"
mkdir -p "$DIST_BIN/bin/distribution"
cp -R browser/branding/nolfox/distribution/. "$DIST_BIN/bin/distribution/" || true

echo "Paquets générés :"
ls -lh obj-*/dist/*.tar.* obj-*/dist/*.dmg obj-*/dist/install/**/*.exe 2>/dev/null || true
