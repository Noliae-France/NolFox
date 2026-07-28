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
  $("statut").textContent = e.actif
    ? "Trafic chiffré via " + e.hote
    : "Proxy inactif";
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
