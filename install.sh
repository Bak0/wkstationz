#!/bin/bash

# Main installer script - version-based, no interactive prompts
# Usage: ./install.sh [OPTIONS]
#
# Options:
#   --desktop          Desktop setup (3 monitors)
#   --laptop           Laptop setup (built-in + external)
#   --catppuccin       Use Catppuccin theme
#   --gruvbox          Use Gruvbox theme
#   --nord             Use Nord theme
#   --tokyo-night      Use Tokyo Night theme
#   --keyboard=XX      Keyboard layout (default: pt)
#   --force-install    Force fresh installation
#   --force-update     Force update installation
#   --help             Show this help

set -e

# Version
VERSION="1.0.0"
INSTALLED_VERSION_FILE="$HOME/.config/wkstationz/VERSION"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Show version immediately
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   wkstationz v$VERSION - Installer     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Parse command-line arguments
MACHINE_TYPE=""
THEME=""
KEYBOARD="pt"
FORCE_MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --desktop)
            MACHINE_TYPE="desktop"
            shift
            ;;
        --laptop)
            MACHINE_TYPE="laptop"
            shift
            ;;
        --catppuccin)
            THEME="catppuccin"
            shift
            ;;
        --gruvbox)
            THEME="gruvbox"
            shift
            ;;
        --nord)
            THEME="nord"
            shift
            ;;
        --tokyo-night)
            THEME="tokyo-night"
            shift
            ;;
        --keyboard=*)
            KEYBOARD="${1#*=}"
            shift
            ;;
        --force-install)
            FORCE_MODE="install"
            shift
            ;;
        --force-update)
            FORCE_MODE="update"
            shift
            ;;
        --help)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --desktop          Desktop setup (3 monitors)"
            echo "  --laptop           Laptop setup (built-in + external)"
            echo "  --catppuccin       Use Catppuccin theme"
            echo "  --gruvbox          Use Gruvbox theme"
            echo "  --nord             Use Nord theme"
            echo "  --tokyo-night      Use Tokyo Night theme"
            echo "  --keyboard=XX      Keyboard layout (default: pt)"
            echo "  --force-install    Force fresh installation"
            echo "  --force-update     Force update installation"
            echo "  --help             Show this help"
            echo ""
            echo "Examples:"
            echo "  ./install.sh --desktop --catppuccin --keyboard=us"
            echo "  ./install.sh --laptop --nord"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$MACHINE_TYPE" ]; then
    echo -e "${RED}Error: Machine type required (--desktop or --laptop)${NC}"
    echo "Use --help for usage information"
    exit 1
fi

if [ -z "$THEME" ]; then
    echo -e "${RED}Error: Theme required (--catppuccin, --gruvbox, --nord, or --tokyo-night)${NC}"
    echo "Use --help for usage information"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging
LOG_FILE="/tmp/wkstationz-install.log"
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
trap 'echo -e "${RED}Error on line $LINENO. Check $LOG_FILE for details.${NC}"' ERR

log "Starting installation v$VERSION"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Do not run this script as root${NC}"
    exit 1
fi

# Request sudo credentials upfront
echo -e "${BLUE}Requesting sudo privileges...${NC}"
if ! sudo -v; then
    echo -e "${RED}Failed to obtain sudo privileges${NC}"
    exit 1
fi

# Keep sudo credentials alive in background
(while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &)

echo -e "${GREEN}✓ Sudo privileges obtained${NC}"
echo ""

# Determine install mode based on version
INSTALL_MODE=""

if [ -n "$FORCE_MODE" ]; then
    INSTALL_MODE="$FORCE_MODE"
    echo -e "${YELLOW}Force mode: $INSTALL_MODE${NC}"
elif [ -f "$INSTALLED_VERSION_FILE" ]; then
    INSTALLED_VERSION=$(cat "$INSTALLED_VERSION_FILE")
    echo -e "${BLUE}Detected installed version: $INSTALLED_VERSION${NC}"
    
    if [ "$INSTALLED_VERSION" = "$VERSION" ]; then
        echo -e "${YELLOW}Same version detected. Use --force-update to update configs.${NC}"
        echo -e "${YELLOW}Use --force-install for fresh installation.${NC}"
        exit 0
    else
        # Compare versions (simple string comparison for now)
        if [ "$VERSION" \> "$INSTALLED_VERSION" ]; then
            echo -e "${GREEN}New version available: $VERSION > $INSTALLED_VERSION${NC}"
            INSTALL_MODE="update"
        else
            echo -e "${YELLOW}Installed version is newer: $INSTALLED_VERSION > $VERSION${NC}"
            echo -e "${YELLOW}Use --force-install to downgrade.${NC}"
            exit 0
        fi
    fi
