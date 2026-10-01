# wkstationz

Automated Arch Linux desktop setup with Hyprland, Quickshell, and essential applications.

## Quick Start

### One-liner installation
```bash
curl -fsSL https://raw.githubusercontent.com/Bak0/wkstationz/main/bootstrap.sh | bash -s -- --desktop --catppuccin
```

### Manual installation
```bash
git clone https://github.com/Bak0/wkstationz.git
cd wkstationz
./install.sh --desktop --catppuccin
```

## Usage

```bash
./install.sh [OPTIONS]

Options:
  --desktop          Desktop setup (3 monitors)
  --laptop           Laptop setup (built-in + external)
  --catppuccin       Use Catppuccin theme (purple/blue)
  --gruvbox          Use Gruvbox theme (warm retro)
  --nord             Use Nord theme (cool blue-gray)
  --tokyo-night      Use Tokyo Night theme (modern dark blue)
  --keyboard=XX      Keyboard layout (default: pt)
  --force-install    Force fresh installation
  --force-update     Force update installation
  --help             Show help
```

### Examples

**Desktop with Catppuccin theme:**
```bash
./install.sh --desktop --catppuccin
```

**Laptop with Nord theme and US keyboard:**
```bash
./install.sh --laptop --nord --keyboard=us
```

**Force fresh installation:**
```bash
./install.sh --desktop --gruvbox --force-install
```

**Update existing installation:**
```bash
./install.sh --desktop --tokyo-night --force-update
```

## Version Management

The installer uses version-based logic:

- **No existing installation**: Performs fresh installation
- **Same version installed**: Shows message, use `--force-update` to update configs
- **Newer version available**: Automatically performs update
- **Older version installed**: Shows message, use `--force-install` to downgrade

Check your installed version:
```bash
cat ~/.config/wkstationz/VERSION
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
- `Super+Arrow keys` - Move focus
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
- `wkstationz/` - Version tracking

### Changing Themes

After installation, you can switch themes using the settings dropdown in Quickshell, or manually:

```bash
~/.config/wkstationz/scripts/apply-theme.sh catppuccin
~/.config/wkstationz/scripts/apply-theme.sh gruvbox
~/.config/wkstationz/scripts/apply-theme.sh nord
~/.config/wkstationz/scripts/apply-theme.sh tokyo-night
```

### Monitor Configuration

Edit `~/.config/hypr/monitors.lua` to adjust monitor layout.

For laptops with external monitors, you may need to adjust the monitor names. Find your monitor names with:
```bash
hyprctl monitors
```

## Updating

Run the installer again with the same or different options:

```bash
cd ~/wkstationz  # or wherever you cloned it
./install.sh --desktop --catppuccin --force-update
```

Or download and run the latest version:
```bash
curl -fsSL https://raw.githubusercontent.com/Bak0/wkstationz/main/bootstrap.sh | bash -s -- --desktop --catppuccin --force-update
```

## Project Structure

```
wkstationz/
├── VERSION                # Current version
├── bootstrap.sh           # Download and run installer
├── install.sh             # Main installation script
├── packages.list          # Pacman packages
├── aur-packages.list      # AUR packages
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

### Quickshell not starting
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
~/.config/wkstationz/scripts/apply-theme.sh <theme-name>
```

### Check installation logs
```bash
cat /tmp/wkstationz-install.log
```

## Requirements

- Fresh Arch Linux installation (or existing setup to update)
- Internet connection
- sudo privileges

## License

MIT License - Feel free to fork and modify for your own use.

## Credits

- Hyprland community for the compositor
- Quickshell developers for the status bar
- All the theme creators (Catppuccin, Gruvbox, Nord, Tokyo Night)
