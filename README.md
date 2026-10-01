# wkstationz

Personal Arch Linux setup for Hyprland, Quickshell, Kitty, Thunar, Rofi, and
the base applications listed in this repository.

## Install or update

Run this from an interactive terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Bak0/wkstationz/main/bootstrap.sh | bash
```

The bootstrap prints the published version and asks whether to install or
update/reapply. It reads choices from the controlling terminal, not curl's
stdin, downloads the complete repository into a unique `/tmp/wkstationz.*`
directory, and runs the installer from there. The installer then asks whether
this is the desktop or laptop. Catppuccin Mocha is the current default theme;
the installer does not ask for a theme yet.

Manual installation:

```bash
git clone https://github.com/Bak0/wkstationz.git
cd wkstationz
./install.sh
```

## Version behavior

- No saved version: choose Install, Update/reapply, or Exit.
- Same version: choose Update/reapply or Exit.
- Newer published version: update starts automatically.
- Installed version newer than published: choose downgrade/reinstall or Exit.

The installer requests sudo authentication once and keeps it alive during
package installation. Do not run it as root.

## Machine selection

- **Desktop:** three-monitor layout.
- **Laptop:** built-in display with an external display configuration.
- **Keyboard:** defaults to Portuguese (`pt`).

## What's included

- Hyprland configured with Lua
- Quickshell shell/bar and settings panel
- Rofi app launcher, Kitty, Thunar with dark GTK preference
- PulseAudio, swaync, Brave, KeePass, Obsidian
- Catppuccin Mocha as the current default theme

Package lists are `packages.list` and `aur-packages.list`. Configuration is in
`configs/`; themes are in `themes/`. Before replacing existing config folders,
the installer makes timestamped backups. The installed version is saved at
`~/.config/wkstationz/VERSION`.

## Troubleshooting

- Run from a terminal with a controlling TTY. Without one, the installer exits
  with a direct error instead of interpreting missing input as a bad choice.
- Log file: `/tmp/wkstationz-install.log`.
- Monitor names: `hyprctl monitors`.

## License

MIT
