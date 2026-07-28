// Défauts NolFox, injectés dans le branding au build.
// Compatibilité streaming (Netflix, Prime Video, Spotify, YouTube) : DRM actif.
pref("media.eme.enabled", true);
pref("media.gmp-widevinecdm.enabled", true);
pref("media.gmp-widevinecdm.visible", true);
pref("media.gmp-manager.updateEnabled", true);
pref("media.ffmpeg.vaapi.enabled", true);

// Performance video
pref("media.hardware-video-decoding.enabled", true);
pref("layers.acceleration.force-enabled", false);

// Vie privee : télémétrie Mozilla coupée, sans casser les sites
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.unified", false);
pref("toolkit.telemetry.archive.enabled", false);
pref("browser.newtabpage.activity-stream.telemetry", false);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
pref("app.shield.optoutstudies.enabled", false);
pref("app.normandy.enabled", false);
pref("breakpad.reportURL", "");
pref("browser.tabs.crashReporting.sendReport", false);

// Pas de sponsors sur le nouvel onglet
pref("browser.newtabpage.activity-stream.showSponsored", false);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Anti-pistage : mode strict, le bouclier prévient des trackers bloqués
pref("browser.contentblocking.category", "strict");
pref("privacy.trackingprotection.enabled", true);
pref("privacy.trackingprotection.socialtracking.enabled", true);
pref("privacy.trackingprotection.cryptomining.enabled", true);
pref("privacy.trackingprotection.fingerprinting.enabled", true);
pref("privacy.purge_trackers.enabled", true);
pref("network.cookie.cookieBehavior", 5);

// Prévient les sites qui récupèrent les donnees : signaux GPC + DNT
pref("privacy.globalprivacycontrol.enabled", true);
pref("privacy.globalprivacycontrol.functionality.enabled", true);
pref("privacy.donottrackheader.enabled", true);

// Zéro récupération de donnees côté navigateur
pref("browser.search.suggest.enabled", false);
pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
pref("extensions.getAddons.showPane", false);
pref("browser.discovery.enabled", false);
pref("dom.private-attribution.submission.enabled", false);

// Couleurs de lancement : fenêtre sombre Pulse dès l'ouverture,
// jamais de flash blanc au démarrage ni entre les pages
pref("browser.display.background_color.dark", "#101014");
pref("browser.startup.blankWindow", false);
pref("browser.startup.preXulSkeletonUI", true);
pref("layout.css.prefers-color-scheme.content-override", 2);

// Interface NolFox : densité compacte autorisée, thème Pulse embarqué
pref("browser.compactmode.show", true);
pref("browser.uidensity", 1);
pref("browser.toolbars.bookmarks.visibility", "always");
pref("extensions.activeThemeID", "theme@nolfox.noliae.com");
pref("extensions.autoDisableScopes", 0);
pref("extensions.installDistroAddons", true);

// NolFox n'est pas signe par Mozilla : sans cela, le proxy, le theme et
// la langue francaise seraient installes puis desactives au demarrage.
pref("xpinstall.signatures.required", false);
pref("extensions.langpacks.signatures.required", false);
pref("extensions.experiments.enabled", true);

// Habillage NolFox charge depuis le profil (userChrome.css)
pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Navigateur en francais
pref("intl.locale.requested", "fr");
pref("intl.accept_languages", "fr-FR, fr, en-US, en");
pref("javascript.use_us_english_locale", false);
pref("browser.search.region", "FR");
pref("distribution.searchplugins.defaultLocale", "fr-FR");
pref("browser.theme.dark-private-wins", true);

// DNS chiffre (DoH) sur le resolveur Noliae : les requetes ne passent
// plus en clair par le fournisseur d'acces. Mode 2 = DoH d'abord, repli
// sur le DNS du systeme si le resolveur est injoignable (portails captifs).
pref("network.trr.mode", 2);
pref("network.trr.uri", "https://dns.avenqelis.com/dns-query");
pref("network.trr.custom_uri", "https://dns.avenqelis.com/dns-query");
pref("network.trr.default_provider_uri", "https://dns.avenqelis.com/dns-query");
pref("network.trr.disable-ECS", true);
pref("network.trr.send_empty_accept-encoding_headers", false);
pref("network.dns.skipTRR-when-parental-control-enabled", false);
pref("doh-rollout.disable-heuristics", true);
pref("doh-rollout.skipHeuristicsCheck", true);

// Écosystème Noliae : recherche + IA
pref("browser.startup.homepage", "https://noliae.com");

// Identité
pref("distribution.about", "NolFox par Noliae");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_override_url", "");

// Proxy / VPN Noliae : quand un proxy chiffré demande un certificat client
// (mTLS), NolFox présente automatiquement le sien sans jamais demander à
// l'utilisateur -> le navigateur est "contacté et validé automatiquement".
pref("security.default_personal_cert", "Select Automatically");
// Ne pas fuiter les requêtes DNS hors du tunnel quand un proxy SOCKS/HTTPS est actif.
pref("network.proxy.socks_remote_dns", true);
pref("network.proxy.failover_direct", false);
