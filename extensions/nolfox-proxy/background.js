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
    // « proxyDNS » n'existe que pour SOCKS : le passer à un proxy HTTPS
    // fait rejeter la règle et le trafic repart en direct.
    return {
      type: etat.type,
      host: etat.hote,
      port: etat.port
    };
  },
  { urls: ["<all_urls>"] }
);

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

// Une erreur de proxy est remontée à l'utilisateur au lieu d'être avalée :
// sans cela, le proxy « ne marche pas » sans qu'on sache pourquoi.
browser.proxy.onError.addListener((erreur) => {
  console.error("NolFox Proxy :", erreur && erreur.message);
  browser.storage.local.set({ derniereErreur: String(erreur && erreur.message) });
  browser.browserAction.setBadgeText({ text: "!" });
  browser.browserAction.setBadgeBackgroundColor({ color: "#b3261e" });
});

browser.storage.onChanged.addListener((changements) => {
  for (const cle of Object.keys(changements)) {
    etat[cle] = changements[cle].newValue;
  }
  majBadge();
});

chargerEtat();
