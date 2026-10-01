#!/usr/bin/env bash
set -Eeuo pipefail

readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
readonly INSTALLED_VERSION_FILE="$HOME/.config/wkstationz/VERSION"

fail() { printf '%b\n' "${RED}Error: $*${NC}" >&2; exit 1; }
if ! { exec 3<>/dev/tty; } 2>/dev/null; then fail "No interactive terminal found. Run from a terminal session."; fi

# Determine script location - handle both direct execution and curl|bash
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SOURCE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || fail "Cannot access script directory."
else
    # When run via curl | bash, use current directory or WKSTATIONZ_WORK_DIR
    SOURCE_DIR="$(pwd)"
fi
if [[ -n "${WKSTATIONZ_WORK_DIR:-}" ]]; then
    SCRIPT_DIR="$WKSTATIONZ_WORK_DIR"
    CLEAN_WORK_DIR=0
else
    [[ -f "$SOURCE_DIR/packages.list" && -f "$SOURCE_DIR/VERSION" ]] || fail "packages.list and VERSION must be present beside install.sh. Clone the complete repository, not just install.sh."
    SCRIPT_DIR=$(mktemp -d /tmp/wkstationz.XXXXXX)
    CLEAN_WORK_DIR=1
    cp -a "$SOURCE_DIR"/. "$SCRIPT_DIR"/
fi
for required in \
    VERSION packages.list aur-packages.list \
    scripts/install-yay.sh scripts/apply-theme.sh scripts/enable-services.sh \
    configs/hyprland/hyprland.lua configs/hyprland/keybinds.lua \
    configs/hyprland/monitors-desktop.lua configs/hyprland/monitors-laptop.lua \
    configs/quickshell/config.qml configs/quickshell/Bar.qml configs/quickshell/SettingsPanel.qml \
    configs/rofi/launcher/launcher.sh configs/kitty/kitty.conf \
    configs/swaync/config.json configs/gtk-3.0/settings.ini; do
    [[ -f "$SCRIPT_DIR/$required" ]] || fail "Repository is incomplete: missing $required. Clone the complete wkstationz repository."
done
if [[ "$CLEAN_WORK_DIR" == 1 ]]; then
    trap 'rm -rf -- "$SCRIPT_DIR"' EXIT
fi
cd "$SCRIPT_DIR"
VERSION=$(cat "$SCRIPT_DIR/VERSION")
printf '%b\n' "${BLUE}wkstationz v$VERSION${NC}"

prompt_choice() {
    local prompt="$1" allowed="$2" answer
    while true; do
        printf '%s' "$prompt" >/dev/tty
        IFS= read -r -u 3 answer || fail "Terminal input closed while waiting for a choice."
        answer="${answer//[[:space:]]/}"
        if [[ "$answer" =~ $allowed ]]; then REPLY="$answer"; return; fi
        printf '%b\n' "${YELLOW}Please enter one of the listed choices.${NC}" >/dev/tty
    done
}

INSTALL_MODE="${WKSTATIONZ_MODE:-}"
if [[ -z "$INSTALL_MODE" ]]; then
    installed=""
    [[ -f "$INSTALLED_VERSION_FILE" ]] && IFS= read -r installed < "$INSTALLED_VERSION_FILE" || true
    if [[ -z "$installed" ]]; then
        printf '%s\n' "No installed version found." "1) Install" "2) Update/reapply setup" "3) Exit" >/dev/tty
        prompt_choice "Choose [1-3]: " '^[1-3]$'
        case "$REPLY" in 1) INSTALL_MODE=install ;; 2) INSTALL_MODE=update ;; 3) exit 0 ;; esac
    elif [[ "$installed" == "$VERSION" ]]; then
        printf 'Installed version %s is current.\n' "$installed" >/dev/tty
        printf '%s\n' "1) Update/reapply setup" "2) Exit" >/dev/tty
        prompt_choice "Choose [1-2]: " '^[1-2]$'
        [[ "$REPLY" == 1 ]] || exit 0
        INSTALL_MODE=update
    elif [[ "$(printf '%s\n' "$installed" "$VERSION" | sort -V | tail -n1)" == "$VERSION" ]]; then
        INSTALL_MODE=update
    else
        printf 'Installed version %s is newer than %s.\n' "$installed" "$VERSION" >/dev/tty
        printf '%s\n' "1) Reinstall/downgrade" "2) Exit" >/dev/tty
        prompt_choice "Choose [1-2]: " '^[1-2]$'
        [[ "$REPLY" == 1 ]] || exit 0
        INSTALL_MODE=install
    fi
fi

if [[ "${WKSTATIONZ_SUDO_READY:-0}" != 1 ]]; then
    printf '\nRequesting administrator privileges...\n'
    sudo -k
    sudo -v <&3 || fail "Could not obtain sudo privileges."
fi

