# Hyprland

`hyprland.lua` runs Omarchy's bootstrap, requires Omarchy's defaults, then the
personal overrides — layering, not replacing, so upstream updates keep improving
the base. The `hl` and `o` globals come from Omarchy's helpers;
`hypr/.stow-local-ignore` keeps `.luarc.json` (which declares them for the LSP)
and `.claude/` out of `$HOME`.

## Window placement

Declarative across four files, so a window lands in the same place no matter
what opened it:

- `apps.lua` — window classes and web-app URLs, defined once, required by the
  other three
- `monitors.lua` — workspace → monitor, and which workspaces scroll
- `windows.lua` — window class → workspace (matched once, at open)
- `autostart.lua` — only _launches_, on the `hyprland.start` event

`autostart.lua` brings up the standing work layout at login. Its local `start()`
helper skips anything already open (`hl.get_windows({ class = ... })`), so a
second event can't duplicate the layout or steal focus. Commands go through
Omarchy's `o.launch`, `o.launch_webapp` and `o.launch_webapp_sole`, which handle
shell quoting. Login is the only trigger — deliberately no keybinding to re-run
it.

`hl.exec_cmd` spawns from the compositor's environment, which is why no
`HERDR_*` unset is needed: herdr refuses to start when it sees `HERDR_PANE_ID`,
and the compositor never has it set.

## TUIs need a terminal host to get a class

`herdr` and the docker TUI have no window flags of their own, so they go through
`omarchy-launch-tui --app-id=<class>`, which supplies the string `windows.lua`
matches on. Only that app-id is pinned — a herdr window opened by hand
(`SUPER + CTRL + ENTER`) keeps the shared `com.mitchellh.ghostty` class and
lands wherever you already are.

## Web apps

A "web app" is Chromium's `--app=<url>` mode, launched by
`omarchy-launch-webapp`. It is the only way to give a browser window its own
Hyprland class; plain `chromium` windows all share one class and can't be
placed.

Chromium derives the class as `chrome-<host>_<path, / → _>-Profile_1`, dropping
port, query and fragment — so `https://github.com/a-yose` becomes
`chrome-github.com__a-yose-Profile_1`, the double underscore being the joiner
plus the path's leading slash. Derive it, then **confirm it** with `hyprctl`
below. It is load-bearing in three files at once, which is why it is defined
once in `apps.lua` and referenced by name from `windows.lua` (workspace rule),
`bindings.lua` (launch-or-focus binding) and `autostart.lua` (already-open check
and launch line).

The `.desktop` entries live in `~/.local/share/applications`, which is **not
stowed**, so they are not in this repo. `install-webapps.sh` in `~/omarchy-setup`
owns them: a `name|url|icon` list, one line per app, skipped when the file
already exists. That entry only puts the app in the launcher (`SUPER + SPACE`)
— it plays no part in the class, so layout and keybindings work with or without
it. Leave `icon` empty to fetch the site's own favicon; set it when that can't
work on a fresh machine, as with the local Supabase URL whose `127.0.0.1` port
won't be listening.

## Inspection

```bash
hyprctl activewindow -j | jq '{class, title}'   # find a class for a window rule

# Every binding on one key, before you claim it. Filter on the key -- scanning
# descriptions misses binds that carry none. modmask is a sum: SHIFT 1, CTRL 4,
# ALT 8, SUPER 64, so SUPER+SHIFT is 65, SUPER+CTRL 68, SUPER+ALT 72.
hyprctl binds -j | jq -r '.[] | select((.key|ascii_downcase) == "v") | "\(.modmask)\t\(.description)"'
```
