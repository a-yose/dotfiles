-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
local legion_scale = 1.6
local dell_monitor = "desc:Dell Inc. Dell AW3420DW #ASPZdyc07szd"
local left_monitor = "desc:LG Electronics LG ULTRAGEAR 302NTVS7C639"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({
	output = left_monitor,
	mode = "2560x1440",
	position = "0x0",
	scale = omarchy_monitor_scale,
})
hl.monitor({ output = dell_monitor, mode = "3440x1440", position = "2560x0", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-2", mode = "preferred", position = "6000x0", scale = legion_scale })

hl.workspace_rule({ workspace = "1", monitor = dell_monitor, default = true, layout = "scrolling" })
hl.workspace_rule({ workspace = "2", monitor = dell_monitor, layout = "scrolling" })
hl.workspace_rule({ workspace = "3", monitor = dell_monitor, layout = "scrolling" })
hl.workspace_rule({ workspace = "4", monitor = left_monitor })
hl.workspace_rule({ workspace = "5", monitor = "eDP-2", layout = "scrolling" })
