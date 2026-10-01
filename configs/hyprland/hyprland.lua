# Hyprland Configuration (Lua format)
# Main configuration file

-- Monitor configuration is loaded from monitors.lua
dofile(os.getenv("HOME") .. "/.config/hypr/monitors.lua")

-- General settings
general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 2,
    col = {
        active_border = "rgb(7aa2f7)",
        inactive_border = "rgb(414868)"
    },
    resize_on_border = true
}

-- Decoration settings
decoration = {
    rounding = 0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
        enabled = false
    },
    blur = {
        enabled = false
    }
}

-- Animation settings
animations = {
    enabled = true,
    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05",
    animation = {
        "windows, 1, 7, myBezier",
        "windowsOut, 1, 7, default, popin 80%",
        "border, 1, 10, default",
        "borderangle, 1, 8, default",
        "fade, 1, 7, default",
        "workspaces, 1, 6, default"
    }
}

-- Dwindle layout
dwindle = {
    pseudotile = true,
    preserve_split = true
}

-- Master layout
master = {
    new_status = "master"
}

-- Misc settings
misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true
}

-- Input settings
input = {
    kb_layout = "pt",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
        natural_scroll = true
    }
}

-- Gestures
gestures = {
    workspace_swipe = true,
    workspace_swipe_fingers = 3
}

-- Window rules
windowrulev2 = "float, class:^(thunar)$"
windowrulev2 = "size 900 600, class:^(thunar)$"
windowrulev2 = "center, class:^(thunar)$"

-- Autostart
exec-once = "quickshell"
exec-once = "swaync"
exec-once = "wl-paste --watch cliphist store"

-- Keybinds are loaded from keybinds.lua
dofile(os.getenv("HOME") .. "/.config/hypr/keybinds.lua")
