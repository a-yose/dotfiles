-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.windows")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Override Omarchy's default nvidia.lua, which sets LIBVA_DRIVER_NAME=nvidia
-- on any machine with an NVIDIA GPU. On this hybrid Optimus laptop the browser
-- and compositor both render on the Intel iGPU (renderD129), so routing VA-API
-- decode through NVDEC fails with "vaEndPicture failed: internal decoding
-- error" -- black, flickering video with working audio.
-- iHD is Intel's VA-API driver (package: intel-media-driver).
hl.env("LIBVA_DRIVER_NAME", "iHD")
