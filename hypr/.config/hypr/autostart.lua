-- Extra autostart processes.
-- o.launch_on_start("my-service")

local apps = require("hypr.apps")

-- Start `command` unless a window of that class is already open.
--
-- The guard matters because the launchers below would otherwise open a second
-- copy of everything if this event ever fires twice in one session. It also
-- keeps the layout quiet: the launch-or-focus variants used by the keybindings
-- in bindings.lua *focus* what they find, which would drag focus across five
-- workspaces in a row. Doing nothing is the right behaviour here.
--
-- `#` is Lua's "length of" operator, so this reads as "no windows matched".
local function start(app, command)
	if #hl.get_windows({ class = app.class }) == 0 then
		hl.exec_cmd(command)
	end
end

-- Bring up the standing work layout at login.
--
-- This only launches. Where each window lands is decided by the class rules in
-- windows.lua, so a window opened by hand or by a keybinding ends up in the
-- same place.
--
-- hl.exec_cmd spawns from the compositor's own environment, which is what keeps
-- herdr happy: no HERDR_* variables are set there, so the ws 2 entry can't trip
-- herdr's nested-session guard.
hl.on("hyprland.start", function()
	-- ws 2 -- herdr session. A TUI has no window flags of its own, so it needs a
	-- terminal host to carry the app-id that windows.lua matches on.
	start(apps.herdr, "omarchy-launch-tui --app-id=" .. apps.herdr.class .. " herdr")

	-- ws 3 -- notes
	start(apps.obsidian, o.launch("obsidian"))

	-- ws 4 -- project workspace
	start(apps.docker, "omarchy-launch-tui --app-id=" .. apps.docker.class .. " omarchy-launch-docker-tui")
	start(apps.github, o.launch_webapp(apps.github.url))
	start(apps.vercel, o.launch_webapp(apps.vercel.url))
	start(apps.supabase, o.launch_webapp(apps.supabase.url))
	start(apps.supabase_local, o.launch_webapp(apps.supabase_local.url))

	-- ws 5 -- music. omarchy-launch-spotify handles the not-installed case, so
	-- it is used instead of a plain `spotify`.
	start(apps.spotify, "omarchy-launch-spotify")
end)

-- TODO: ws 1 -- the Gmail window is still a plain `chromium`, so it shares one
-- class with every other plain chromium window and can't be placed. Convert it
-- to a webapp to give it its own class, add it to apps.lua, then add a rule in
-- windows.lua and a start() line above.
