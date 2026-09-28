#!/usr/bin/env bash
# Installe le look Liquid Glass sur un téléphone Android ou l'émulateur (Mac / Linux).
# Lancement : bash install.sh
set -u
cd "$(dirname "$0")"

pause() { read -r -p "$1" _; }

# 1. Trouver adb (installé avec Android Studio)
ADB=""
for c in adb "${ANDROID_HOME:-}/platform-tools/adb" "$HOME/Library/Android/sdk/platform-tools/adb" "$HOME/Android/Sdk/platform-tools/adb"; do
    if command -v "$c" >/dev/null 2>&1; then ADB="$c"; break; fi
done
if [ -z "$ADB" ]; then
    echo "adb introuvable. Installe Android Studio (il contient adb), puis relance."
    exit 1
fi

# 2. Vérifier qu'un appareil est branché
if [ "$("$ADB" get-state 2>/dev/null)" != "device" ]; then
    echo "Aucun appareil détecté (ou plusieurs)."
    echo "- Émulateur : lance-le depuis Android Studio."
    echo "- Téléphone : active le débogage USB et accepte l'autorisation sur l'écran."
    exit 1
fi
echo "Appareil détecté."

is_installed() {
    "$ADB" shell pm list packages "$1" 2>/dev/null | tr -d '\r' | grep -qx "package:$1"
}

# 3. APK locaux éventuels (dossier apks/ à côté du script)
if [ -d apks ]; then
    for f in apks/*.apk; do
        [ -e "$f" ] || continue
        echo "Installation de $f..."
        "$ADB" install -r "$f"
    done
fi

# 4. Apps du Play Store listées dans apps.txt
while read -r pkg _; do
    case "$pkg" in ""|\#*) continue ;; esac
    if is_installed "$pkg"; then
        echo "✓ $pkg déjà installée"
        continue
    fi
    echo "→ Ouverture de $pkg dans le Play Store..."
    if ! "$ADB" shell am start -a android.intent.action.VIEW -d "market://details?id=$pkg" 2>&1 | grep -q "Starting"; then
        "$ADB" shell am start -a android.intent.action.VIEW -d "https://play.google.com/store/apps/details?id=$pkg" >/dev/null 2>&1
    fi
    pause "   Appuie sur « Installer » sur l'appareil, puis sur Entrée ici (ou Entrée pour passer)... "
    if is_installed "$pkg"; then echo "✓ $pkg installée"; else echo "✗ $pkg passée"; fi
done < apps.txt

# 5. Choisir l'écran d'accueil par défaut
echo
echo "Dernière étape : choisis « Liquid Launcher » comme écran d'accueil sur l'appareil."
"$ADB" shell am start -a android.settings.HOME_SETTINGS >/dev/null 2>&1
echo "Ensuite, dans Liquid Launcher, choisis le pack d'icônes iLiquid Dark."
echo "Terminé."
