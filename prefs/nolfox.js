// Defaults NolFox, injectes dans le branding au build.
// Compatibilite streaming (Netflix, Prime Video, Spotify, YouTube) : DRM actif.
pref("media.eme.enabled", true);
pref("media.gmp-widevinecdm.enabled", true);
pref("media.gmp-widevinecdm.visible", true);
pref("media.gmp-manager.updateEnabled", true);
pref("media.ffmpeg.vaapi.enabled", true);

// Performance video
pref("media.hardware-video-decoding.enabled", true);
pref("layers.acceleration.force-enabled", false);

// Vie privee : telemetrie Mozilla coupee, sans casser les sites
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

// Identite
pref("distribution.about", "NolFox par Noliae");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_override_url", "");
