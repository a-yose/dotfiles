# Conventions

## Formatting and linting

No runner — invoke directly. `shfmt`, `shellcheck` and `prettier` come from mise
(`mise/.config/mise/config.toml`); `stylua` and `markdownlint` are mason
binaries and neither is on `PATH`.

```bash
shfmt -i 2 -ci -bn -w <script>   # flags match the nvim conform config
shellcheck <script>
stylua <file>.lua                # nvim + hypr lua; .stylua.toml is nvim-only
prettier --write <file>          # prettier/.config/prettier/.prettierrc
~/.local/share/nvim/mason/bin/markdownlint <file>.md
```

Every shell script here is `shfmt`-formatted — run it before committing. There
are no hand-formatted exceptions.

`install-prettier.sh` and `install-sh-fmt.sh` in `~/omarchy-setup` pin the same
versions as mise does, so a version bump means changing both.

## Style

- Comments explain **why**, and name the specific breakage when a setting is a
  workaround — see the `LIBVA_DRIVER_NAME` note in
  `hypr/.config/hypr/hyprland.lua` and `async-backend` in
  `ghostty/.config/ghostty/overrides.conf`. Match that density.
- Bash: `set -uo pipefail` in long-running scripts — `dygma-watch` deliberately
  omits `-e` so one failed sync can't kill the watcher.
- Use `%h`, not `~`, in systemd units.
- Markdown wraps at 80 (markdownlint `MD013`). Prettier does _not_ rewrap prose
  (`proseWrap` is `preserve`), so this is manual. `README.md` has some
  pre-existing ~90-column lines; leave them unless you're editing that paragraph
  anyway.
