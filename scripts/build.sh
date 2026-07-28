#!/usr/bin/env bash
# Build + packaging NolFox. A lancer apres fetch.sh et brand.sh.
set -euo pipefail
cd "$(dirname "$0")/../build/firefox-source"

./mach --no-interactive bootstrap --application-choice browser
./mach build
./mach package

# La distribution (policies.json) doit etre presente a cote du binaire
DIST_BIN="$(echo obj-*/dist)"
mkdir -p "$DIST_BIN/bin/distribution"
cp browser/branding/nolfox/distribution/policies.json "$DIST_BIN/bin/distribution/" || true

echo "Paquets generes :"
ls -lh obj-*/dist/*.tar.* obj-*/dist/*.dmg obj-*/dist/install/**/*.exe 2>/dev/null || true
