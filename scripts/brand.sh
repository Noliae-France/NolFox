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

# Prefs NolFox. Elles sont ajoutées à la FIN de browser/app/profile/firefox.js
# et non au seul branding : les fichiers de defaults/preferences se chargent
# par ordre alphabétique, si bien que firefox.js écrasait nos valeurs (les
# extensions et la langue française se retrouvaient désactivées au démarrage).
{
  printf '\n// --- Préférences NolFox (chargées en dernier) ---\n'
  cat prefs/nolfox.js
} >> "$SRC/browser/app/profile/firefox.js"
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

# Pack de langue francaise officiel de la meme version ESR : NolFox
# s'ouvre en francais sans manipulation. La signature Mozilla n'est pas
# valable pour un build maison, d'ou xpinstall.signatures.required a faux.
VERSION_ESR_COURANTE="$(cat build/VERSION_ESR)"
LANGPACK="$DIST_EXT/langpack-fr@firefox.mozilla.org.xpi"
for plateforme in linux-x86_64 mac win64; do
  if curl -fsSL --retry 2 -o "$LANGPACK" \
    "https://archive.mozilla.org/pub/firefox/releases/${VERSION_ESR_COURANTE}esr/${plateforme}/xpi/fr.xpi"; then
    echo "Pack de langue francaise embarque (${plateforme})"
    break
  fi
done
[ -s "$LANGPACK" ] || { echo "pack de langue francaise introuvable" >&2; exit 1; }

# Habillage NolFox : copie dans chaque nouveau profil au premier lancement
mkdir -p "$SRC/browser/branding/nolfox/distribution/profile/chrome"
cp branding/userChrome.css "$SRC/browser/branding/nolfox/distribution/profile/chrome/userChrome.css"

echo "Branding NolFox appliqué"
