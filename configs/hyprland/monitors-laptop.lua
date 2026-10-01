# Laptop Monitor Configuration
# Built-in + External monitor (auto-detect)

-- Auto-detect external monitor
-- If external monitor is connected, use it as primary
-- Otherwise, use laptop built-in display

-- Laptop built-in display (fallback)
monitor = "eDP-1, preferred, auto, 1"

-- External monitor (when connected)
-- Uncomment the line below and adjust for your external monitor
-- monitor = "HDMI-A-1, preferred, 0x0, 1"

-- Workspace assignments (single monitor)
workspace = "1, monitor:eDP-1"
workspace = "2, monitor:eDP-1"
workspace = "3, monitor:eDP-1"
workspace = "4, monitor:eDP-1"
workspace = "5, monitor:eDP-1"
workspace = "6, monitor:eDP-1"
workspace = "7, monitor:eDP-1"
workspace = "8, monitor:eDP-1"
workspace = "9, monitor:eDP-1"

-- Note: To use external monitor as primary, comment out the eDP-1 line
-- and uncomment the HDMI-A-1 line above. Adjust the monitor name as needed.
-- You can find your monitor names with: hyprctl monitors
