#!/usr/bin/env bash
# Optimisation d'une TV TCL Google TV (testé pour 65C845) via ADB.
# Tout est réversible : les applis sont désactivées (pas supprimées).
#
# Usage :
#   ./optimize-tcl-tv.sh <IP_DE_LA_TV> scan       # liste les applis installées
#   ./optimize-tcl-tv.sh <IP_DE_LA_TV> optimize   # applique les optimisations
#   ./optimize-tcl-tv.sh <IP_DE_LA_TV> restore    # annule tout
set -euo pipefail

IP="${1:-}"
MODE="${2:-}"
if [[ -z "$IP" || ! "$MODE" =~ ^(scan|optimize|restore)$ ]]; then
  sed -n '5,8p' "$0"; exit 1
fi
command -v adb >/dev/null || { echo "adb introuvable : installe 'android-platform-tools'."; exit 1; }

# Applis de fond inutiles pour regarder la TV (pub, télémétrie, chaînes TCL...).
# Celles qui n'existent pas sur ta TV sont simplement ignorées.
BLOAT=(
  com.tcl.waterfall.overseas        # TCL Channel (contenu sponsorisé)
  com.tcl.usercenter                # Compte TCL
  com.tcl.common.weather            # Météo TCL
  com.tcl.tvhealthcheck             # Diagnostic TCL en tâche de fond
  com.tcl.MultiScreenInteraction_TV # T-Cast
  com.tcl.gallery                   # Galerie TCL
  com.tcl.ui_mediaCenter            # Lecteur média TCL
  com.google.android.feedback       # Envoi de rapports Google
  com.google.android.tvrecommendations
  com.google.android.play.games
  com.google.android.marvin.talkback
  com.android.printspooler
)

adb connect "$IP:5555" >/dev/null
echo "Connecté à $IP — si la TV affiche « Autoriser le débogage ? », accepte."
adb -s "$IP:5555" wait-for-device
A=(adb -s "$IP:5555" shell)

case "$MODE" in
  scan)
    echo "== Applis TCL / tierces installées =="
    "${A[@]}" pm list packages | sed 's/package://' | grep -Ei 'tcl|xiaomi|ads|partner' | sort
    echo; echo "== Mémoire =="
    "${A[@]}" cat /proc/meminfo | head -3
    ;;

  optimize)
    echo "-> Animations accélérées (0.5x) : l'interface paraît beaucoup plus réactive"
    for k in window_animation_scale transition_animation_scale animator_duration_scale; do
      "${A[@]}" settings put global "$k" 0.5
    done

    echo "-> Désactivation des applis inutiles"
    installed="$("${A[@]}" pm list packages | sed 's/package://' | tr -d '\r')"
    for p in "${BLOAT[@]}"; do
      if grep -qx "$p" <<<"$installed"; then
        "${A[@]}" pm disable-user --user 0 "$p" >/dev/null && echo "   désactivé : $p"
      fi
    done

    echo "-> Nettoyage des caches et arrêt des processus en arrière-plan"
    "${A[@]}" pm trim-caches 999G >/dev/null || true
    "${A[@]}" am kill-all

    echo "Terminé. Redémarre la TV (débranche 30 s) pour un effet maximal."
    ;;

  restore)
    for k in window_animation_scale transition_animation_scale animator_duration_scale; do
      "${A[@]}" settings put global "$k" 1.0
    done
    for p in "${BLOAT[@]}"; do
      "${A[@]}" pm enable "$p" >/dev/null 2>&1 && echo "   réactivé : $p" || true
    done
    echo "Réglages d'origine restaurés."
    ;;
esac
