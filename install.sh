#!/usr/bin/env bash
set -Eeuo pipefail

readonly REPO="Bak0/wkstationz"
readonly RAW="https://raw.githubusercontent.com/${REPO}/main"
readonly ARCHIVE="https://github.com/${REPO}/archive/refs/heads/main.tar.gz"
readonly INSTALLED_VERSION_FILE="$HOME/.config/wkstationz/VERSION"
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'

WORK_DIR=""
CLEAN_WORK_DIR=0
SUDO_KEEPALIVE_PID=""
LOG_FILE="/tmp/wkstationz-install.log"

fail() { printf '%b\n' "${RED}Error: $*${NC}" >&2; exit 1; }
warn() { printf '%b\n' "${YELLOW}  ! $*${NC}" >&2; }
ok()   { printf '%b\n' "${GREEN}  + $*${NC}"; }

cleanup() {
    if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
    if [[ "$CLEAN_WORK_DIR" == 1 && -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
        rm -rf -- "$WORK_DIR"
    fi
}
trap cleanup EXIT

if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    fail "No interactive terminal found. Run from a terminal session."
fi

prompt_choice() {
    local prompt="$1" allowed="$2" answer
    while true; do
        printf '%s' "$prompt" >/dev/tty
        IFS= read -r -u 3 answer || fail "Terminal input closed while waiting for a choice."
        answer="${answer//[[:space:]]/}"
        if [[ "$answer" =~ $allowed ]]; then
            REPLY="$answer"
            return
        fi
        printf '%b\n' "${YELLOW}Please enter one of the listed choices.${NC}" >/dev/tty
    done
}

log() { printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$1" | tee -a "$LOG_FILE"; }

download_repository() {
    WORK_DIR=$(mktemp -d /tmp/wkstationz.XXXXXX)
    CLEAN_WORK_DIR=1
    mkdir "$WORK_DIR/repo"
    printf 'Downloading wkstationz into %s...\n' "$WORK_DIR"
    curl -fLsS --retry 2 "$ARCHIVE" -o "$WORK_DIR/source.tar.gz" || fail "Could not download repository archive."
    tar -xzf "$WORK_DIR/source.tar.gz" --strip-components=1 -C "$WORK_DIR/repo" || fail "Could not unpack repository archive."
    rm -f "$WORK_DIR/source.tar.gz"
    SCRIPT_DIR="$WORK_DIR/repo"
}

# Establish source directory.
if [[ -n "${WKSTATIONZ_WORK_DIR:-}" ]]; then
    SCRIPT_DIR="$WKSTATIONZ_WORK_DIR"
elif [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SOURCE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    if [[ -f "$SOURCE_DIR/packages.list" && -f "$SOURCE_DIR/VERSION" ]]; then
        WORK_DIR=$(mktemp -d /tmp/wkstationz.XXXXXX)
        CLEAN_WORK_DIR=1
        cp -a "$SOURCE_DIR"/. "$WORK_DIR"/
        SCRIPT_DIR="$WORK_DIR"
    else
        download_repository
    fi
else
    download_repository
fi

for required in \
    VERSION packages.list aur-packages.list \
    scripts/install-yay.sh scripts/apply-theme.sh scripts/enable-services.sh \
    configs/hyprland/keybinds.lua \
    configs/hyprland/monitors-desktop.lua configs/hyprland/monitors-laptop.lua \
    configs/quickshell/shell.qml \
    configs/rofi/launcher/launcher.sh configs/kitty/kitty.conf \
    configs/swaync/config.json configs/gtk-3.0/settings.ini; do
    [[ -f "$SCRIPT_DIR/$required" ]] || fail "Repository is incomplete: missing $required"
done

VERSION=$(tr -d '\r\n[:space:]' < "$SCRIPT_DIR/VERSION")
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Invalid VERSION: '$VERSION'."
printf '%b\n' "${BLUE}wkstationz v$VERSION${NC}"

validate_lua() {
    if ! command -v luac >/dev/null 2>&1; then
        printf '\nInstalling lua to validate Hyprland configuration...\n'
        sudo pacman -S --needed --noconfirm lua || fail "Could not install lua for configuration validation."
    fi

    local file
    for file in "$SCRIPT_DIR"/configs/hyprland/*.lua; do
        [[ -f "$file" ]] || continue
        luac -p "$file" || fail "Invalid Lua syntax in $file. Fix it before installing."
    done
    log "Validated Hyprland Lua configuration"
}

INSTALL_MODE="${WKSTATIONZ_MODE:-}"
if [[ -z "$INSTALL_MODE" ]]; then
    installed=""
    [[ -f "$INSTALLED_VERSION_FILE" ]] && IFS= read -r installed < "$INSTALLED_VERSION_FILE" || true
    if [[ -z "$installed" ]]; then
        printf '%s\n' "No installed version found." "1) Install" "2) Update/reapply setup" "3) Exit" >/dev/tty
        prompt_choice "Choose [1-3]: " '^[1-3]$'
        case "$REPLY" in
            1) INSTALL_MODE=install ;;
            2) INSTALL_MODE=update ;;
            3) exit 0 ;;
        esac
    elif [[ "$installed" == "$VERSION" ]]; then
        printf 'Installed version %s is current.\n' "$installed" >/dev/tty
        printf '%s\n' "1) Update/reapply setup" "2) Exit" >/dev/tty
        prompt_choice "Choose [1-2]: " '^[1-2]$'
        [[ "$REPLY" == 1 ]] || exit 0
        INSTALL_MODE=update
    elif [[ "$(printf '%s\n' "$installed" "$VERSION" | sort -V | tail -n1)" == "$VERSION" ]]; then
        printf 'New version %s found (installed: %s); updating.\n' "$VERSION" "$installed"
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

(while sleep 45; do sudo -n -v 2>/dev/null || exit; done) >/dev/null 2>&1 &
SUDO_KEEPALIVE_PID=$!

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

log "Starting v$VERSION ($INSTALL_MODE, $MACHINE_TYPE)"
validate_lua

backup_configs() {
    local name="$1" path="$HOME/.config/$1"
    if [[ -d "$path" ]]; then
        local backup="$path.backup.$(date +%Y%m%d_%H%M%S)"
        cp -a -- "$path" "$backup"
        printf 'Backed up %s to %s\n' "$name" "$backup"
        log "Backed up $name to $backup"
    fi
}

install_packages() {
    printf '\nInstalling/updating packages...\n'
    local failures=()

    # A refresh failure must not abort the install; per-package reporting below
    # covers anything that is genuinely unavailable.
    if ! sudo pacman -Syu --needed --noconfirm; then
        warn "system update reported errors; continuing with package lists"
    fi

    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        if ! sudo pacman -S --needed --noconfirm "$package"; then
            warn "failed to install '$package'"
            failures+=("$package")
        fi
    done < "$SCRIPT_DIR/packages.list"

    if ! command -v yay >/dev/null 2>&1; then
        bash "$SCRIPT_DIR/scripts/install-yay.sh"
    fi

    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] && continue
        if ! yay -S --needed --noconfirm "$package"; then
            warn "failed to install '$package' from AUR"
            failures+=("$package")
        fi
    done < "$SCRIPT_DIR/aur-packages.list"

    if [ "${#failures[@]}" -gt 0 ]; then
        warn "${#failures[@]} package(s) failed: ${failures[*]}"
        warn "re-run the installer to retry, or install them manually"
    else
        ok "all packages installed"
    fi
}

install_configs() {
    mkdir -p "$HOME/.config"/{hypr,quickshell,rofi,kitty,swaync,gtk-3.0,wkstationz}

    # Copy monitor configuration
    cp "$SCRIPT_DIR/configs/hyprland/$MONITOR_CONFIG" "$HOME/.config/hypr/monitors.lua"
    log "Copied monitor configuration"

    # Copy custom keybinds overlay (if illogical-impulse is installed, this goes to custom/)
    if [[ -d "$HOME/.config/hypr/hyprland" ]]; then
        # illogical-impulse structure detected - overlay to custom/
        mkdir -p "$HOME/.config/hypr/custom"
        cp "$SCRIPT_DIR/configs/hyprland/keybinds.lua" "$HOME/.config/hypr/custom/keybinds.lua"
        log "Overlayed custom keybinds to illogical-impulse structure"
    else
        # Standalone Hyprland - copy directly
        cp "$SCRIPT_DIR/configs/hyprland/keybinds.lua" "$HOME/.config/hypr/keybinds.lua"
        log "Copied standalone keybinds"
    fi

    # Copy other configs
    cp -a "$SCRIPT_DIR/configs/quickshell/." "$HOME/.config/quickshell/"
    cp -a "$SCRIPT_DIR/configs/rofi/." "$HOME/.config/rofi/"
    cp -a "$SCRIPT_DIR/configs/kitty/." "$HOME/.config/kitty/"
    cp -a "$SCRIPT_DIR/configs/swaync/." "$HOME/.config/swaync/"
    cp -a "$SCRIPT_DIR/configs/gtk-3.0/." "$HOME/.config/gtk-3.0/"
    cp -a "$SCRIPT_DIR/scripts" "$HOME/.config/wkstationz/"
    cp -a "$SCRIPT_DIR/themes" "$HOME/.config/wkstationz/"
    cp "$SCRIPT_DIR/VERSION" "$INSTALLED_VERSION_FILE"

    chmod +x "$HOME/.config/rofi/launcher/launcher.sh" "$HOME/.config/wkstationz/scripts/"*.sh

    # Update keyboard layout in the appropriate location
    if [[ -d "$HOME/.config/hypr/hyprland" ]]; then
        # illogical-impulse: update in general.lua
        if [[ -f "$HOME/.config/hypr/hyprland/general.lua" ]]; then
            sed -i "s/kb_layout = \"[^\"]*\"/kb_layout = \"$KEYBOARD\"/" "$HOME/.config/hypr/hyprland/general.lua"
            log "Updated keyboard layout in illogical-impulse general.lua"
        fi
    else
        # Standalone: update in hyprland.lua if it exists
        if [[ -f "$HOME/.config/hypr/hyprland.lua" ]]; then
            sed -i "s/kb_layout = \"[^\"]*\"/kb_layout = \"$KEYBOARD\"/" "$HOME/.config/hypr/hyprland.lua"
            log "Updated keyboard layout in standalone hyprland.lua"
        fi
    fi

    # Validate monitor config
    luac -p "$HOME/.config/hypr/monitors.lua" || fail "Monitor configuration failed validation."
    log "Validated monitor configuration"
}

for component in hypr quickshell rofi kitty swaync gtk-3.0; do
    backup_configs "$component"
done

install_packages
install_configs
bash "$SCRIPT_DIR/scripts/apply-theme.sh" "$THEME"
bash "$SCRIPT_DIR/scripts/enable-services.sh"

printf '\n%b\n' "${GREEN}wkstationz v$VERSION installed successfully.${NC}"
printf '%s\n' \
    "Machine: $MACHINE_TYPE" \
    "Theme: Catppuccin Mocha" \
    "Keyboard: $KEYBOARD" \
    "Log: $LOG_FILE"

cat <<BANNER

$(printf '%b' "${GREEN}${BLUE}========================================${NC}")
$(printf '%b' "${GREEN}   Reboot to apply and start the desktop. ${NC}")
$(printf '%b' "${GREEN}${BLUE}========================================${NC}")

BANNER

log "Installation completed successfully"
