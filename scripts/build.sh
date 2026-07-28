#!/usr/bin/env bash
# Build + packaging NolFox. À lancer après fetch.sh et brand.sh.
set -euo pipefail
RACINE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RACINE/build/firefox-source"

PY="${PY311:-python3}"

"$PY" ./mach --no-interactive bootstrap --application-choice browser
"$PY" ./mach build

# La distribution (policies + extensions NolFox) doit être en place AVANT
# l'empaquetage, sinon elle n'entre pas dans l'archive livrée.
DIST_BIN="$(echo obj-*/dist)"
mkdir -p "$DIST_BIN/bin/distribution"
cp -R browser/branding/nolfox/distribution/. "$DIST_BIN/bin/distribution/"

"$PY" ./mach package

# Filet de sécurité : le manifeste d'empaquetage de Firefox ne reprend pas
# toujours distribution/. On la réinjecte dans l'archive livrée, pour que le
# proxy, le thème et les policies soient présents dès la première ouverture.
injecter_dans_archive() {
  archive="$1"
  atelier="$(mktemp -d)"
  tar -xJf "$archive" -C "$atelier"
  racine_app="$(find "$atelier" -maxdepth 1 -mindepth 1 -type d | head -1)"
  [ -n "$racine_app" ] || return 0
  if [ ! -d "$racine_app/distribution" ] || [ ! -f "$racine_app/nolfox.cfg" ]; then
    rm -rf "$racine_app/distribution"
    cp -R browser/branding/nolfox/distribution "$racine_app/distribution"
    # Configuration automatique : installe l'habillage dans le profil
    cp "$RACINE/branding/nolfox.cfg" "$racine_app/nolfox.cfg"
    mkdir -p "$racine_app/defaults/pref"
    cp "$RACINE/branding/autoconfig.js" "$racine_app/defaults/pref/autoconfig.js"
    # Les chemins de l'archive restent « nolfox/... » : un préfixe « ./ »
    # empêcherait toute extraction ciblée par la suite.
    (cd "$atelier" && tar -cJf "$archive.nouveau" "$(basename "$racine_app")")
    mv "$archive.nouveau" "$archive"
    echo "distribution et configuration NolFox réinjectées dans $(basename "$archive")"
  fi
  rm -rf "$atelier"
}

for archive in obj-*/dist/*.tar.xz; do
  [ -e "$archive" ] || continue
  injecter_dans_archive "$(cd "$(dirname "$archive")" && pwd)/$(basename "$archive")"
done

# Sur macOS la distribution se loge dans les ressources de l'application
# principale (les applications auxiliaires n'en ont pas l'usage).
for app in obj-*/dist/NolFox.app obj-*/dist/*/NolFox.app; do
  [ -d "$app" ] || continue
  mkdir -p "$app/Contents/Resources/distribution"
  cp -R browser/branding/nolfox/distribution/. "$app/Contents/Resources/distribution/"
  cp "$RACINE/branding/nolfox.cfg" "$app/Contents/Resources/nolfox.cfg"
  mkdir -p "$app/Contents/Resources/defaults/pref"
  cp "$RACINE/branding/autoconfig.js" "$app/Contents/Resources/defaults/pref/autoconfig.js"
  echo "distribution et configuration NolFox installées dans $app"
done

echo "Paquets générés :"
ls -lh obj-*/dist/*.tar.* obj-*/dist/*.dmg obj-*/dist/install/**/*.exe 2>/dev/null || true
