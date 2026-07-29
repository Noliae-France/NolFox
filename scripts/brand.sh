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

# Chaines de marque : la base "unofficial" dit "Firefox" dans brand.ftl /
# brand.properties -> tout passer en NolFox, sinon l'UI affiche encore
# "Firefox n'est pas votre navigateur par defaut", etc.
rebrand_marque() {
  local cible="$1"
  find "$cible" \( -name 'brand.ftl' -o -name 'brand.properties' \) -print0 \
    | while IFS= read -r -d '' f; do
    sed -i.bak -E \
      -e 's/(-brand-shorter-name[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(-brand-shortcut-name[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(-vendor-short-name[[:space:]]*=[[:space:]]*).*/\1Noliae/' \
      -e 's/(vendorShortName[[:space:]]*=[[:space:]]*).*/\1Noliae/' \
      -e 's/(-brand-short-name[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(-brand-full-name[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(-brand-product-name[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(brandShorterName[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(brandShortName[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      -e 's/(brandFullName[[:space:]]*=[[:space:]]*).*/\1NolFox/' \
      "$f"
    rm -f "$f.bak"
  done

  # Certaines traductions ecrivent « Firefox » en dur au lieu d'utiliser la
  # variable de marque : sans cela l'interface francaise le laisse paraitre
  # (« Firefox n'est pas votre navigateur par defaut »). Seule la forme
  # capitalisee est remplacee, ce qui preserve les URL et les identifiants
  # techniques, tous en minuscules.
  find "$cible" \( -name '*.ftl' -o -name '*.properties' -o -name '*.dtd' \) -print0 \
    | while IFS= read -r -d '' f; do
    sed -i.bak -E \
      -e 's/Mozilla Firefox/NolFox/g' \
      -e 's/Firefox/NolFox/g' \
      "$f"
    rm -f "$f.bak"
  done
}
rebrand_marque "$SRC/browser/branding/nolfox"

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
# Sur Mac, NolFox ne vise que les puces Apple Silicon.
if [ "$(uname -s)" = "Darwin" ]; then
  echo 'ac_add_options --target=aarch64-apple-darwin' >> "$SRC/mozconfig"
fi
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
case "$(uname -s)" in
  Darwin) plateformes="mac" ;;
  *) plateformes="win64 linux-x86_64" ;;
esac
for plateforme in $plateformes; do
  if curl -fsSL --retry 2 -o "$LANGPACK" \
    "https://archive.mozilla.org/pub/firefox/releases/${VERSION_ESR_COURANTE}esr/${plateforme}/xpi/fr.xpi"; then
    echo "Pack de langue francaise embarque (${plateforme})"
    break
  fi
done
[ -s "$LANGPACK" ] || { echo "pack de langue francaise introuvable" >&2; exit 1; }
# Chemin absolu : le repack s'effectue depuis un autre repertoire.
LANGPACK="$(cd "$(dirname "$LANGPACK")" && pwd)/$(basename "$LANGPACK")"

# Le langpack fr de Mozilla embarque ses propres brand.ftl/brand.properties
# disant "Firefox" : les reecrire en NolFox pour que l'UI francaise n'affiche
# jamais "Firefox". Extraction/repack en python (zip absent des runners Windows).
TMPFR="$(mktemp -d)"
python3 - "$LANGPACK" "$TMPFR" <<'PY'
import sys, zipfile, pathlib
zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])
PY
rebrand_marque "$TMPFR"

# La version est incrementee : sans cela, un profil qui possede deja le pack
# de langue officiel de meme version le garde, et l'interface continue
# d'afficher Firefox malgre le rebranding.
python3 - "$TMPFR" <<'PY'
import json, pathlib, sys

manifeste = pathlib.Path(sys.argv[1]) / "manifest.json"
donnees = json.loads(manifeste.read_text())
morceaux = donnees["version"].split(".")
morceaux[-1] = str(int(morceaux[-1]) + 1)
donnees["version"] = ".".join(morceaux)
donnees["name"] = "Langue : Francais (NolFox)"
manifeste.write_text(json.dumps(donnees, ensure_ascii=False, indent=2))
print(f"version du pack de langue portee a {donnees['version']}")
PY
( cd "$TMPFR" && python3 - "$LANGPACK" <<'PY'
import sys, zipfile, pathlib
xpi = pathlib.Path(sys.argv[1])
root = pathlib.Path('.')
fichiers = sorted(p for p in root.rglob('*') if p.is_file())
with zipfile.ZipFile(xpi, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in fichiers:
        z.write(f, f.relative_to(root).as_posix())
PY
)
rm -rf "$TMPFR"
echo "Langpack fr rebrande NolFox"

# Habillage NolFox : copie dans chaque nouveau profil au premier lancement
mkdir -p "$SRC/browser/branding/nolfox/distribution/profile/chrome"
cp branding/userChrome.css "$SRC/browser/branding/nolfox/distribution/profile/chrome/userChrome.css"

echo "Branding NolFox appliqué"
