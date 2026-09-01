-- Window placement rules: class -> workspace.
--
-- The compositor matches these when a window opens, so they apply no matter
-- what started it -- autostart.lua, a keybinding, or you by hand. Rules are
-- evaluated once, at open: moving a window afterwards sticks.
--
-- Class strings are defined in apps.lua, because autostart.lua and bindings.lua
-- need the same ones.
--
-- "N silent" places the window on workspace N without dragging focus there.
-- Workspace -> monitor mapping lives in monitors.lua.

local apps = require("hypr.apps")

-- ws 2 (DP-1 ultrawide) -- herdr session.
-- herdr is a TUI, so a herdr window opened by hand (SUPER + CTRL + ENTER) keeps
-- the shared com.mitchellh.ghostty class and opens wherever you are; only the
-- dedicated app-id autostart.lua gives it is pinned to ws 2.
--
-- `maximize` opens it at the full workspace width while leaving it tiled, so
-- gaps and borders still apply. Without it the width depends on ws 2's current
-- layout and on whether anything else shares the workspace -- a scrolling
-- column opens at scrolling:column_width (0.5) as soon as it isn't alone.
o.window(apps.herdr.class, { workspace = "2 silent", maximize = true })

-- ws 3 (DP-1 ultrawide) -- notes
o.window(apps.obsidian.class, { workspace = "3 silent", suppress_event = "activate activatefocus" })

-- ws 4 (LG UltraGear) -- the project workspace.
-- These share a workspace under a scrolling layout, so columns land in whatever
-- order the windows happen to open.
o.window(apps.docker.class, { workspace = "4 silent" })
o.window(apps.github.class, { workspace = "4 silent" })
o.window(apps.vercel.class, { workspace = "4 silent" })
o.window(apps.supabase.class, { workspace = "4 silent" })
o.window(apps.supabase_local.class, { workspace = "4 silent" })

-- ws 5 (laptop) -- music
o.window(apps.spotify.class, { workspace = "5 silent" })
