# NolFox

Navigateur web édité par **Noliae**, basé sur **Firefox ESR** (canal long
support de Mozilla). Le dépôt ne contient pas les sources Mozilla : il porte
l'identité NolFox, les réglages et l'outillage, et la chaîne de build
télécharge les sources ESR officielles puis applique le tout.

## Principes

- **Base Firefox ESR** : stabilité et correctifs de sécurité du canal LTS.
- **Streaming sans friction** : DRM Widevine activé dès l'installation.
  Netflix, Prime Video, Spotify, YouTube fonctionnent sans réglage.
- **Zéro télémétrie, zéro récupération de données** : aucun envoi vers
  Mozilla (télémétrie, études Shield/Normandy, rapports de plantage),
  aucune suggestion sponsorisée, pas de contenu publicitaire.
- **Prévenir plutôt que subir** : anti-pistage strict (le bouclier signale
  les traqueurs bloqués : pistage social, cryptominage, fingerprinting) et
  signaux GPC + DNT envoyés aux sites qui collectent des données.
- **Écosystème Noliae intégré** : moteur de recherche
  [noliae.com](https://noliae.com) par défaut (alias `@noliae`), accès
  direct à [Noliae IA](https://ia.noliae.com) depuis la barre personnelle,
  page d'accueil noliae.com.
- **Outillage en Nolc** : les outils du dépôt sont écrits en
  [Noliae Code](https://wiki.noliae.com).

## Arborescence

| Chemin | Rôle |
|---|---|
| `outils/` | Outils Nolc : `version_esr.nol` (version ESR upstream), `verifie_prefs.nol` (garde-fou prefs) |
| `prefs/nolfox.js` | Défauts NolFox (DRM, vie privée, anti-pistage, Noliae) |
| `distribution/policies.json` | Policies embarquées (recherche Noliae, signets IA) |
| `mozconfig` | Configuration de build (branding, Widevine, release) |
| `scripts/` | `fetch.sh` puis `brand.sh` puis `build.sh` |

## Build local

Prérequis : `nolc` (releases sur le S3 Noliae), ~40 Go de disque ; les
dépendances Firefox sont installées par `mach bootstrap`.

```bash
bash scripts/fetch.sh
bash scripts/brand.sh
bash scripts/build.sh
```

Le paquet sort dans `build/firefox-source/obj-*/dist/`.

## CI/CD

- **CI** (`ci.yml`, chaque push) : compile et exécute les outils Nolc,
  valide `prefs/nolfox.js` et `policies.json`, shellcheck des scripts.
- **Build** (`build.yml`, manuel ou tag `v*`) : build complet Linux x86_64
  sur les sources ESR courantes, artefact + Release GitHub sur tag.

## Licences

Le contenu de ce dépôt est sous licence MPL-2.0, comme Firefox. Les binaires
produits embarquent du code Mozilla (MPL-2.0). NolFox n'utilise ni les
marques ni le branding officiel Mozilla.
