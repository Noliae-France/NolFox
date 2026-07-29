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

# Sur Windows, la distribution accompagne le binaire dans l'archive livrée.
for archive in obj-*/dist/*.zip; do
  [ -e "$archive" ] || continue
  chemin="$(cd "$(dirname "$archive")" && pwd)/$(basename "$archive")"
  python3 - "$chemin" "$RACINE" <<'PY'
import pathlib, sys, zipfile

archive = pathlib.Path(sys.argv[1])
racine = pathlib.Path(sys.argv[2])
source = racine / "build/firefox-source/browser/branding/nolfox/distribution"

with zipfile.ZipFile(archive) as z:
    entrees = z.namelist()
if any("/distribution/" in e for e in entrees):
    print(f"distribution déjà présente dans {archive.name}")
    raise SystemExit

# Le dossier racine de l'archive (« nolfox/ ») accueille la distribution.
prefixe = entrees[0].split("/")[0] if entrees else "nolfox"
ajouts = [(p, f"{prefixe}/distribution/{p.relative_to(source).as_posix()}")
          for p in sorted(source.rglob("*")) if p.is_file()]
ajouts.append((racine / "branding/nolfox.cfg", f"{prefixe}/nolfox.cfg"))
ajouts.append((racine / "branding/autoconfig.js",
               f"{prefixe}/defaults/pref/autoconfig.js"))

with zipfile.ZipFile(archive, "a", zipfile.ZIP_DEFLATED) as z:
    for fichier, destination in ajouts:
        z.write(fichier, destination)
print(f"distribution NolFox ajoutée à {archive.name}")
PY
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
ls -ld obj-*/dist/NolFox.app 2>/dev/null || true
ls -lh obj-*/dist/*.zip obj-*/dist/install/sea/*.exe 2>/dev/null || true
