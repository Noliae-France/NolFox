#!/usr/bin/env bash
# Télécharge les sources Firefox ESR courantes dans build/firefox-source.
# La version est extraite du product-details Mozilla par l'outil Nolc.
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p build
curl -fsSL "https://product-details.mozilla.org/1.0/firefox_versions.json" \
  -o build/firefox_versions.json

nolc run outils/version_esr.nol -- build/firefox_versions.json
VERSION="$(cat VERSION_ESR)"
mv VERSION_ESR build/VERSION_ESR
echo "Firefox ESR upstream : ${VERSION}esr"

TARBALL="firefox-${VERSION}esr.source.tar.xz"
URL="https://archive.mozilla.org/pub/firefox/releases/${VERSION}esr/source/${TARBALL}"

if [ ! -f "build/${TARBALL}" ]; then
  echo "Téléchargement ${URL}"
  curl -fL --retry 3 -o "build/${TARBALL}" "${URL}"
fi

rm -rf build/firefox-source
mkdir -p build/firefox-source
tar -xJf "build/${TARBALL}" -C build/firefox-source --strip-components=1
echo "Sources prêtes dans build/firefox-source"
