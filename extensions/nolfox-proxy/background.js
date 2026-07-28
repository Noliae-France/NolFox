// NolFox Proxy : route le trafic du navigateur vers le proxy chiffré Noliae.
// Désactivé par défaut ; l'utilisateur l'active depuis le popup.

const DEFAUTS = {
  actif: false,
  hote: "proxy.avenqelis.com",
  port: 443,
  type: "https",
  identifiant: "",
  motdepasse: ""
};

let etat = { ...DEFAUTS };

async function chargerEtat() {
  const stocke = await browser.storage.local.get(DEFAUTS);
  etat = { ...DEFAUTS, ...stocke };
  majBadge();
}

function majBadge() {
  browser.browserAction.setBadgeText({ text: etat.actif ? "ON" : "" });
  browser.browserAction.setBadgeBackgroundColor({ color: "#FF4D2E" });
}

// Décision de proxy par requête : tout passe par Noliae quand actif,
// sauf les adresses locales.
browser.proxy.onRequest.addListener(
  (details) => {
    if (!etat.actif) return { type: "direct" };
    const url = new URL(details.url);
    const h = url.hostname;
    if (
      h === "localhost" ||
      h.endsWith(".local") ||
      h.startsWith("127.") ||
      h.startsWith("192.168.") ||
      h.startsWith("10.")
    ) {
      return { type: "direct" };
    }
    return {
      type: etat.type,
      host: etat.hote,
      port: etat.port,
      proxyDNS: true
    };
  },
  { urls: ["<all_urls>"] }
);

// En cas d'erreur proxy, on repasse en direct plutôt que de casser la navigation.
// Le proxy exige une authentification : elle est fournie ici, jamais
// stockée en clair dans une URL ni envoyée à un autre hôte.
browser.webRequest.onAuthRequired.addListener(
  (details) => {
    if (!details.isProxy || !etat.actif || !etat.identifiant) return {};
    return {
      authCredentials: {
        username: etat.identifiant,
        password: etat.motdepasse
      }
    };
  },
  { urls: ["<all_urls>"] },
  ["blocking"]
);

browser.proxy.onError.addListener(() => {
  etat.actif = false;
  browser.storage.local.set({ actif: false });
  majBadge();
});

browser.storage.onChanged.addListener((changements) => {
  for (const cle of Object.keys(changements)) {
    etat[cle] = changements[cle].newValue;
  }
  majBadge();
});

chargerEtat();
