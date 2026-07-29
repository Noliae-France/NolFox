// Popup NolFox Proxy : activation en un clic, serveur configurable.
const $ = (id) => document.getElementById(id);

const DEFAUTS = {
  actif: false,
  hote: "proxy.avenqelis.com",
  port: 443,
  identifiant: "",
  motdepasse: ""
};

function saisie() {
  return {
    hote: $("hote").value.trim() || DEFAUTS.hote,
    port: parseInt($("port").value, 10) || DEFAUTS.port,
    identifiant: $("identifiant").value.trim(),
    motdepasse: $("motdepasse").value
  };
}

async function rendre() {
  const e = await browser.storage.local.get({ ...DEFAUTS, derniereErreur: "" });
  $("hote").value = e.hote;
  $("port").value = e.port;
  $("identifiant").value = e.identifiant;
  $("motdepasse").value = e.motdepasse;
  $("bascule").className = e.actif ? "on" : "off";
  $("bascule").textContent = e.actif ? "Désactiver le proxy" : "Activer le proxy";

  if (e.actif && e.derniereErreur) {
    $("statut").textContent = "Erreur : " + e.derniereErreur;
  } else {
    $("statut").textContent = e.actif
      ? "Trafic chiffré via " + e.hote
      : "Proxy inactif";
  }
}

$("bascule").addEventListener("click", async () => {
  const e = await browser.storage.local.get({ actif: false });
  // Une bascule repart d'une ardoise propre : l'erreur précédente n'a
  // plus lieu d'être affichée.
  await browser.storage.local.set({
    ...saisie(),
    actif: !e.actif,
    derniereErreur: ""
  });
  await rendre();
});

// Test de connexion : affiche l'adresse vue par les sites, ce qui prouve
// que le trafic passe réellement par le proxy Noliae.
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
    $("statut").textContent = "Échec : " + erreur.message;
  }
});

for (const champ of ["hote", "port", "identifiant", "motdepasse"]) {
  $(champ).addEventListener("change", () => browser.storage.local.set(saisie()));
}

rendre();
