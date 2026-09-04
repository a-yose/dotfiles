# CLAUDE.md

Personal dotfiles for an **Omarchy** machine (Arch + Hyprland). Every top-level
directory is a GNU Stow package whose layout mirrors `$HOME`:
`git/.config/git/config` → `~/.config/git/config`.

No build, no test suite, no application code. "Running" a change means reloading
whichever tool owns the file.

Two things that apply to every task here:

- **Files are symlinked into `$HOME`.** Editing `hypr/.config/hypr/windows.lua`
  in this repo edits the live `~/.config/hypr/windows.lua`. No deploy step — and
  no undo.
- **The installer is in the other repo**, `~/omarchy-setup/`. Adding a package
  here is half the job; a change usually means a commit in both.

Run the formatter before committing — no exceptions.

## Where things are written down

- [.claude/docs/stow.md](.claude/docs/stow.md) — stow patterns, the two-repo
  contract, and the two ways a config silently stops applying
- [.claude/docs/hyprland.md](.claude/docs/hyprland.md) — the four-file window
  placement model, web-app window classes, `hyprctl` inspection
- [.claude/docs/packages.md](.claude/docs/packages.md) — bash, ghostty, dygma
  and nvim internals
- [.claude/docs/conventions.md](.claude/docs/conventions.md) — formatter and
  linter commands, comment and style rules
- [README.md](README.md) — step-by-step procedures for adding and removing
  packages and services
