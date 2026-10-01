#!/usr/bin/env bash
set -Eeuo pipefail

readonly REPO="Bak0/wkstationz"
readonly RAW="https://raw.githubusercontent.com/${REPO}/main"
readonly ARCHIVE="https://github.com/${REPO}/archive/refs/heads/main.tar.gz"
readonly VERSION_FILE="$HOME/.config/wkstationz/VERSION"
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
WORK_DIR=""
cleanup() {
    if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
        rm -rf -- "$WORK_DIR"
    fi
}
trap cleanup EXIT
fail() { printf '%b\n' "${RED}Error: $*${NC}" >&2; exit 1; }

# Open the controlling terminal explicitly. stdin remains free for curl/bash.
if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    fail "No interactive terminal found. Run this command from a terminal session."
fi

VERSION=$(curl -fsSL --retry 2 "$RAW/VERSION" | tr -d '\r\n') || fail "Could not fetch the published VERSION file."
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Invalid published version '$VERSION'."
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

installed=""
[[ -f "$VERSION_FILE" ]] && IFS= read -r installed < "$VERSION_FILE" || true
if [[ -z "$installed" ]]; then
    printf '%s\n' "No installed version found." "1) Install" "2) Update/reapply setup" "3) Exit" >/dev/tty
    prompt_choice "Choose [1-3]: " '^[1-3]$'
    case "$REPLY" in 1) mode=install ;; 2) mode=update ;; 3) exit 0 ;; esac
elif [[ "$VERSION" == "$installed" ]]; then
    printf 'Installed version %s is current.\n' "$installed" >/dev/tty
    printf '%s\n' "1) Update/reapply setup" "2) Exit" >/dev/tty
    prompt_choice "Choose [1-2]: " '^[1-2]$'
    [[ "$REPLY" == 1 ]] || exit 0
    mode=update
elif [[ "$(printf '%s\n' "$installed" "$VERSION" | sort -V | tail -n1)" == "$VERSION" ]]; then
    printf 'New version %s found (installed: %s); updating.\n' "$VERSION" "$installed"
    mode=update
else
    printf 'Installed version %s is newer than %s.\n' "$installed" "$VERSION" >/dev/tty
    printf '%s\n' "1) Reinstall/downgrade" "2) Exit" >/dev/tty
    prompt_choice "Choose [1-2]: " '^[1-2]$'
    [[ "$REPLY" == 1 ]] || exit 0
    mode=install
fi

printf '\nRequesting administrator privileges...\n'
sudo -k
sudo -v <&3 || fail "Could not obtain sudo privileges."

WORK_DIR=$(mktemp -d /tmp/wkstationz.XXXXXX)
mkdir "$WORK_DIR/repo"
printf 'Downloading wkstationz %s into %s...\n' "$VERSION" "$WORK_DIR"
curl -fLsS --retry 2 "$ARCHIVE" -o "$WORK_DIR/source.tar.gz" || fail "Could not download repository archive."
tar -xzf "$WORK_DIR/source.tar.gz" --strip-components=1 -C "$WORK_DIR/repo" || fail "Could not unpack repository archive."
[[ -f "$WORK_DIR/repo/install.sh" && -f "$WORK_DIR/repo/packages.list" ]] || fail "Repository archive is incomplete; required files are missing."
for required in \
    VERSION packages.list aur-packages.list \
    scripts/install-yay.sh scripts/apply-theme.sh scripts/enable-services.sh \
    configs/hyprland/hyprland.lua configs/hyprland/keybinds.lua \
    configs/hyprland/monitors-desktop.lua configs/hyprland/monitors-laptop.lua \
    configs/quickshell/config.qml configs/quickshell/Bar.qml configs/quickshell/SettingsPanel.qml \
    configs/rofi/launcher/launcher.sh configs/kitty/kitty.conf \
    configs/swaync/config.json configs/gtk-3.0/settings.ini; do
    [[ -f "$WORK_DIR/repo/$required" ]] || fail "Published repository is incomplete: missing $required. Commit/push the complete project before installing."
done
[[ "$(cat "$WORK_DIR/repo/VERSION")" == "$VERSION" ]] || fail "Downloaded repository version does not match VERSION endpoint."

WKSTATIONZ_MODE="$mode" WKSTATIONZ_WORK_DIR="$WORK_DIR/repo" WKSTATIONZ_SUDO_READY=1 \
    bash "$WORK_DIR/repo/install.sh" 3<&3
