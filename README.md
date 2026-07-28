# NolFox

[![CI](https://github.com/Noliae-France/NolFox/actions/workflows/ci.yml/badge.svg)](https://github.com/Noliae-France/NolFox/actions/workflows/ci.yml)
[![DMG macOS](https://github.com/Noliae-France/NolFox/actions/workflows/dmg.yml/badge.svg)](https://github.com/Noliae-France/NolFox/actions/workflows/dmg.yml)
[![Build NolFox](https://github.com/Noliae-France/NolFox/actions/workflows/build.yml/badge.svg)](https://github.com/Noliae-France/NolFox/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/Noliae-France/NolFox?label=release&color=FF4D2E)](https://github.com/Noliae-France/NolFox/releases/latest)
[![Licence](https://img.shields.io/badge/licence-MPL--2.0-FF4D2E)](LICENSE)

**Le navigateur de Noliae.** Basé sur **Firefox ESR** (canal long support de
Mozilla), NolFox garde le moteur Gecko, sa stabilité et ses correctifs de
sécurité, et y ajoute ce que Firefox n'offre pas : un proxy chiffré intégré,
une interface repensée, l'écosystème Noliae et une vie privée sans compromis.

## Téléchargement

Les versions sont publiées sur la [page des Releases](https://github.com/Noliae-France/NolFox/releases/latest).

| Plateforme | Fichier |
|---|---|
| macOS Apple Silicon | `NolFox-<version>-apple-silicon.dmg` |
| macOS Intel | `NolFox-<version>-intel.dmg` |
| Linux x86_64 | `nolfox-<version>.tar.xz` |

Chaque archive est accompagnée de son empreinte `.sha256`. Pour vérifier :

```bash
shasum -a 256 -c NolFox-*.dmg.sha256
```

## Ce que NolFox a en plus de Firefox

| | Firefox | NolFox |
|---|---|---|
| Proxy / VPN intégré | Payant (Mozilla VPN) | **Inclus** : proxy chiffré Noliae, activation en un clic |
| Interface | Standard | **Thème Pulse** sombre, accent orange, densité compacte |
| Moteur de recherche | Google (accord commercial) | **noliae.com**, souverain, alias `@noliae` |
| IA intégrée | Anthropic/OpenAI tiers | **Noliae IA** dans la barre personnelle |
| Télémétrie | Activée par défaut | **Zéro** : rien ne part, jamais |
| Contenu sponsorisé | Nouvel onglet, suggestions | **Aucun** |
| Anti-pistage | Standard | **Strict** : le bouclier prévient des traqueurs bloqués (pistage social, cryptominage, fingerprinting) |
| Signaux vie privée | GPC opt-in | **GPC + DNT actifs** : les sites qui collectent sont prévenus |
| Streaming DRM | Widevine à activer | **Widevine prêt** : Netflix, Prime Video, Spotify, YouTube sans réglage |

## Fonctionnalités intégrées

- **NolFox Proxy** (`extensions/nolfox-proxy`) : extension embarquée qui
  route le trafic via le proxy chiffré Noliae. Un clic sur l'icône, le badge
  passe à `ON`, votre adresse IP est masquée. Les adresses locales restent en
  direct et une panne du proxy ne casse jamais la navigation. Le service
  tourne sur l'infrastructure Noliae (`proxy.avenqelis.com:443`), en CONNECT
  authentifié, sans aucun journal de navigation.
- **DNS chiffré (DoH)** : résolveur `https://dns.avenqelis.com/dns-query`,
  filtrage des traqueurs et publicités à la source, requêtes anonymisées et
  journal des requêtes désactivé.
- **VPN WireGuard** : accès complet au tunnel Noliae, administration sur
  `vpn.avenqelis.com`.
- **Thème Pulse** (`extensions/nolfox-theme`) : identité visuelle Noliae,
  fond sombre `#101014`, accent `#FF4D2E`, appliqué dès le premier lancement.
- **Écosystème Noliae** : recherche noliae.com par défaut, page d'accueil
  noliae.com, accès direct à [Noliae IA](https://ia.noliae.com).

## Plateformes

| Plateforme | État |
|---|---|
| Linux x86_64 | ✅ Build CI (`build.yml`) |
| macOS (Apple Silicon et Intel) | ✅ DMG prêt à installer (`dmg.yml`) |
| Windows x86_64 | 🧪 Build CI expérimental |
| Android | 🔜 Prévu (base GeckoView/Fenix, dépôt dédié) |
| iOS | 🔜 Prévu (moteur WebKit imposé par Apple, dépôt dédié) |

## Comment c'est construit

Le dépôt ne contient pas les sources Mozilla : il porte l'identité NolFox,
les réglages et l'outillage. La chaîne de build télécharge les sources ESR
officielles puis applique le tout.

| Chemin | Rôle |
|---|---|
| `branding/` | Icônes NolFox : source SVG, PNG Linux, `.ico` Windows, `.icns` macOS |
| `outils/` | Outils **Nolc** : `version_esr.nol` (version ESR upstream), `verifie_prefs.nol` (garde-fou prefs) |
| `extensions/` | NolFox Proxy + thème Pulse, empaquetés en XPI au build |
| `prefs/nolfox.js` | Défauts NolFox (DRM, vie privée, anti-pistage, interface, Noliae) |
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

- **CI** (`ci.yml`, chaque push) : exécute les outils Nolc, valide
  `prefs/nolfox.js`, `policies.json` et les manifests d'extensions,
  empaquette les XPI, shellcheck des scripts.
- **Build** (`build.yml`, manuel ou tag `v*`) : builds complets Linux,
  macOS et Windows (expérimental) sur les sources ESR courantes,
  artefacts + Release GitHub sur tag.
- **DMG macOS** (`dmg.yml`, manuel ou tag `v*`) : construit NolFox pour
  Apple Silicon et Intel, fabrique le `.dmg`, vérifie qu'il se monte et
  contient bien l'application, publie l'archive et son empreinte SHA-256.

## Licences

Le contenu de ce dépôt est sous licence MPL-2.0, comme Firefox. Les binaires
produits embarquent du code Mozilla (MPL-2.0). NolFox n'utilise ni les
marques ni le branding officiel Mozilla. Netflix, YouTube, Spotify et les
autres marques citées appartiennent à leurs propriétaires respectifs.