else
    echo -e "${GREEN}No existing installation detected${NC}"
    INSTALL_MODE="install"
fi

echo ""
echo -e "${BLUE}Installation mode: $INSTALL_MODE${NC}"
echo -e "${BLUE}Machine type: $MACHINE_TYPE${NC}"
echo -e "${BLUE}Theme: $THEME${NC}"
echo -e "${BLUE}Keyboard: $KEYBOARD${NC}"
echo ""

# Set monitor config based on machine type
if [ "$MACHINE_TYPE" = "desktop" ]; then
    MONITOR_CONFIG="monitors-desktop.lua"
else
    MONITOR_CONFIG="monitors-laptop.lua"
fi

# Function to backup existing configs
backup_configs() {
    local config_name=$1
    local config_path="$HOME/.config/$config_name"
    
    if [ -d "$config_path" ]; then
        BACKUP_DIR="$config_path.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backing up existing $config_name config to $BACKUP_DIR"
        cp -r "$config_path" "$BACKUP_DIR"
        echo -e "${GREEN}✓ Backed up existing $config_name config${NC}"
    fi
}

# Function to install a package if not already installed
install_package() {
    local package=$1
    if pacman -Q "$package" &>/dev/null; then
        log "$package already installed, skipping"
    else
        log "Installing $package"
        sudo pacman -S --noconfirm --needed "$package"
    fi
}

# Function to install AUR package if not already installed
install_aur_package() {
    local package=$1
    if pacman -Q "$package" &>/dev/null; then
        log "$package already installed from AUR, skipping"
    else
        log "Installing $package from AUR"
        yay -S --noconfirm --needed "$package"
    fi
}

# Function to install packages
install_packages() {
    echo -e "${YELLOW}=== Installing Packages ===${NC}"
    echo ""
    
    # Update system
    echo -e "${BLUE}Updating system...${NC}"
    sudo pacman -Syu --noconfirm
    
    # Install base packages
    echo -e "${BLUE}Installing base packages...${NC}"
    while IFS= read -r package; do
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue
        install_package "$package"
    done < "$SCRIPT_DIR/packages.list"
    
    # Install yay (AUR helper) if not present
    if ! command -v yay &> /dev/null; then
        echo -e "${BLUE}Installing yay (AUR helper)...${NC}"
        bash "$SCRIPT_DIR/scripts/install-yay.sh"
    fi
    
    # Install AUR packages
    echo -e "${BLUE}Installing AUR packages...${NC}"
    while IFS= read -r package; do
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue
        install_aur_package "$package"
    done < "$SCRIPT_DIR/aur-packages.list"
    
    log "Packages installed"
}

