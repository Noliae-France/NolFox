#!/usr/bin/env bash
# Télécharge les sources Firefox ESR courantes dans build/firefox-source.
# La version est extraite du product-details Mozilla par l'outil Nolc.
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p build
curl -fsSL "https://product-details.mozilla.org/1.0/firefox_versions.json" \
  -o build/firefox_versions.json

# L'outil Nolc est la source de vérité ; sur les plateformes où nolc n'a pas
# encore de binaire publié (macOS, Windows), un repli équivalent prend le relais.
if command -v nolc >/dev/null 2>&1; then
  nolc run outils/version_esr.nol -- build/firefox_versions.json
elif [ ! -f VERSION_ESR ]; then
  python3 -c "import json; v=json.load(open('build/firefox_versions.json'))['FIREFOX_ESR']; open('VERSION_ESR','w').write(v[:-3] if v.endswith('esr') else v)"
fi

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
