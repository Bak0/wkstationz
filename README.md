# Arch Setup

Automated Arch Linux desktop setup with Hyprland, Quickshell, and essential applications.

## Quick Start

### Option 1: Direct Curl (Recommended for fresh installs)
```bash
curl -fsSL https://raw.githubusercontent.com/bak0/arch-setup/main/install.sh | bash
```

### Option 2: Git Clone
```bash
git clone https://github.com/bak0/arch-setup.git
cd arch-setup
./install.sh
```

## What's Included

### Core Components
- **Hyprland** - Wayland compositor with smooth animations
- **Quickshell** - Modern status bar and widgets
- **Rofi** - macOS-style application launcher
- **SwayNC** - Notification daemon

### Applications
- **Kitty** - Terminal emulator
- **Thunar** - File manager (dark mode)
- **Brave** - Web browser
- **KeePass** - Password manager
- **Obsidian** - Notes application

### Audio
- **PulseAudio** - Sound server with volume control

## Installation Process

The installer will prompt you for:

1. **Machine Type**
   - Desktop (3 monitors: left vertical, center main, right horizontal)
   - Laptop (built-in + external monitor)

2. **Color Theme**
   - Catppuccin Mocha (purple/blue)
   - Gruvbox Dark (warm retro)
   - Nord (cool blue-gray)
   - Tokyo Night (modern dark blue)

3. **Keyboard Layout**
   - Default: Portuguese (pt)
   - Enter your preferred layout code

## Post-Installation

### First Boot
1. Reboot your system
2. Select "Hyprland" at the SDDM login screen
3. Log in with your password

### Default Keybinds
- `Super+T` - Terminal (Kitty)
- `Super+B` - Browser (Brave)
- `Super+E` - File manager (Thunar)
- `Super+Space` - App launcher (Rofi)
- `Super+L` - Lock screen
- `Super+Q` - Close window
- `Super+F` - Fullscreen
- `Super+Arrows` - Move focus
- `Super+1-9` - Switch workspace
- `Super+Shift+1-9` - Move window to workspace
- `Print` - Screenshot (full screen)
- `Super+Print` - Screenshot (selection)

### Quickshell Bar
- **Left**: Workspace selector
- **Center**: Clock and date (large, bold)
- **Right**: Bluetooth, audio, settings button
- **Settings dropdown**: Brightness, volume, WiFi, Bluetooth, screenshot, recording, theme switcher

## Configuration

All configurations are stored in `~/.config/`:

- `hypr/` - Hyprland configuration (Lua format)
- `quickshell/` - Quickshell bar and widgets
- `rofi/` - Application launcher
- `kitty/` - Terminal configuration
- `swaync/` - Notification daemon
- `gtk-3.0/` - GTK theme settings

### Changing Themes

After installation, you can switch themes using the settings dropdown in Quickshell, or manually:

```bash
~/.config/arch-setup/scripts/apply-theme.sh catppuccin
~/.config/arch-setup/scripts/apply-theme.sh gruvbox
~/.config/arch-setup/scripts/apply-theme.sh nord
~/.config/arch-setup/scripts/apply-theme.sh tokyo-night
```

### Monitor Configuration

Edit `~/.config/hypr/monitors.lua` to adjust monitor layout.

For laptops with external monitors, you may need to adjust the monitor names. Find your monitor names with:
```bash
hyprctl monitors
```

## Project Structure

```
arch-setup/
├── install.sh              # Main installation script
├── packages.list           # Pacman packages
├── aur-packages.list       # AUR packages
├── configs/
│   ├── hyprland/          # Hyprland configs
│   ├── quickshell/        # Quickshell configs
│   ├── rofi/              # Rofi launcher
│   ├── kitty/             # Terminal config
│   ├── swaync/            # Notification config
│   └── gtk-3.0/           # GTK settings
├── themes/                # Color themes
│   ├── catppuccin/
│   ├── gruvbox/
│   ├── nord/
│   └── tokyo-night/
└── scripts/               # Helper scripts
    ├── install-yay.sh
    ├── apply-theme.sh
    └── enable-services.sh
```

## Troubleshooting

### Waybar/Quickshell not starting
Check if Quickshell is running:
```bash
ps aux | grep quickshell
```

Start it manually:
```bash
quickshell &
```

### Audio not working
Restart PulseAudio:
```bash
systemctl --user restart pulseaudio
```

### Monitor layout wrong
1. Find monitor names: `hyprctl monitors`
2. Edit `~/.config/hypr/monitors.lua`
3. Reload Hyprland: `hyprctl reload`

### Theme not applying
Run the theme script manually:
```bash
~/.config/arch-setup/scripts/apply-theme.sh <theme-name>
```

## Customization

### Adding Packages

Edit `packages.list` for pacman packages or `aur-packages.list` for AUR packages, then run:
```bash
# For pacman packages
sudo pacman -S --needed $(cat packages.list | grep -v '^#' | grep -v '^$')

# For AUR packages
yay -S --needed $(cat aur-packages.list | grep -v '^#' | grep -v '^$')
```

### Modifying Keybinds

Edit `~/.config/hypr/keybinds.lua` and reload:
```bash
hyprctl reload
```

## Requirements

- Fresh Arch Linux installation
- Internet connection
- sudo privileges

## License

MIT License - Feel free to fork and modify for your own use.

## Credits

- Hyprland community for the compositor
- Quickshell developers for the status bar
- All the theme creators (Catppuccin, Gruvbox, Nord, Tokyo Night)
