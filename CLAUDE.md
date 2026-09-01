# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for an **Omarchy** machine (Arch + Hyprland). Every top-level
directory is a GNU Stow package whose layout mirrors `$HOME`:
`git/.config/git/config` → `~/.config/git/config`.

No build, no test suite, no application code. "Running" a change means reloading
whichever tool owns the file.

**Files here are symlinked into `$HOME`.** Editing `hypr/.config/hypr/windows.lua`
in this repo edits the live `~/.config/hypr/windows.lua`. No deploy step — and no
undo.

`README.md` has the step-by-step procedures for adding and removing packages and
services. This file is the model behind them.

## The two-repo contract

The installer is **not in this repo**. It lives in `~/omarchy-setup/`:
`install-dotfiles.sh` (clones/pulls and stows), `master-install.sh` (runs every
`install-*.sh`), `install-webapps.sh` (the Chromium web-app launchers, which are
not stowed — see **Web apps** below), and `bashrc-drift-check` (orphaned — not
wired in, run by hand).

Adding a package here is half the job. Without a `stow_package <pkg>` line in
`install-dotfiles.sh`, a fresh machine silently won't get it. **Nothing enforces
this** — no check compares the package dirs here against that file. Changes
usually mean a commit in both repos.

`OLD_CONFIGS` in that script lists paths deleted before stowing, so a stock
Omarchy file doesn't cause a stow conflict. A new package whose target already
exists on a fresh machine needs its `$HOME` path added there.

## Four stow patterns, not one

| Pattern                                              | Packages                                               |
| ---------------------------------------------------- | ------------------------------------------------------ |
| plain                                                | `bash`, `nvim`, `prettier`, `markdownlint`             |
| `--no-folding` — target dir holds files we don't own | `ssh`, `git`, `mise`, `herdr`, `claude`, `dygma-watch` |
| `--no-folding --adopt`                               | `hypr`                                                 |
| not stowed; include-line instead                     | `ghostty`                                              |

Two hazards live in that table:

- **`hypr` uses `--adopt`**, which overwrites the _repo_ with machine state.
  On a fresh install Omarchy's stock templates land on top of the real config.
  `master-install.sh` exits 0 either way, so it scrolls past. After any install
  run, check `git status --short -- hypr/` and recover with
  `git checkout -- hypr/`.
- **The ghostty include is append-once.** `~/.config/ghostty/config` is Omarchy's
  file plus three appended lines; Omarchy rewrites it on update and the overrides
  then silently stop applying. Verify with
  `grep -n overrides.conf ~/.config/ghostty/config`; restore by re-running
  `install-dotfiles.sh`.

Tracked but **never stowed**: `dygma`, `Bazecor`, `profile`, `wsl-mise`, `zsh` —
backups and other-machine configs.

## Commands

```bash
cd ~/dotfiles
stow -n -v <pkg>     # dry run — always first
stow <pkg>           # link (use the same flags the installer uses)
stow -R <pkg>        # restow; clears stale links after moving files
stow -D <pkg>        # unlink
```

```bash
systemctl --user daemon-reload              # required after any unit edit
systemctl --user enable --now <unit>.service
journalctl --user -u <unit>.service -f      # stdout/stderr goes here
```

Formatting and linting — no runner, invoke directly. Tools come from mise
(`mise/.config/mise/config.toml`; note `install-prettier.sh` and
`install-sh-fmt.sh` pin the same versions again, so change both). `markdownlint`
is not on `PATH` — it lives in mason:

```bash
shfmt -i 2 -ci -bn -w <script>   # flags match the nvim conform config
shellcheck <script>
stylua <file>.lua                # nvim lua only — nvim/.config/nvim/.stylua.toml
prettier --write <file>          # prettier/.config/prettier/.prettierrc
~/.local/share/nvim/mason/bin/markdownlint <file>.md
```

```bash
hyprctl activewindow -j | jq '{class, title}'   # find a class for a window rule
ws-layout --dry-run                             # what the layout would launch

# Every binding on one key, before you claim it. Filter on the key -- scanning
# descriptions misses binds that carry none. modmask is a sum: SHIFT 1, CTRL 4,
# ALT 8, SUPER 64, so SUPER+SHIFT is 65, SUPER+CTRL 68, SUPER+ALT 72.
hyprctl binds -j | jq -r '.[] | select((.key|ascii_downcase) == "v") | "\(.modmask)\t\(.description)"'
```

## Architecture: layering, not replacing

Both large packages extend Omarchy's defaults rather than owning them, so
upstream updates keep improving the base.

**bash** — `bash/.bashrc` sources `$OMARCHY_PATH/default/bash/rc` first, then
`~/.config/bash/rc.sh`, which sources in fixed order: `envs.sh` → `shell.sh` →
`aliases.sh` → `init.sh` → `functions.sh`. `functions.sh` globs every file in
`fns/`, so **a new shell function is just a new file in
`bash/.config/bash/fns/`** — nothing to register. `OMARCHY_PATH` defaults to
`/usr/share/omarchy`, overridden via `/etc/omarchy.conf` when `omarchy-dev-link`
is active.

