#!/bin/bash

# Arch Setup - Automated Arch Linux Desktop Installer
# Repository: https://github.com/Bak0/wkstationz
# Usage: curl -fsSL https://raw.githubusercontent.com/Bak0/wkstationz/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
LOG_FILE="/tmp/wkstationz-install.log"
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
trap 'echo -e "${RED}Error on line $LINENO. Check $LOG_FILE for details.${NC}"' ERR

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Arch Setup - Desktop Installer     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

log "Starting installation"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Do not run this script as root${NC}"
    echo "Please run as a normal user"
    exit 1
fi

# Detect if script is being piped and download if necessary
if [ ! -t 0 ] || [ "${BASH_SOURCE[0]}" = "/dev/stdin" ] || [ "${BASH_SOURCE[0]}" = "/proc/self/fd/0" ]; then
    echo -e "${BLUE}Detected piped installation, downloading repository...${NC}"
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Git not found, installing...${NC}"
        sudo pacman -S --noconfirm git
    fi
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone https://github.com/Bak0/wkstationz.git .
    SCRIPT_DIR="$TEMP_DIR"
    echo -e "${GREEN}Repository downloaded to $TEMP_DIR${NC}"
    echo ""
else
    # Get script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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

# Function to get user input with validation
get_input() {
    local prompt=$1
    local default=$2
    local input
    
    while true; do
        echo -n -e "${BLUE}$prompt${NC}"
        if [ -n "$default" ]; then
            echo -n -e " [${YELLOW}$default${NC}]: "
        else
            echo -n ": "
        fi
        
        # Read from terminal
        read input < /dev/tty
        
        # Trim whitespace
        input=$(echo "$input" | tr -d '[:space:]')
        
        # Use default if empty
        if [ -z "$input" ] && [ -n "$default" ]; then
            input="$default"
        fi
        
        # Return input
        if [ -n "$input" ]; then
            echo "$input"
            return 0
        fi
    done
}

# Function to get menu choice
get_menu_choice() {
    local prompt=$1
    local min=$2
    local max=$3
    local choice
    
    while true; do
        choice=$(get_input "$prompt" "")
        
        # Validate it's a number in range
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge "$min" ] && [ "$choice" -le "$max" ]; then
            echo "$choice"
            return 0
        else
            echo -e "${RED}Invalid choice. Please enter a number between $min and $max${NC}"
        fi
    done
}

# Interactive prompts
echo -e "${YELLOW}=== Configuration ===${NC}"
echo ""

# Machine type
echo -e "${BLUE}Select machine type:${NC}"
echo "1) Desktop (3 monitors)"
echo "2) Laptop (built-in + external)"
MACHINE_TYPE=$(get_menu_choice "Enter choice" 1 2)

case $MACHINE_TYPE in
    1) MONITOR_CONFIG="monitors-desktop.lua" ;;
    2) MONITOR_CONFIG="monitors-laptop.lua" ;;
esac

# Color theme
echo ""
echo -e "${BLUE}Select color theme:${NC}"
echo "1) Catppuccin Mocha (purple/blue)"
echo "2) Gruvbox Dark (warm retro)"
echo "3) Nord (cool blue-gray)"
echo "4) Tokyo Night (modern dark blue)"
THEME_CHOICE=$(get_menu_choice "Enter choice" 1 4)

case $THEME_CHOICE in
    1) THEME="catppuccin" ;;
    2) THEME="gruvbox" ;;
    3) THEME="nord" ;;
    4) THEME="tokyo-night" ;;
esac

# Keyboard layout
echo ""
KEYBOARD_LAYOUT=$(get_input "Keyboard layout" "pt")

echo ""
echo -e "${GREEN}Configuration saved:${NC}"
echo "  Machine: $MACHINE_TYPE"
echo "  Theme: $THEME"
echo "  Keyboard: $KEYBOARD_LAYOUT"
echo ""

log "Configuration: Machine=$MACHINE_TYPE, Theme=$THEME, Keyboard=$KEYBOARD_LAYOUT"

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

# Install packages
echo -e "${YELLOW}=== Installing Packages ===${NC}"
echo ""

# Update system
echo -e "${BLUE}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# Install base packages
echo -e "${BLUE}Installing base packages...${NC}"
while IFS= read -r package; do
    # Skip comments and empty lines
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

# Copy configurations
echo ""
echo -e "${YELLOW}=== Installing Configurations ===${NC}"
echo ""

# Create config directories
echo -e "${BLUE}Creating config directories...${NC}"
mkdir -p ~/.config/{hypr,quickshell,rofi,kitty,swaync,gtk-3.0}

# Copy Hyprland config
echo -e "${BLUE}Installing Hyprland config...${NC}"
cp -r "$SCRIPT_DIR/configs/hyprland/"* ~/.config/hypr/
cp "$SCRIPT_DIR/configs/hyprland/$MONITOR_CONFIG" ~/.config/hypr/monitors.lua
log "Hyprland config installed"

# Copy Quickshell config
echo -e "${BLUE}Installing Quickshell config...${NC}"
cp -r "$SCRIPT_DIR/configs/quickshell/"* ~/.config/quickshell/
log "Quickshell config installed"

# Copy Rofi config
echo -e "${BLUE}Installing Rofi config...${NC}"
cp -r "$SCRIPT_DIR/configs/rofi/"* ~/.config/rofi/
log "Rofi config installed"

# Copy Kitty config
echo -e "${BLUE}Installing Kitty config...${NC}"
cp -r "$SCRIPT_DIR/configs/kitty/"* ~/.config/kitty/
log "Kitty config installed"

# Copy swaync config
echo -e "${BLUE}Installing swaync config...${NC}"
cp -r "$SCRIPT_DIR/configs/swaync/"* ~/.config/swaync/
log "swaync config installed"

# Copy GTK config
echo -e "${BLUE}Installing GTK config...${NC}"
cp -r "$SCRIPT_DIR/configs/gtk-3.0/"* ~/.config/gtk-3.0/
log "GTK config installed"

# Apply theme
echo ""
echo -e "${YELLOW}=== Applying Theme ===${NC}"
echo ""
bash "$SCRIPT_DIR/scripts/apply-theme.sh" "$THEME"
log "Theme applied: $THEME"

# Update keyboard layout in Hyprland config
echo -e "${BLUE}Setting keyboard layout to: $KEYBOARD_LAYOUT${NC}"
sed -i "s/kb_layout = .*/kb_layout = $KEYBOARD_LAYOUT/" ~/.config/hypr/hyprland.lua
log "Keyboard layout set to: $KEYBOARD_LAYOUT"

# Enable services
echo ""
echo -e "${YELLOW}=== Enabling Services ===${NC}"
echo ""
bash "$SCRIPT_DIR/scripts/enable-services.sh"
log "Services enabled"

# Make scripts executable
chmod +x ~/.config/rofi/launcher/launcher.sh 2>/dev/null || true

# Cleanup temp directory if we created one
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    echo ""
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
    log "Cleaned up temp directory"
fi

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
