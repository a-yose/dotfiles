-- Window placement rules: class -> workspace.
--
-- The compositor matches these when a window opens, so they apply no matter
-- what started it -- a keybinding, uwsm, ws-layout, or you by hand. Rules are
-- evaluated once, at open: moving a window afterwards sticks.
--
-- Find a window's class by focusing it and running:
--   hyprctl activewindow -j | jq '{class, title}'
--
-- "N silent" places the window on workspace N without dragging focus there.
-- Workspace -> monitor mapping lives in monitors.lua.

-- ws 2 (DP-1 ultrawide) -- herdr session.
-- herdr is a TUI, so a herdr window opened by hand (SUPER + CTRL + ENTER) keeps
-- the shared com.mitchellh.ghostty class and opens wherever you are; only the
-- dedicated app-id ws-layout gives it is pinned to ws 2.
o.window("dev.baz.herdr", { workspace = "2 silent" })

-- ws 3 (DP-1 ultrawide) -- notes
o.window("md.obsidian.Obsidian", { workspace = "3 silent", suppress_event = "activate activatefocus" })

-- ws 4 (LG UltraGear) -- the project workspace.
-- In a scrolling layout, columns land in the order the windows open, so the
-- launch order in ws-layout is what sets the left-to-right arrangement.
o.window("org.omarchy.omarchy-launch-docker-tui", { workspace = "4 silent" })
o.window("chrome-github.com__a-yose-Profile_1", { workspace = "4 silent" })
o.window("chrome-vercel.com__brents-projects-14fb3145_climbing-journal-Profile_1", { workspace = "4 silent" })
o.window("chrome-supabase.com__dashboard_project_ytjfmlzpqriaxgizkuta-Profile_1", { workspace = "4 silent" })
o.window("chrome-127.0.0.1__project_default_editor_20982-Profile_1", { workspace = "4 silent" })

-- ws 5 (laptop) -- music
o.window("Spotify", { workspace = "5 silent" })