**hypr** — `hyprland.lua` runs Omarchy's bootstrap, requires Omarchy's defaults,
then the personal overrides. The `hl` and `o` globals come from Omarchy's
helpers; `.luarc.json` declares them for the LSP and is kept out of `$HOME` by
`hypr/.stow-local-ignore`.

Window placement is declarative across three files, so a window lands in the same
place no matter what opened it:

- `monitors.lua` — workspace → monitor, and which workspaces scroll
- `windows.lua` — window class → workspace (matched once, at open)
- `hypr/.local/bin/ws-layout` — only _launches_. Order matters: scrolling-layout
  columns appear in open order, so the script waits for each window before
  starting the next.

`autostart.lua` runs `ws-layout` at login through `o.launch_on_start`, which
wraps it in `uwsm-app --` and starts it from the compositor's environment. Every
launcher in the script is launch-or-focus, so re-running it by hand is safe.

Three things about `ws-layout` are not obvious from reading it:

- **A TUI needs a terminal host to get a class.** `herdr` and the docker TUI have
  no window flags of their own, so they go through the `tui()` helper →
  `omarchy-launch-or-focus-tui --app-id=<class>`, which is what supplies the
  string `windows.lua` matches on. Only that app-id is pinned — a herdr window
  opened by hand (`SUPER + CTRL + ENTER`) keeps the shared
  `com.mitchellh.ghostty` class and lands wherever you already are.
- **It unsets `HERDR_*` before launching anything.** herdr refuses to start when
  it sees `HERDR_PANE_ID` ("nested herdr is disabled by default"), which is
  exactly what happens if you run `ws-layout` from inside a herdr pane. Login and
  a plain terminal are already clean; the unset only covers that case.
- **Do not run `shfmt` on it, and keep edits below the header.** It is
  hand-formatted with compact one-line function bodies, so `shfmt -i 2 -ci -bn -d`
  reports a large diff against the file as it stands. `--help` prints
  `sed -n '2,16p' "$0"`, so inserting lines in the header block silently truncates
  it. `bash -n` and `shellcheck` are clean — keep them that way.

**Web apps** — a "web app" is Chromium's `--app=<url>` mode, launched by
`omarchy-launch-webapp`. It is the only way to give a browser window its own
Hyprland class; plain `chromium` windows all share one class and can't be placed.
Chromium derives the class as `chrome-<host>_<path, / → _>-Profile_1`, dropping
port, query and fragment — so `https://github.com/a-yose` becomes
`chrome-github.com__a-yose-Profile_1`, the double underscore being the joiner
plus the path's leading slash. Derive it, then **confirm it** with
`hyprctl activewindow -j | jq '{class, title}'`: it is the load-bearing string in
three places at once.

- `hypr/.local/bin/ws-layout` — the `webapp` launch line
- `hypr/.config/hypr/windows.lua` — the workspace rule
- `hypr/.config/hypr/bindings.lua` — the launch-or-focus keybinding

The `.desktop` entries live in `~/.local/share/applications`, which is **not
stowed**, so they are not in this repo at all. `install-webapps.sh` in
`~/omarchy-setup` owns them: a `name|url|icon` list, one line per app, skipped
when the file already exists. That entry only puts the app in the launcher
(`SUPER + SPACE`) — it plays no part in the class, so the layout and the
keybindings work with or without it. Leave `icon` empty to fetch the site's own
favicon; set it when that can't work on a fresh machine, as with the local
Supabase URL whose `127.0.0.1` port won't be listening.

**Dygma keyboard** — `dygma/backups/Defy/*.json` are generated, never
hand-edited. The `dygsync` function (`bash/.config/bash/fns/dygma-sync.sh`)
copies the newest Bazecor backup in and prunes to the 5 newest; the `dygma-watch`
service sources that same function and runs it on inotify events, so the logic
exists in one place.

**nvim** is kickstart.nvim based and is often worked on as its own project (it
has its own `.claude/settings.local.json`). Specs live in
`lua/kickstart/plugins/` (upstream-shaped) and `lua/custom/plugins/`,
auto-imported by glob.

## Conventions

- Comments explain **why**, and name the specific breakage when a setting is a
  workaround — see the `LIBVA_DRIVER_NAME` note in
  `hypr/.config/hypr/hyprland.lua` and `async-backend` in
  `ghostty/.config/ghostty/overrides.conf`. Match that density.
- Bash: `set -uo pipefail` in long-running scripts — `dygma-watch` deliberately
  omits `-e` so one failed sync can't kill the watcher. Use `%h`, not `~`, in
  systemd units.
- Markdown wraps at 80 (markdownlint `MD013`). Prettier does _not_ rewrap prose
  (`proseWrap` is `preserve`), so this is manual. `README.md` has some
  pre-existing ~90-column lines; leave them unless you're editing that paragraph
  anyway.
- Git: default branch `master`, `pull.rebase = true`.
- `~/.claude/settings.json` (stowed from `claude/`) **denies** the git write
  commands (`add`, `commit`, `push`, `rebase`) and `lazygit` — committing is done
  by hand, not by Claude. Sandbox writes are limited to `~/dotfiles` and
  `~/omarchy-setup`.
- Path shortcuts from `envs.sh`: `$DF`, `$OMS`, `$HC`.
