#!/bin/bash

# Arch Setup - Automated Arch Linux Desktop Installer
# Repository: https://github.com/Bak0/wkstationz
# Usage: curl -fsSL https://raw.githubusercontent.com/Bak0/wkstationz/main/install.sh | bash
# Or: git clone https://github.com/Bak0/wkstationz.git && cd wkstationz && ./install.sh

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

# Check if running from downloaded location, if not, download and re-execute
if [ -z "$WKSTATIONZ_DOWNLOADED" ]; then
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Arch Setup - Desktop Installer     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Git not found, installing...${NC}"
        sudo pacman -S --noconfirm git
    fi
    
    # Download repository
    TEMP_DIR=$(mktemp -d)
    echo -e "${BLUE}Downloading repository to $TEMP_DIR...${NC}"
    git clone https://github.com/Bak0/wkstationz.git "$TEMP_DIR"
    
    # Re-execute from downloaded location
    export WKSTATIONZ_DOWNLOADED=1
    export WKSTATIONZ_DIR="$TEMP_DIR"
    exec "$TEMP_DIR/install.sh"
fi

# Now we're running from the downloaded/cloned location
SCRIPT_DIR="${WKSTATIONZ_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Arch Setup - Desktop Installer     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

log "Starting installation from $SCRIPT_DIR"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Do not run this script as root${NC}"
    echo "Please run as a normal user"
    exit 1
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

# Function to detect existing installation
detect_existing_install() {
    if [ -d "$HOME/.config/hypr" ] && [ -d "$HOME/.config/quickshell" ]; then
        return 0  # Installation exists
    else
        return 1  # No installation
    fi
}

# Function to get current theme from existing config
get_current_theme() {
    if [ -f "$HOME/.config/quickshell/theme.conf" ]; then
        local bg_color=$(grep "background = " "$HOME/.config/quickshell/theme.conf" | cut -d'=' -f2 | tr -d ' ')
        case "$bg_color" in
            "#1e1e2e") echo "catppuccin" ;;
            "#282828") echo "gruvbox" ;;
            "#2e3440") echo "nord" ;;
            "#1a1b26") echo "tokyo-night" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
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
    
    mkdir -p ~/.config/{hypr,quickshell,rofi,kitty,swaync,gtk-3.0}
    
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
    echo -e "${BLUE}Setting keyboard layout to: $KEYBOARD_LAYOUT${NC}"
    sed -i "s/kb_layout = .*/kb_layout = $KEYBOARD_LAYOUT/" ~/.config/hypr/hyprland.lua
    log "Keyboard layout set to: $KEYBOARD_LAYOUT"
}

# Function to enable services
enable_services() {
    echo ""
    echo -e "${YELLOW}=== Enabling Services ===${NC}"
    echo ""
    bash "$SCRIPT_DIR/scripts/enable-services.sh"
    log "Services enabled"
}

# Function for fresh installation
fresh_install() {
    log "Starting fresh installation"
    
    echo -e "${YELLOW}=== Configuration ===${NC}"
    echo ""
    
    # Machine type
    echo -e "${BLUE}Select machine type:${NC}"
    echo "1) Desktop (3 monitors)"
    echo "2) Laptop (built-in + external)"
    read -p "Enter choice [1-2]: " MACHINE_TYPE
    
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
    read -p "Enter choice [1-4]: " THEME_CHOICE
    
    case $THEME_CHOICE in
        1) THEME="catppuccin" ;;
        2) THEME="gruvbox" ;;
        3) THEME="nord" ;;
        4) THEME="tokyo-night" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
    
    # Keyboard layout
    echo ""
    read -p "Keyboard layout [default: pt]: " KEYBOARD_LAYOUT
    KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-pt}
    
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
    
    install_packages
    install_configs
    apply_theme
    configure_keyboard
    enable_services
    
    chmod +x ~/.config/rofi/launcher/launcher.sh 2>/dev/null || true
}

