# Package notes

Only the packages with non-obvious internals. Hyprland has its own file:
[hyprland.md](hyprland.md).

## bash

`bash/.bashrc` sources `$OMARCHY_PATH/default/bash/rc` first, then
`~/.config/bash/rc.sh`, which sources in fixed order: `envs.sh` → `shell.sh` →
`aliases.sh` → `init.sh` → `functions.sh`. `functions.sh` globs every file in
`fns/`, so **a new shell function is just a new file in
`bash/.config/bash/fns/`** — nothing to register.

`OMARCHY_PATH` defaults to `/usr/share/omarchy`, overridden via
`/etc/omarchy.conf` when `omarchy-dev-link` is active.

Path shortcuts from `envs.sh`: `$DF`, `$OMS`, `$HC`.

## ghostty

Only `overrides.conf` is ours. Omarchy owns `~/.config/ghostty/config` and
rewrites it on update — see the append-once hazard in [stow.md](stow.md).

## dygma

`dygma/backups/Defy/*.json` are generated, never hand-edited. The `dygsync`
function (`bash/.config/bash/fns/dygma-sync.sh`) copies the newest Bazecor
backup in and prunes to the 5 newest; the `dygma-watch` service sources that
same function and runs it on inotify events, so the logic exists in one place.

## nvim

kickstart.nvim based, and often worked on as its own project. Specs live in
`lua/kickstart/plugins/` (upstream-shaped) and `lua/custom/plugins/`,
auto-imported by glob.
