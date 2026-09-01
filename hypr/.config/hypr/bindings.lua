-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

local apps = require("hypr.apps")

-- Web apps. o.launch_webapp_sole builds the launch-or-focus command with the
-- class as the match pattern, which is what Omarchy's shorthand
-- ({ webapp = url, focus = true }) gets wrong: that form matches on the
-- binding's description instead, so "Vercel CJ" would never find the window.
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Claude cloud", o.launch_webapp_sole(apps.claude.class, apps.claude.url))
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "Github - Profile", o.launch_webapp_sole(apps.github.class, apps.github.url))
hl.unbind("SUPER + SHIFT + V")
o.bind("SUPER + SHIFT + V", "Vercel CJ", o.launch_webapp_sole(apps.vercel.class, apps.vercel.url))
hl.unbind("SUPER + SHIFT + ALT + S")
o.bind("SUPER + SHIFT + ALT + S", "Supabase - Prod", o.launch_webapp_sole(apps.supabase.class, apps.supabase.url))
hl.unbind("SUPER + SHIFT + S")
o.bind(
	"SUPER + SHIFT + S",
	"Supabase - Local",
	o.launch_webapp_sole(apps.supabase_local.class, apps.supabase_local.url)
)

hl.unbind("SUPER + M")
o.bind("SUPER + M", "Monitor Config", "ghostty -e nvim ~/dotfiles/hypr/.config/hypr/monitors.lua")
hl.unbind("SUPER + ALT + N")
o.bind("SUPER + ALT + N", "Edit Neovim Config", "cd ~/dotfiles/nvim/.config/nvim && ghostty -e nvim")

-- Omarchy's default is { launch = "obsidian", focus = "^obsidian$" }, but the
-- real class is md.obsidian.Obsidian, so that pattern matches nothing and the
-- binding relaunched Obsidian instead of focusing the open window.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = apps.obsidian.class })