# Keep sudo authentication alive while package builds and installation run.
(while sleep 45; do sudo -n -v 2>/dev/null || exit; done) >/dev/null 2>&1 &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; if [[ "$CLEAN_WORK_DIR" == 1 ]]; then rm -rf -- "$SCRIPT_DIR"; fi' EXIT

printf '\nMachine type:\n' >/dev/tty
printf '%s\n' "1) Desktop (3 monitors)" "2) Laptop (built-in + external)" >/dev/tty
prompt_choice "Choose [1-2]: " '^[1-2]$'
if [[ "$REPLY" == 1 ]]; then
    MACHINE_TYPE=desktop
    MONITOR_CONFIG=monitors-desktop.lua
else
    MACHINE_TYPE=laptop
    MONITOR_CONFIG=monitors-laptop.lua
fi

KEYBOARD=pt
THEME=catppuccin
printf '\nKeyboard layout [pt]: ' >/dev/tty
IFS= read -r -u 3 input_keyboard || fail "Terminal input closed while waiting for keyboard layout."
[[ -n "$input_keyboard" ]] && KEYBOARD="${input_keyboard//[[:space:]]/}"
printf '\nSetup: %s | Machine: %s | Theme: Catppuccin Mocha | Keyboard: %s\n' "$INSTALL_MODE" "$MACHINE_TYPE" "$KEYBOARD" >/dev/tty
printf '%s\n' "1) Continue" "2) Cancel" >/dev/tty
prompt_choice "Choose [1-2]: " '^[1-2]$'
[[ "$REPLY" == 1 ]] || exit 0

LOG_FILE="/tmp/wkstationz-install.log"
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
trap 'printf "%b\n" "${RED}Installation failed near line $LINENO. See $LOG_FILE.${NC}" >&2' ERR
log "Starting v$VERSION ($INSTALL_MODE, $MACHINE_TYPE)"

backup_configs() {
    local name="$1" path="$HOME/.config/$1"
    if [[ -d "$path" ]]; then
        local backup="$path.backup.$(date +%Y%m%d_%H%M%S)"
        cp -a -- "$path" "$backup"
        printf 'Backed up %s to %s\n' "$name" "$backup"
    fi
}

install_packages() {
    printf '\nInstalling/updating packages...\n'
    sudo pacman -Syu --needed --noconfirm
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        sudo pacman -S --needed --noconfirm "$package"
    done < "$SCRIPT_DIR/packages.list"
    if ! command -v yay >/dev/null 2>&1; then bash "$SCRIPT_DIR/scripts/install-yay.sh"; fi
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        yay -S --needed --noconfirm "$package"
    done < "$SCRIPT_DIR/aur-packages.list"
}

install_configs() {
    mkdir -p "$HOME/.config"/{hypr,quickshell,rofi,kitty,swaync,gtk-3.0,wkstationz}
    cp -a "$SCRIPT_DIR/configs/hyprland/." "$HOME/.config/hypr/"
    cp "$SCRIPT_DIR/configs/hyprland/$MONITOR_CONFIG" "$HOME/.config/hypr/monitors.lua"
    cp -a "$SCRIPT_DIR/configs/quickshell/." "$HOME/.config/quickshell/"
    cp -a "$SCRIPT_DIR/configs/rofi/." "$HOME/.config/rofi/"
    cp -a "$SCRIPT_DIR/configs/kitty/." "$HOME/.config/kitty/"
    cp -a "$SCRIPT_DIR/configs/swaync/." "$HOME/.config/swaync/"
    cp -a "$SCRIPT_DIR/configs/gtk-3.0/." "$HOME/.config/gtk-3.0/"
    cp -a "$SCRIPT_DIR/scripts" "$HOME/.config/wkstationz/"
    cp -a "$SCRIPT_DIR/themes" "$HOME/.config/wkstationz/"
    cp "$SCRIPT_DIR/VERSION" "$INSTALLED_VERSION_FILE"
    chmod +x "$HOME/.config/rofi/launcher/launcher.sh" "$HOME/.config/wkstationz/scripts/"*.sh
    sed -i "s/kb_layout = .*/kb_layout = $KEYBOARD/" "$HOME/.config/hypr/hyprland.lua"
}

# Preserve local edits in both fresh and reapply/update modes.
for component in hypr quickshell rofi kitty swaync gtk-3.0; do
    backup_configs "$component"
done

install_packages
install_configs
bash "$SCRIPT_DIR/scripts/apply-theme.sh" "$THEME"
bash "$SCRIPT_DIR/scripts/enable-services.sh"

printf '\n%b\n' "${GREEN}wkstationz v$VERSION installed successfully.${NC}"
printf '%s\n' "Machine: $MACHINE_TYPE" "Theme: Catppuccin Mocha" "Keyboard: $KEYBOARD" "Log: $LOG_FILE"
log "Installation completed successfully"
