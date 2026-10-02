-- wkstationz keybinds (Hyprland Lua API)
local mod = "SUPER"

-- Apps
hl.bind(mod .. " + T", hl.dsp.exec_cmd("kitty"),  { description = "App: Terminal" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd("brave"),  { description = "App: Browser" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd("thunar"), { description = "App: File manager" })
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("rofi -show drun"), { description = "App: Launcher" })
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"), { description = "Session: Lock screen" })

-- Window management
hl.bind(mod .. " + Q", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Window: Fullscreen" })
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float" })
hl.bind(mod .. " + P", hl.dsp.window.pin(), { description = "Window: Pin" })

-- Focus movement
hl.bind(mod .. " + Left",  hl.dsp.focus({ direction = "l" }), { description = "Window: Focus left" })
hl.bind(mod .. " + Right", hl.dsp.focus({ direction = "r" }), { description = "Window: Focus right" })
hl.bind(mod .. " + Up",    hl.dsp.focus({ direction = "u" }), { description = "Window: Focus up" })
hl.bind(mod .. " + Down",  hl.dsp.focus({ direction = "d" }), { description = "Window: Focus down" })

-- Window movement
hl.bind(mod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }), { description = "Window: Move left" })
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), { description = "Window: Move right" })
hl.bind(mod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }), { description = "Window: Move up" })
hl.bind(mod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }), { description = "Window: Move down" })

-- Workspaces
for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }),
        { description = "Workspace: Focus " .. i })
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i), follow = false }),
        { description = "Workspace: Move window to " .. i })
end
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("special"), { description = "Workspace: Toggle scratchpad" })

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"), { description = "Utilities: Screenshot >> clipboard" })
hl.bind(mod .. " + Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]),
    { description = "Utilities: Screenshot region >> clipboard" })

-- Mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Drag" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })
