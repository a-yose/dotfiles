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
o.bind(
	"SUPER + SHIFT + C",
	"Claude cloud",
	"omarchy-launch-or-focus-webapp chrome-claude.ai__new-Profile_1 https://claude.ai/new"
)
hl.unbind("SUPER + SHIFT + G")
o.bind(
	"SUPER + SHIFT + G",
	"Github - Profile",
	"omarchy-launch-or-focus-webapp chrome-github.com__a-yose-Profile_1 https://github.com/a-yose"
)
hl.unbind("SUPER + SHIFT + ALT + S")
o.bind(
	"SUPER + SHIFT + ALT + S",
	"Supabase - Prod",
	"omarchy-launch-or-focus-webapp chrome-supabase.com__dashboard_project_ytjfmlzpqriaxgizkuta-Profile_1 https://supabase.com/dashboard/project/ytjfmlzpqriaxgizkuta"
)
hl.unbind("SUPER + SHIFT + S")
o.bind(
	"SUPER + SHIFT + S",
	"Supabase - Local",
	"omarchy-launch-or-focus-webapp chrome-127.0.0.1__project_default_editor_20982-Profile_1 http://127.0.0.1:54323/project/default/editor/20982?schema=public"
)
hl.unbind("SUPER + M")
o.bind("SUPER + M", "Monitor Config", "ghostty -e nvim ~/dotfiles/hypr/.config/hypr/monitors.lua")
hl.unbind("SUPER + ALT + N")
o.bind("SUPER + ALT + N", "Edit Neovim Config", "cd ~/dotfiles/nvim/.config/nvim && ghostty -e nvim")

-- Omarchy's default is { launch = "obsidian", focus = "^obsidian$" }, but the
-- real class is md.obsidian.Obsidian, so that pattern matches nothing and the
-- binding relaunched Obsidian instead of focusing the open window.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "md.obsidian.Obsidian" })
