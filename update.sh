#!/bin/bash

# --------------------- Banner ---------------------
echo '           ___
          |_|_|
          |_|_|              _____
          |_|_|     ____    |*_*_*|
 _______   _\__\___/ __ \____|_|_   _______
/ ____  |=|      \  <_+>  /      |=|  ____ \
~|    |\|=|======\\______//======|=|/|    |~
 |_   |    \      |      |      /    |    |
  \==-|     \     |inuiti|     /     |----|~~/
  |   |      |    |      |    |      |____/~/
  |   |       \____\____/____/      /    / /
  |   |         {----------}       /____/ /
  |___|        /~~~~~~~~~~~~\     |_/~|_|/
   \_/        |/~~~~~||~~~~~\|     /__|\
   | |         |    ||||    |     (/|| \)
   | |        /     |  |     \       \\
   |_|        |     |  |     |
              |_____|  |_____|
              (_____)  (_____)
              |     |  |     |
              |     |  |     |
              |/~~~\|  |/~~~\|
              /|___|\  /|___|\
             <_______><_______> '

# ------------------ Configuration ------------------
LOG_FILE="/var/log/system_update_$(date '+%Y-%m-%d_%H-%M-%S').log"

log() {
    echo -e "\033[1;32m[$(date '+%Y-%m-%d %H:%M:%S')]\033[0m $1" | tee -a "$LOG_FILE"
}

handle_error() {
    log "❌ ERROR: $1"
    exit 1
}

# ------------------- Error handling -------------------
trap 'handle_error "An unexpected error occurred."' ERR
set -e

# ------------------ Root check ------------------
if [ "$EUID" -ne 0 ]; then
    handle_error "Please run this script as root or using sudo."
fi

# ------------------- Check for available updates -------------------
log "Checking available package updates..."

nala update

# Nala
NALA_UPGRADES=$(nala list --upgradable 2>/dev/null || true)
NALA_HAS_UPGRADES=$(echo "$NALA_UPGRADES" | grep -q "upgradable" && echo "yes" || echo "no")

# Flatpak
FLATPAK_UPGRADES=$(flatpak remote-ls --updates 2>/dev/null)
FLATPAK_HAS_UPGRADES=$(echo "$FLATPAK_UPGRADES" | grep -q . && echo "yes" || echo "no")

# Snap
SNAP_UPGRADES=$(snap refresh --list 2>/dev/null)
SNAP_HAS_UPGRADES=$(echo "$SNAP_UPGRADES" | grep -q . && echo "yes" || echo "no")

# ------------------- Show update lists -------------------
log "💡 Available updates:"

if [ "$NALA_HAS_UPGRADES" = "yes" ]; then
    echo -e "\n--- APT/NALA ---"
    echo "$NALA_UPGRADES"
else
    echo -e "\n--- APT/NALA ---"
    echo "No updates available."
fi

if [ "$FLATPAK_HAS_UPGRADES" = "yes" ]; then
    echo -e "\n--- FLATPAK ---"
    echo "$FLATPAK_UPGRADES"
else
    echo -e "\n--- FLATPAK ---"
    echo "No updates available."
fi

if [ "$SNAP_HAS_UPGRADES" = "yes" ]; then
    echo -e "\n--- SNAP ---"
    echo "$SNAP_UPGRADES"
else
    echo -e "\n--- SNAP ---"
    echo "No updates available."
fi

# ------------------- User selection -------------------
echo ""
echo "Which sources do you want to update? Enter a combination of letters (e.g. NF, S, A, Q):"
echo "[N] nala    [F] flatpak    [S] snap    [A] all    [Q] quit"
read -p "Your choice: " choice

choice="${choice^^}"  # convert to uppercase

# Selection flags
UPDATE_NALA=false
UPDATE_FLATPAK=false
UPDATE_SNAP=false

if [[ "$choice" == *"Q"* ]]; then
    log "Update cancelled by user."
    exit 0
fi

if [[ "$choice" == *"A"* ]]; then
    UPDATE_NALA=true
    UPDATE_FLATPAK=true
    UPDATE_SNAP=true
else
    [[ "$choice" == *"N"* ]] && UPDATE_NALA=true
    [[ "$choice" == *"F"* ]] && UPDATE_FLATPAK=true
    [[ "$choice" == *"S"* ]] && UPDATE_SNAP=true
fi

# ------------------- Perform updates -------------------
if [ "$UPDATE_NALA" = true ]; then
    if [ "$NALA_HAS_UPGRADES" = "yes" ]; then
        log "🔧 Updating packages using nala..."
        nala upgrade -y
    else
        log "No updates available for nala."
    fi
fi

if [ "$UPDATE_FLATPAK" = true ]; then
    if [ "$FLATPAK_HAS_UPGRADES" = "yes" ]; then
        log "🔧 Updating flatpak packages..."
        flatpak update -y
    else
        log "No updates available for flatpak."
    fi
fi

if [ "$UPDATE_SNAP" = true ]; then
    if [ "$SNAP_HAS_UPGRADES" = "yes" ]; then
        log "🔧 Updating snap packages..."
        snap refresh
    else
        log "No updates available for snap."
    fi
fi

# ------------------- Reboot / Shutdown -------------------
read -p "Do you want to restart the system? (Y/N/P): " reboot_choice
case "${reboot_choice^^}" in
    Y)
        log "Rebooting system..."
        reboot
        ;;
    P)
        log "Shutting down system..."
        poweroff
        ;;
    *)
        log "Update process completed. Ave YOU."
        ;;
esac

