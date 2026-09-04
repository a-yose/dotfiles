# Stow packages

Every top-level directory is a GNU Stow package whose layout mirrors `$HOME`:
`git/.config/git/config` → `~/.config/git/config`.

`README.md` has the step-by-step procedures — [adding an
entry](../../README.md#adding-an-entry), [adding a user
service](../../README.md#adding-a-user-service), [removing a user
service](../../README.md#removing-a-user-service), and
[checks](../../README.md#checks). This file is the model behind them.

## The two-repo contract

The installer is not in this repo. It lives in `~/omarchy-setup/`:
`install-dotfiles.sh` (clones/pulls and stows), `master-install.sh` (runs every
`install-*.sh`), and `install-webapps.sh` (the Chromium web-app launchers, which
are not stowed — see [hyprland.md](hyprland.md)).

Adding a package here is half the job. Without a `stow_package <pkg>` line in
`install-dotfiles.sh`, a fresh machine silently won't get it. **Nothing enforces
this** — no check compares the package dirs here against that file. Changes
usually mean a commit in both repos.

`OLD_CONFIGS` in that script lists paths deleted before stowing, so a stock
Omarchy file doesn't cause a stow conflict. A new package whose target already
exists on a fresh machine needs its `$HOME` path added there.

## Three stow patterns, not one

| Pattern                                              | Packages                                               |
| ---------------------------------------------------- | ------------------------------------------------------ |
| plain                                                | `bash`, `nvim`, `prettier`, `markdownlint`, `ghostty`  |
| `--no-folding` — target dir holds files we don't own | `ssh`, `git`, `mise`, `herdr`, `claude`, `dygma-watch` |
| `--no-folding --adopt`                               | `hypr`                                                 |

Use the **same flags** locally as the installer uses. Locally the target dir
usually already exists so stow won't fold either way; on a fresh machine it
doesn't, and the mismatch only shows up there.

Tracked but **never stowed**: `dygma`, `Bazecor`, `profile`, `wsl-mise`, `zsh` —
backups and other-machine configs.

## Two hazards

- **`hypr` uses `--adopt`**, which overwrites the _repo_ with machine state, so
  a fresh install lands Omarchy's stock templates on top of the real config.
  `master-install.sh` exits 0 either way, so it scrolls past. After any install
  run, check `git status --short -- hypr/`; recovery is in
  [README](../../README.md#hypr-is-stowed---adopt).
- **`ghostty` is stowed _and_ patched.** `overrides.conf` is a normal stowed
  file, but it only applies because `install-dotfiles.sh` appends a
  `config-file = ?"~/.config/ghostty/overrides.conf"` line to Omarchy's
  `~/.config/ghostty/config`. Omarchy rewrites that file on update and the
  append does not heal itself. Verify with
  `grep -n overrides.conf ~/.config/ghostty/config`; restore by re-running
  `install-dotfiles.sh`.

## Commands

```bash
cd ~/dotfiles
stow -n -v <pkg>     # dry run — always first
stow <pkg>           # link (use the same flags the installer uses)
stow -R <pkg>        # restow; clears stale links after moving files
stow -D <pkg>        # unlink
```