# Function for update installation
update_install() {
    log "Starting update installation"
    
    CURRENT_THEME=$(get_current_theme)
    echo -e "${BLUE}Detected current theme: $CURRENT_THEME${NC}"
    echo ""
    
    echo -e "${YELLOW}=== Update Options ===${NC}"
    echo ""
    echo "What would you like to update?"
    echo "1) Configs only (recommended)"
    echo "2) Configs and packages"
    echo "3) Change theme"
    echo "4) Change keyboard layout"
    echo "5) All of the above"
    read -p "Enter choice [1-5]: " UPDATE_CHOICE
    
    case $UPDATE_CHOICE in
        1)
            echo -e "${YELLOW}=== Backing Up Existing Configs ===${NC}"
            echo ""
            backup_configs "hypr"
            backup_configs "quickshell"
            backup_configs "rofi"
            backup_configs "kitty"
            backup_configs "swaync"
            backup_configs "gtk-3.0"
            echo ""
            
            echo -e "${BLUE}Select machine type:${NC}"
            echo "1) Desktop (3 monitors)"
            echo "2) Laptop (built-in + external)"
            read -p "Enter choice [1-2]: " MACHINE_TYPE
            
            case $MACHINE_TYPE in
                1) MONITOR_CONFIG="monitors-desktop.lua" ;;
                2) MONITOR_CONFIG="monitors-laptop.lua" ;;
            esac
            
            THEME="$CURRENT_THEME"
            if [ "$THEME" = "unknown" ]; then
                echo ""
                echo -e "${BLUE}Select color theme:${NC}"
                echo "1) Catppuccin Mocha (purple/blue)"
                echo "2) Gruvbox Dark (warm retro)"
                echo "3) Nord (cool blue-gray)"
                echo "4) Tokyo Night (modern dark blue)"
                read -p "Enter choice [1-4]: " THEME_CHOICE
                
                case $THEME_CHOICE in
                    1) THEME="catppuccin" ;;
                    2) THEME="gruvbox" ;;
                    3) THEME="nord" ;;
                    4) THEME="tokyo-night" ;;
                esac
            fi
            
            KEYBOARD_LAYOUT=$(grep "kb_layout = " ~/.config/hypr/hyprland.lua | cut -d'"' -f2)
            if [ -z "$KEYBOARD_LAYOUT" ]; then
                read -p "Keyboard layout [default: pt]: " KEYBOARD_LAYOUT
                KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-pt}
            fi
            
            install_configs
            apply_theme
            configure_keyboard
            ;;
            
        2)
            echo -e "${YELLOW}=== Backing Up Existing Configs ===${NC}"
            echo ""
            backup_configs "hypr"
            backup_configs "quickshell"
            backup_configs "rofi"
            backup_configs "kitty"
            backup_configs "swaync"
            backup_configs "gtk-3.0"
            echo ""
            
            echo -e "${BLUE}Select machine type:${NC}"
            echo "1) Desktop (3 monitors)"
            echo "2) Laptop (built-in + external)"
            read -p "Enter choice [1-2]: " MACHINE_TYPE
            
            case $MACHINE_TYPE in
                1) MONITOR_CONFIG="monitors-desktop.lua" ;;
                2) MONITOR_CONFIG="monitors-laptop.lua" ;;
            esac
            
            THEME="$CURRENT_THEME"
            if [ "$THEME" = "unknown" ]; then
                echo ""
                echo -e "${BLUE}Select color theme:${NC}"
                echo "1) Catppuccin Mocha (purple/blue)"
                echo "2) Gruvbox Dark (warm retro)"
                echo "3) Nord (cool blue-gray)"
                echo "4) Tokyo Night (modern dark blue)"
                read -p "Enter choice [1-4]: " THEME_CHOICE
                
                case $THEME_CHOICE in
                    1) THEME="catppuccin" ;;
                    2) THEME="gruvbox" ;;
                    3) THEME="nord" ;;
                    4) THEME="tokyo-night" ;;
                esac
            fi
            
            KEYBOARD_LAYOUT=$(grep "kb_layout = " ~/.config/hypr/hyprland.lua | cut -d'"' -f2)
            if [ -z "$KEYBOARD_LAYOUT" ]; then
                read -p "Keyboard layout [default: pt]: " KEYBOARD_LAYOUT
                KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-pt}
            fi
            
            install_packages
            install_configs
            apply_theme
            configure_keyboard
            enable_services
            ;;
            
        3)
            echo ""
            echo -e "${BLUE}Select color theme:${NC}"
            echo "1) Catppuccin Mocha (purple/blue)"
            echo "2) Gruvbox Dark (warm retro)"
            echo "3) Nord (cool blue-gray)"
            echo "4) Tokyo Night (modern dark blue)"
            read -p "Enter choice [1-4]: " THEME_CHOICE
            
            case $THEME_CHOICE in
                1) THEME="catppuccin" ;;
                2) THEME="gruvbox" ;;
                3) THEME="nord" ;;
                4) THEME="tokyo-night" ;;
            esac
            
            apply_theme
            ;;
            
        4)
            read -p "Keyboard layout [default: pt]: " KEYBOARD_LAYOUT
            KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-pt}
            configure_keyboard
            ;;
            
        5)
            echo -e "${YELLOW}=== Backing Up Existing Configs ===${NC}"
            echo ""
            backup_configs "hypr"
            backup_configs "quickshell"
            backup_configs "rofi"
            backup_configs "kitty"
            backup_configs "swaync"
            backup_configs "gtk-3.0"
            echo ""
            
            echo -e "${BLUE}Select machine type:${NC}"
            echo "1) Desktop (3 monitors)"
            echo "2) Laptop (built-in + external)"
            read -p "Enter choice [1-2]: " MACHINE_TYPE
            
            case $MACHINE_TYPE in
                1) MONITOR_CONFIG="monitors-desktop.lua" ;;
                2) MONITOR_CONFIG="monitors-laptop.lua" ;;
            esac
            
            echo ""
            echo -e "${BLUE}Select color theme:${NC}"
            echo "1) Catppuccin Mocha (purple/blue)"
            echo "2) Gruvbox Dark (warm retro)"
            echo "3) Nord (cool blue-gray)"
            echo "4) Tokyo Night (modern dark blue)"
            read -p "Enter choice [1-4]: " THEME_CHOICE
            
            case $THEME_CHOICE in
                1) THEME="catppuccin" ;;
                2) THEME="gruvbox" ;;
                3) THEME="nord" ;;
                4) THEME="tokyo-night" ;;
            esac
            
            read -p "Keyboard layout [default: pt]: " KEYBOARD_LAYOUT
            KEYBOARD_LAYOUT=${KEYBOARD_LAYOUT:-pt}
            
            install_packages
            install_configs
            apply_theme
            configure_keyboard
            enable_services
            ;;
            
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
    
    chmod +x ~/.config/rofi/launcher/launcher.sh 2>/dev/null || true
}

# Main menu
echo -e "${YELLOW}=== Main Menu ===${NC}"
echo ""

if detect_existing_install; then
    echo -e "${GREEN}Existing installation detected${NC}"
    echo ""
    echo "What would you like to do?"
    echo "1) Fresh installation (backup and reinstall everything)"
    echo "2) Update existing installation"
    read -p "Enter choice [1-2]: " INSTALL_MODE
else
    echo -e "${YELLOW}No existing installation detected${NC}"
    echo ""
    echo "Starting fresh installation..."
    INSTALL_MODE=1
fi

echo ""

case $INSTALL_MODE in
    1) fresh_install ;;
    2) update_install ;;
    *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
esac

# Cleanup temp directory if we created one
if [ -n "$WKSTATIONZ_DOWNLOADED" ] && [ -d "$WKSTATIONZ_DIR" ]; then
    echo ""
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -rf "$WKSTATIONZ_DIR"
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
