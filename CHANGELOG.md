# Journal des versions

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).
NolFox suit le canal **Firefox ESR** : chaque version indique la base Mozilla
sur laquelle elle est construite.

## [0.1.0] - 2026-07-28

Première version publiée de NolFox, construite sur Firefox ESR 140.13.0.

### Ajouté

- **Base Firefox ESR** : moteur Gecko du canal long support, correctifs de
  sécurité Mozilla, sources téléchargées et reconstruites à chaque build.
- **Streaming sans réglage** : Widevine compilé (`--enable-eme=widevine`),
  Netflix, Prime Video, Spotify et YouTube fonctionnent dès l'installation.
- **NolFox Proxy** : extension embarquée, activation en un clic, trafic
  chiffré vers l'infrastructure Noliae en CONNECT authentifié. Les adresses
  locales restent en direct et une panne du proxy ne coupe pas la navigation.
- **DNS chiffré (DoH)** : résolveur Noliae avec filtrage des traqueurs et des
  publicités à la source, requêtes anonymisées, aucun journal conservé.
- **VPN WireGuard** : tunnel complet vers l'infrastructure Noliae.
- **Thème Pulse** : interface sombre `#101014`, accent `#FF4D2E`, densité
  compacte, appliquée dès le premier lancement.
- **Icônes NolFox** : logo waveform décliné en PNG, `.ico` Windows et
  `.icns` macOS ; fenêtre sombre dès l'ouverture, sans flash blanc.
- **Écosystème Noliae** : recherche noliae.com par défaut (alias `@noliae`),
  page d'accueil noliae.com, accès direct à Noliae IA.
- **Outillage Nolc** : extraction de la version ESR upstream et validation
  des préférences, exécutés à chaque intégration continue.

### Sécurité et vie privée

- Télémétrie Mozilla, études Shield/Normandy et rapports de plantage coupés.
- Anti-pistage strict : pistage social, cryptominage et fingerprinting
  bloqués, le bouclier signale ce qu'il arrête.
- Signaux **GPC** et **DNT** actifs : les sites qui collectent sont prévenus.
- Aucune suggestion sponsorisée ni contenu publicitaire.

### Infrastructure

- Services proxy, DoH et VPN déployés et durcis contre les robots :
  limitation par adresse IP, rejet des scanners sans SNI, blocage des agents
  automatisés connus, authentification obligatoire sur le proxy.

[0.1.0]: https://github.com/Noliae-France/NolFox/releases/tag/v0.1.0
