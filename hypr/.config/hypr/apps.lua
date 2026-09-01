-- The window classes and URLs that more than one config file needs.
--
-- A class string is load-bearing in three places at once -- the placement rule
-- in windows.lua, the launch-or-focus keybinding in bindings.lua, and the
-- "is it already open?" check in autostart.lua -- and nothing catches a typo in
-- one of the copies. Defining it here means it is typed once.
--
-- Chromium derives a web app's class from its URL (host and path, with `/`
-- becoming `_`, dropping port, query and fragment), so the two always change
-- together. That is why they sit side by side here.
--
-- Anything that appears in only one file -- the workspace number, the
-- keybinding, the description -- stays inline in the file that uses it.
--
-- Confirm a class by focusing the window and running:
--   hyprctl activewindow -j | jq '{class, title}'

return {
	-- TUIs. These have no window flags of their own, so the class is an app-id
	-- handed to a terminal host at launch rather than something the app sets.
	herdr = { class = "dev.baz.herdr" },
	docker = { class = "org.omarchy.omarchy-launch-docker-tui" },

	-- Native apps, classes set by the app itself.
	obsidian = { class = "md.obsidian.Obsidian" },
	spotify = { class = "Spotify" },

	-- Web apps: Chromium `--app=<url>` windows, launched by omarchy-launch-webapp.
	-- That mode is the only way to give a browser window its own class; plain
	-- chromium windows all share one and cannot be placed.
	github = {
		class = "chrome-github.com__a-yose-Profile_1",
		url = "https://github.com/a-yose",
	},
	vercel = {
		class = "chrome-vercel.com__brents-projects-14fb3145_climbing-journal-Profile_1",
		url = "https://vercel.com/brents-projects-14fb3145/climbing-journal",
	},
	supabase = {
		class = "chrome-supabase.com__dashboard_project_ytjfmlzpqriaxgizkuta-Profile_1",
		url = "https://supabase.com/dashboard/project/ytjfmlzpqriaxgizkuta",
	},
	supabase_local = {
		class = "chrome-127.0.0.1__project_default_editor_20982-Profile_1",
		url = "http://127.0.0.1:54323/project/default/editor/20982?schema=public",
	},
	claude = {
		class = "chrome-claude.ai__new-Profile_1",
		url = "https://claude.ai/new",
	},
}
