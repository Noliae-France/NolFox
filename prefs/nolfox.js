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

// Écosystème Noliae : recherche + IA
pref("browser.startup.homepage", "https://noliae.com");

// Identité
pref("distribution.about", "NolFox par Noliae");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_override_url", "");
