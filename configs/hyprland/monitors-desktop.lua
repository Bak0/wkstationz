-- wkstationz desktop monitor layout (3 monitors).
-- Adjust the connector names for the target machine with: hyprctl monitors
-- Layout: left vertical, center main, right horizontal

hl.monitor({
    output = "DP-3",          -- LEFT (rotated/vertical)
    mode = "1920x1080@60",
    position = "0x0",
    transform = 1,
})

hl.monitor({
    output = "HDMI-A-1",      -- CENTER (main)
    mode = "1920x1080@60",
    position = "1080x0",
})

hl.monitor({
    output = "DP-2",          -- RIGHT (horizontal)
    mode = "1920x1080@60",
    position = "3000x0",
})

hl.workspace_rule({ workspace = 1,  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = 2,  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = 3,  monitor = "HDMI-A-1", persistent = true })
hl.workspace_rule({ workspace = 4,  monitor = "DP-3",     persistent = true })
hl.workspace_rule({ workspace = 5,  monitor = "DP-3",     persistent = true })
hl.workspace_rule({ workspace = 6,  monitor = "DP-3",     persistent = true })
hl.workspace_rule({ workspace = 7,  monitor = "DP-2",     persistent = true })
hl.workspace_rule({ workspace = 8,  monitor = "DP-2",     persistent = true })
hl.workspace_rule({ workspace = 9,  monitor = "DP-2",     persistent = true })
