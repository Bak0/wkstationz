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

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Arch Setup - Desktop Installer     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

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

# Interactive prompts
echo -e "${YELLOW}=== Configuration ===${NC}"
echo ""

# Machine type
echo -e "${BLUE}Select machine type:${NC}"
echo "1) Desktop (3 monitors)"
echo "2) Laptop (built-in + external)"
read -p "Enter choice [1-2]: " MACHINE_TYPE < /dev/tty

case $MACHINE_TYPE in
    1) MONITOR_CONFIG="monitors-desktop.lua" ;;
    2) MONITOR_CONFIG="monitors-laptop.lua" ;;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
esac

# Color theme
echo ""
echo -e "${BLUE}Select color theme:${NC}"
echo "1) Catppuccin Mocha (purple/blue)"
echo "2) Gruvbox Dark (warm retro)"
echo "3) Nord (cool blue-gray)"
echo "4) Tokyo Night (modern dark blue)"
read -p "Enter choice [1-4]: " THEME_CHOICE < /dev/tty

case $THEME_CHOICE in
    1) THEME="catppuccin" ;;
    2) THEME="gruvbox" ;;
    3) THEME="nord" ;;
    4) THEME="tokyo-night" ;;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
esac

# Keyboard layout
echo ""
read -p "Keyboard layout [default: pt]: " KEYBOARD_LAYOUT < /dev/tty
KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-pt}

echo ""
echo -e "${GREEN}Configuration saved:${NC}"
echo "  Machine: $MACHINE_TYPE"
echo "  Theme: $THEME"
echo "  Keyboard: $KEYBOARD_LAYOUT"
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
    
    echo -e "  Installing ${GREEN}$package${NC}..."
    sudo pacman -S --noconfirm --needed "$package"
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
    
    echo -e "  Installing ${GREEN}$package${NC} from AUR..."
    yay -S --noconfirm --needed "$package"
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

# Copy Quickshell config
echo -e "${BLUE}Installing Quickshell config...${NC}"
cp -r "$SCRIPT_DIR/configs/quickshell/"* ~/.config/quickshell/

# Copy Rofi config
echo -e "${BLUE}Installing Rofi config...${NC}"
cp -r "$SCRIPT_DIR/configs/rofi/"* ~/.config/rofi/

# Copy Kitty config
echo -e "${BLUE}Installing Kitty config...${NC}"
cp -r "$SCRIPT_DIR/configs/kitty/"* ~/.config/kitty/

# Copy swaync config
echo -e "${BLUE}Installing swaync config...${NC}"
cp -r "$SCRIPT_DIR/configs/swaync/"* ~/.config/swaync/

# Copy GTK config
echo -e "${BLUE}Installing GTK config...${NC}"
cp -r "$SCRIPT_DIR/configs/gtk-3.0/"* ~/.config/gtk-3.0/

# Apply theme
echo ""
echo -e "${YELLOW}=== Applying Theme ===${NC}"
echo ""
bash "$SCRIPT_DIR/scripts/apply-theme.sh" "$THEME"

# Update keyboard layout in Hyprland config
echo -e "${BLUE}Setting keyboard layout to: $KEYBOARD_LAYOUT${NC}"
sed -i "s/kb_layout = .*/kb_layout = $KEYBOARD_LAYOUT/" ~/.config/hypr/hyprland.lua

# Enable services
echo ""
echo -e "${YELLOW}=== Enabling Services ===${NC}"
echo ""
bash "$SCRIPT_DIR/scripts/enable-services.sh"

# Make scripts executable
chmod +x ~/.config/rofi/launcher/launcher.sh 2>/dev/null || true

# Cleanup temp directory if we created one
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    echo ""
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
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
echo -e "${GREEN}Enjoy your new setup!${NC}"
