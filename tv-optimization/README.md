# Optimiser la TV TCL 65C845 (Google TV)

Le script se lance **depuis un ordinateur connecté au même Wi-Fi que la TV**.

## 1. Activer le débogage sur la TV
1. Paramètres → Système → À propos → appuyer **7 fois** sur « Build du système d'exploitation Android TV ».
2. Paramètres → Système → **Options pour les développeurs** → activer **Débogage USB** (et « Débogage réseau » s'il existe).
3. Paramètres → Réseau → noter l'**adresse IP** de la TV (ex. `192.168.1.42`).

## 2. Installer ADB sur l'ordinateur
- Mac : `brew install android-platform-tools`
- Linux : `sudo apt install adb`
- Windows : utiliser WSL, ou télécharger les « SDK Platform-Tools » de Google.

## 3. Lancer
```bash
./optimize-tcl-tv.sh 192.168.1.42 scan       # voir ce qui est installé
./optimize-tcl-tv.sh 192.168.1.42 optimize   # optimiser
./optimize-tcl-tv.sh 192.168.1.42 restore    # tout annuler si besoin
```
Au premier lancement, la TV demande d'autoriser l'ordinateur : choisir **Toujours autoriser**.

## Ce que fait `optimize`
- Animations à 0.5x → menus nettement plus vifs.
- Désactive (sans supprimer) les applis TCL/Google de fond : TCL Channel, météo, télémétrie, Assistant Google…
- Vide les caches et ferme les processus inutiles.

L'Assistant Google est désactivé : le bouton micro de la télécommande et la recherche vocale ne marcheront plus (`restore` les réactive).
Netflix, YouTube, Prime et le lanceur Google TV ne sont pas touchés.

## Astuces sans ordinateur
- Débrancher la TV 30 s de temps en temps (vraie remise à zéro de la mémoire).
- Paramètres → Applications → désinstaller les applis jamais utilisées.
- Paramètres → Comptes → désactiver « Recommandations » si le menu d'accueil rame.
- Pour les jeux / la console : activer le **Mode Jeu** (réduit la latence de l'image).
- Désactiver le lissage de mouvement (MEMC / « Motion Clarity ») réduit aussi le décalage.
