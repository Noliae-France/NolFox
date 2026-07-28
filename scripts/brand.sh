#!/usr/bin/env bash
# Applique l'identité NolFox sur l'arbre de sources : branding dérivé
# de browser/branding/unofficial + injection des prefs NolFox + policies.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=build/firefox-source

[ -d "$SRC/browser" ] || { echo "Sources absentes : lancer scripts/fetch.sh" >&2; exit 1; }

# Valide les prefs avant toute injection. L'outil Nolc est la reference ;
# la CI Linux l'execute systematiquement, donc sur une plateforme sans
# binaire nolc publie on n'echoue pas pour autant.
if command -v nolc >/dev/null 2>&1; then
  nolc run outils/verifie_prefs.nol -- prefs/nolfox.js
else
  echo "nolc absent : validation des prefs deja assuree par la CI Linux"
fi

# Branding : copie de la base unofficial, renommée NolFox
rm -rf "$SRC/browser/branding/nolfox"
cp -R "$SRC/browser/branding/unofficial" "$SRC/browser/branding/nolfox"
sed -i.bak 's/Mozilla Developer Preview/NolFox/g; s/mozilla-developer-preview/nolfox/g' \
  "$SRC/browser/branding/nolfox/configure.sh" 2>/dev/null || true
sed -i.bak 's/^MOZ_APP_DISPLAYNAME=.*/MOZ_APP_DISPLAYNAME=NolFox/' \
  "$SRC/browser/branding/nolfox/configure.sh"
find "$SRC/browser/branding/nolfox" -name '*.bak' -delete

# Icônes NolFox : PNG Linux, ICO Windows, ICNS macOS + logos about:
B="$SRC/browser/branding/nolfox"
for f in branding/default*.png; do cp "$f" "$B/$(basename "$f")"; done
cp branding/firefox.ico branding/document.ico "$B/"
cp branding/firefox.icns branding/document.icns "$B/"
mkdir -p "$B/content"
cp branding/about-logo.png "$B/content/about-logo.png"
cp branding/about-logo@2x.png "$B/content/about-logo@2x.png"
cp branding/nolfox.svg "$B/content/about-logo.svg" 2>/dev/null || true

# Prefs NolFox ajoutées aux défauts du branding
cat prefs/nolfox.js >> "$SRC/browser/branding/nolfox/pref/firefox-branding.js"

# mozconfig + policies d'entreprise embarquées
cp mozconfig "$SRC/mozconfig"
mkdir -p "$SRC/browser/branding/nolfox/distribution"
cp distribution/policies.json "$SRC/browser/branding/nolfox/distribution/policies.json"

# Extensions maison (proxy Noliae + thème Pulse) empaquetées en XPI,
# auto-installées au premier lancement via distribution/extensions
DIST_EXT="$SRC/browser/branding/nolfox/distribution/extensions"
mkdir -p "$DIST_EXT"
# L'archive est construite par python plutôt que par « zip », absent des
# runners Windows ; les entrées sont triées pour un XPI reproductible.
for ext in extensions/*/; do
  python3 - "$ext" "$DIST_EXT" <<'PY'
import json, pathlib, sys, zipfile

source = pathlib.Path(sys.argv[1])
destination = pathlib.Path(sys.argv[2])
identifiant = json.loads((source / "manifest.json").read_text())[
    "browser_specific_settings"]["gecko"]["id"]

xpi = destination / f"{identifiant}.xpi"
fichiers = sorted(p for p in source.rglob("*") if p.is_file())
with zipfile.ZipFile(xpi, "w", zipfile.ZIP_DEFLATED) as archive:
    for fichier in fichiers:
        archive.write(fichier, fichier.relative_to(source).as_posix())
print(f"Extension empaquetée : {identifiant}")
PY
done

echo "Branding NolFox appliqué"