# Function to install configs
install_configs() {
    echo -e "${YELLOW}=== Installing Configurations ===${NC}"
    echo ""
    
    mkdir -p ~/.config/{hypr,quickshell,rofi,kitty,swaync,gtk-3.0,wkstationz}
    
    echo -e "${BLUE}Installing Hyprland config...${NC}"
    cp -r "$SCRIPT_DIR/configs/hyprland/"* ~/.config/hypr/
    cp "$SCRIPT_DIR/configs/hyprland/$MONITOR_CONFIG" ~/.config/hypr/monitors.lua
    log "Hyprland config installed"
    
    echo -e "${BLUE}Installing Quickshell config...${NC}"
    cp -r "$SCRIPT_DIR/configs/quickshell/"* ~/.config/quickshell/
    log "Quickshell config installed"
    
    echo -e "${BLUE}Installing Rofi config...${NC}"
    cp -r "$SCRIPT_DIR/configs/rofi/"* ~/.config/rofi/
    log "Rofi config installed"
    
    echo -e "${BLUE}Installing Kitty config...${NC}"
    cp -r "$SCRIPT_DIR/configs/kitty/"* ~/.config/kitty/
    log "Kitty config installed"
    
    echo -e "${BLUE}Installing swaync config...${NC}"
    cp -r "$SCRIPT_DIR/configs/swaync/"* ~/.config/swaync/
    log "swaync config installed"
    
    echo -e "${BLUE}Installing GTK config...${NC}"
    cp -r "$SCRIPT_DIR/configs/gtk-3.0/"* ~/.config/gtk-3.0/
    log "GTK config installed"
    
    echo -e "${BLUE}Installing helper scripts...${NC}"
    cp -r "$SCRIPT_DIR/scripts/"* ~/.config/wkstationz/
    chmod +x ~/.config/wkstationz/*.sh
    log "Helper scripts installed"
    
    echo -e "${BLUE}Installing themes...${NC}"
    cp -r "$SCRIPT_DIR/themes" ~/.config/wkstationz/
    log "Themes installed"
}

# Function to apply theme
apply_theme() {
    echo ""
    echo -e "${YELLOW}=== Applying Theme ===${NC}"
    echo ""
    bash "$SCRIPT_DIR/scripts/apply-theme.sh" "$THEME"
    log "Theme applied: $THEME"
}

# Function to configure keyboard layout
configure_keyboard() {
    echo -e "${BLUE}Setting keyboard layout to: $KEYBOARD${NC}"
    sed -i "s/kb_layout = .*/kb_layout = $KEYBOARD/" ~/.config/hypr/hyprland.lua
    log "Keyboard layout set to: $KEYBOARD"
}

# Function to enable services
enable_services() {
    echo ""
    echo -e "${YELLOW}=== Enabling Services ===${NC}"
    echo ""
    bash "$SCRIPT_DIR/scripts/enable-services.sh"
    log "Services enabled"
}

# Function to save version
save_version() {
    mkdir -p "$HOME/.config/wkstationz"
    echo "$VERSION" > "$INSTALLED_VERSION_FILE"
    log "Saved version $VERSION to $INSTALLED_VERSION_FILE"
}

# Execute installation
if [ "$INSTALL_MODE" = "install" ]; then
    echo -e "${YELLOW}=== Fresh Installation ===${NC}"
    echo ""
    
    # Backup existing configs
    echo -e "${YELLOW}=== Backing Up Existing Configs ===${NC}"
    echo ""
    backup_configs "hypr"
    backup_configs "quickshell"
    backup_configs "rofi"
    backup_configs "kitty"
    backup_configs "swaync"
    backup_configs "gtk-3.0"
    echo ""
    
    install_packages
    install_configs
    apply_theme
    configure_keyboard
    enable_services
    save_version
    
elif [ "$INSTALL_MODE" = "update" ]; then
    echo -e "${YELLOW}=== Updating Installation ===${NC}"
    echo ""
    
    # Backup existing configs
    echo -e "${YELLOW}=== Backing Up Existing Configs ===${NC}"
    echo ""
    backup_configs "hypr"
    backup_configs "quickshell"
    backup_configs "rofi"
    backup_configs "kitty"
    backup_configs "swaync"
    backup_configs "gtk-3.0"
    echo ""
    
    install_packages
    install_configs
    apply_theme
    configure_keyboard
    enable_services
    save_version
fi

chmod +x ~/.config/rofi/launcher/launcher.sh 2>/dev/null || true

# Completion message
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Installation Complete!          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}What's installed:${NC}"
echo "  • Hyprland (Wayland compositor)"
echo "  • Quickshell (status bar)"
echo "  • Rofi (app launcher)"
echo "  • Kitty (terminal)"
echo "  • Thunar (file manager)"
echo "  • Brave (browser)"
echo "  • PulseAudio (sound)"
echo "  • Theme: $THEME"
echo "  • Version: $VERSION"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Reboot your system"
echo "  2. Select 'Hyprland' at the SDDM login screen"
echo "  3. Log in with your password"
echo ""
echo -e "${BLUE}Keybinds:${NC}"
echo "  Super+T      Terminal"
echo "  Super+B      Browser"
echo "  Super+E      File manager"
echo "  Super+Space  App launcher"
echo "  Super+L      Lock screen"
echo "  Super+F1     Show all keybinds"
echo ""
echo -e "${GREEN}Log file saved to: $LOG_FILE${NC}"
echo -e "${GREEN}Enjoy your new setup!${NC}"

log "Installation completed successfully"
