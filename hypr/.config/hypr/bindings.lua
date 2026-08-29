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

hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Claude cloud", "omarchy-launch-webapp https://claude.ai/new")
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "Github - Profile", "omarchy-launch-webapp https://github.com/a-yose")
hl.unbind("SUPER + SHIFT + S")
o.bind(
	"SUPER + SHIFT + S",
	"Supabase",
	"omarchy-launch-webapp http://127.0.0.1:54323/project/default/editor/20982?schema=public"
)
hl.unbind("SUPER + M")
o.bind("SUPER + M", "Monitor Config", "ghostty -e nvim ~/dotfiles/hypr/.config/hypr/monitors.lua")
hl.unbind("SUPER + ALT + N")
o.bind("SUPER + ALT + N", "Edit Neovim Config", "cd ~/dotfiles/nvim/.config/nvim && ghostty -e nvim")
