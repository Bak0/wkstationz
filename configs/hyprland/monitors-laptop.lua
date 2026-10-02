-- wkstationz laptop monitor layout.
-- Built-in display is used by default; adjust the names for the target machine
-- with: hyprctl monitors

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- External monitor: uncomment and adjust the connector name when connected.
-- hl.monitor({
--     output = "HDMI-A-1",
--     mode = "preferred",
--     position = "auto",
-- })

for i = 1, 9 do
    hl.workspace_rule({ workspace = i, monitor = "eDP-1", persistent = true })
end
