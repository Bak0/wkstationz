# Hyprland Keybinds Configuration (Lua format)

-- Variables
local modkey = "SUPER"

-- Application launchers
bind = {modkey, "T", "exec", "kitty"}
bind = {modkey, "B", "exec", "brave"}
bind = {modkey, "E", "exec", "thunar"}
bind = {modkey, "SPACE", "exec", "rofi -show drun"}
bind = {modkey, "L", "exec", "hyprlock"}

-- Window management
bind = {modkey, "Q", "killactive", ""}
bind = {modkey, "F", "fullscreen", ""}
bind = {modkey .. " SHIFT", "Q", "exit", ""}
bind = {modkey, "V", "togglefloating", ""}
bind = {modkey, "P", "pseudo", ""}
bind = {modkey, "J", "togglesplit", ""}

-- Move focus
bind = {modkey, "left", "movefocus", "l"}
bind = {modkey, "right", "movefocus", "r"}
bind = {modkey, "up", "movefocus", "u"}
bind = {modkey, "down", "movefocus", "d"}

-- Move windows
bind = {modkey .. " SHIFT", "left", "movewindow", "l"}
bind = {modkey .. " SHIFT", "right", "movewindow", "r"}
bind = {modkey .. " SHIFT", "up", "movewindow", "u"}
bind = {modkey .. " SHIFT", "down", "movewindow", "d"}

-- Workspaces
for i = 1, 9 do
    bind = {modkey, tostring(i), "workspace", tostring(i)}
    bind = {modkey .. " SHIFT", tostring(i), "movetoworkspace", tostring(i)}
end

-- Special workspace (scratchpad)
bind = {modkey, "S", "togglespecialworkspace", ""}
bind = {modkey .. " SHIFT", "S", "movetoworkspace", "special"}

-- Scroll through workspaces
bind = {modkey, "mouse_down", "workspace", "e+1"}
bind = {modkey, "mouse_up", "workspace", "e-1"}

-- Media keys
bind = {"", "XF86AudioRaiseVolume", "exec", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"}
bind = {"", "XF86AudioLowerVolume", "exec", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"}
bind = {"", "XF86AudioMute", "exec", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"}
bind = {"", "XF86AudioPlay", "exec", "playerctl play-pause"}
bind = {"", "XF86AudioNext", "exec", "playerctl next"}
bind = {"", "XF86AudioPrev", "exec", "playerctl previous"}
bind = {"", "XF86MonBrightnessUp", "exec", "brightnessctl set 5%+"}
bind = {"", "XF86MonBrightnessDown", "exec", "brightnessctl set 5%-"}

-- Screenshots
bind = {"", "Print", "exec", "grim - | wl-copy"}
bind = {modkey, "Print", "exec", "grim -g \"$(slurp)\" - | wl-copy"}

-- Resize mode
bind = {modkey, "R", "submap", "resize"}

submap = "resize"
bind = {"", "up", "resizeactive", "0 -20"}
bind = {"", "down", "resizeactive", "0 20"}
bind = {"", "left", "resizeactive", "-20 0"}
bind = {"", "right", "resizeactive", "20 0"}
bind = {"", "escape", "submap", "reset"}
submap = "reset"

-- Mouse bindings
bindm = {modkey, "mouse:272", "movewindow"}
bindm = {modkey, "mouse:273", "resizewindow"}
