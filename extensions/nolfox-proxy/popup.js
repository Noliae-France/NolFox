// Popup NolFox Proxy : activation en un clic, serveur configurable.
const $ = (id) => document.getElementById(id);

async function rendre() {
  const e = await browser.storage.local.get({
    actif: false,
    hote: "proxy.avenqelis.com",
    port: 443,
    identifiant: "",
    motdepasse: ""
  });
  $("hote").value = e.hote;
  $("port").value = e.port;
  $("identifiant").value = e.identifiant;
  $("motdepasse").value = e.motdepasse;
  $("bascule").className = e.actif ? "on" : "off";
  $("bascule").textContent = e.actif ? "Désactiver le proxy" : "Activer le proxy";
  const stocke = await browser.storage.local.get({ derniereErreur: "" });
  if (e.actif && stocke.derniereErreur) {
    $("statut").textContent = "Erreur : " + stocke.derniereErreur;
  } else {
    $("statut").textContent = e.actif
      ? "Trafic chiffré via " + e.hote
      : "Proxy inactif";
  }
}

$("bascule").addEventListener("click", async () => {
  const e = await browser.storage.local.get({ actif: false });
  await browser.storage.local.set({
    actif: !e.actif,
    hote: $("hote").value.trim() || "proxy.avenqelis.com",
    port: parseInt($("port").value, 10) || 443,
    identifiant: $("identifiant").value.trim(),
    motdepasse: $("motdepasse").value
  });
  // Test de connexion : affiche l'adresse vue par les sites, ce qui prouve
// que le trafic passe reellement par le proxy Noliae.
$("tester").addEventListener("click", async () => {
  $("statut").textContent = "Test en cours...";
  try {
    const reponse = await fetch("https://api.ipify.org", { cache: "no-store" });
    const adresse = (await reponse.text()).trim();
    const e = await browser.storage.local.get({ actif: false });
    $("statut").textContent = e.actif
      ? "Adresse publique : " + adresse
      : "Proxy inactif, adresse : " + adresse;
  } catch (erreur) {
    $("statut").textContent = "Echec : " + erreur.message;
  }
});

rendre();
});

["hote", "port", "identifiant", "motdepasse"].forEach((id) =>
  $(id).addEventListener("change", async () => {
    await browser.storage.local.set({
      hote: $("hote").value.trim() || "proxy.avenqelis.com",
      port: parseInt($("port").value, 10) || 443,
      identifiant: $("identifiant").value.trim(),
      motdepasse: $("motdepasse").value
    });
  })
);

rendre();
