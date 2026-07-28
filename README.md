# NolFox

Navigateur web edite par **Noliae**, base sur **Firefox ESR** (canal long
support de Mozilla). Le depot ne contient pas les sources Mozilla : il porte
l'identite NolFox, les reglages et l'outillage, et la chaine de build
telecharge les sources ESR officielles puis applique le tout.

## Principes

- **Base Firefox ESR** : stabilite et correctifs de securite du canal LTS.
- **Streaming sans friction** : DRM Widevine active des l'installation.
  Netflix, Prime Video, Spotify, YouTube fonctionnent sans reglage.
- **Telemetrie Mozilla coupee** : aucun envoi de donnees, pas d'etudes
  Shield/Normandy, pas de contenu sponsorise sur le nouvel onglet.
- **Outillage en Nolc** : les outils du depot sont ecrits en
  [Noliae Code](https://wiki.noliae.com).

## Arborescence

| Chemin | Role |
|---|---|
| `outils/` | Outils Nolc : `version_esr.nol` (version ESR upstream), `verifie_prefs.nol` (garde-fou prefs) |
| `prefs/nolfox.js` | Defaults NolFox (DRM, telemetrie, nouvel onglet) |
| `distribution/policies.json` | Policies d'entreprise embarquees |
| `mozconfig` | Configuration de build (branding, Widevine, release) |
| `scripts/` | `fetch.sh` puis `brand.sh` puis `build.sh` |

## Build local

Prerequis : `nolc` (releases sur le S3 Noliae), ~40 Go de disque, les
dependances Firefox sont installees par `mach bootstrap`.

```bash
bash scripts/fetch.sh
bash scripts/brand.sh
bash scripts/build.sh
```

Le paquet sort dans `build/firefox-source/obj-*/dist/`.

## CI/CD

- **CI** (`ci.yml`, chaque push) : compile et execute les outils Nolc,
  valide `prefs/nolfox.js` et `policies.json`, shellcheck des scripts.
- **Build** (`build.yml`, manuel ou tag `v*`) : build complet Linux x86_64
  sur les sources ESR courantes, artefact + Release GitHub sur tag.

## Licences

Le contenu de ce depot est sous licence MPL-2.0, comme Firefox. Les binaires
produits embarquent du code Mozilla (MPL-2.0). NolFox n'utilise pas les
marques ni le branding officiel Mozilla.
