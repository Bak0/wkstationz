#!/bin/bash
# Apply color theme to all components
# Usage: apply-theme.sh <theme-name>
# Themes: catppuccin, gruvbox, nord, tokyo-night

set -e

THEME=$1

if [ -z "$THEME" ]; then
    echo "Usage: apply-theme.sh <theme-name>"
    echo "Available themes: catppuccin, gruvbox, nord, tokyo-night"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEME_DIR="$HOME/.config/wkstationz/themes/$THEME"

if [ ! -d "$THEME_DIR" ]; then
    echo "Error: Theme '$THEME' not found"
    echo "Available themes: catppuccin, gruvbox, nord, tokyo-night"
    exit 1
fi

echo "Applying theme: $THEME"

# Apply to Kitty
if [ -f "$THEME_DIR/kitty.conf" ]; then
    echo "  Applying to Kitty..."
    cp "$THEME_DIR/kitty.conf" ~/.config/kitty/kitty.conf
fi

# Apply to Rofi
if [ -f "$THEME_DIR/rofi.rasi" ]; then
    echo "  Applying to Rofi..."
    cp "$THEME_DIR/rofi.rasi" ~/.config/rofi/launcher/theme.rasi
fi

# Apply to Quickshell
if [ -f "$THEME_DIR/quickshell.conf" ]; then
    echo "  Applying to Quickshell..."
    cp "$THEME_DIR/quickshell.conf" ~/.config/quickshell/theme.conf
fi

# Apply to GTK
if [ -f "$THEME_DIR/gtk.css" ]; then
    echo "  Applying to GTK..."
    mkdir -p ~/.config/gtk-3.0
    cp "$THEME_DIR/gtk.css" ~/.config/gtk-3.0/gtk.css
fi

echo "Theme applied successfully!"
echo "You may need to restart applications for changes to take effect."
