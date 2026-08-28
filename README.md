# dotfiles

Configs symlinked into `$HOME` with GNU Stow. Each top-level dir is a package whose layout
mirrors the path under `$HOME` (`dotfiles/git/.config/git/config` → `~/.config/git/config`).

The installer lives in the other repo: `~/omarchy-setup/install-dotfiles.sh`. Adding
something here is half the job — wire it up there too, or a fresh machine won't get it.

Not every dir here is stowed. `dygma`, `Bazecor`, `profile`, `wsl-mise`, `zsh` are not in
the installer's list.

## Adding an entry

```bash
mkdir -p ~/dotfiles/<pkg>/.config/<tool>
mv ~/.config/<tool>/<file> ~/dotfiles/<pkg>/.config/<tool>/   # move, don't copy
cd ~/dotfiles && stow -n -v <pkg>                             # dry run
stow <pkg>
```

Then in `~/omarchy-setup/install-dotfiles.sh`:

- add `stow_package <pkg>`
- add `--no-folding` if the target dir holds files you don't own (`~/.config/systemd/user`,
  `~/.local/bin`). Otherwise stow symlinks the whole directory.
- if the file already exists on a fresh machine, add its `$HOME` path to `OLD_CONFIGS`,
  or stow will hit a conflict

Commit in both repos.

```bash
stow -D <pkg>    # unlink
stow -R <pkg>    # restow, clears stale links
```

## Adding a user service

Package layout — stow `--no-folding`:

```
dotfiles/<pkg>/.config/systemd/user/<unit>.service
dotfiles/<pkg>/.local/bin/<script>       # chmod +x
```

Use `%h` for `$HOME` in the unit; `~` does not expand. `WantedBy=default.target` under
`[Install]` makes it start at login.

```bash
cd ~/dotfiles && stow <pkg> --no-folding
systemctl --user daemon-reload           # required after any unit edit
systemctl --user enable --now <unit>.service
systemctl --user status <unit>.service
journalctl --user -u <unit>.service -f   # stdout/stderr goes here
```

Add an `install-<name>.sh` to `~/omarchy-setup` (see `install-dygma-watch.sh`) and list it
in `master-install.sh` **after** `install-dotfiles`.

List your own services — everything else comes from packages:

```bash
ls ~/.config/systemd/user/*.service
```

## Removing a user service

Disable **before** deleting the unit file. `disable` reads `[Install]` to find the
`default.target.wants` symlink; delete the file first and that symlink is orphaned.

```bash
systemctl --user disable --now <unit>.service
cd ~/dotfiles && stow -D <pkg>        # or rm the unit file if not stowed
systemctl --user daemon-reload
systemctl --user reset-failed

rm -rf ~/dotfiles/<pkg> ~/.config/<tool> ~/.cache/yay/<package>
yay -Rns <package>
```

Un-wire the installer or `master-install.sh` will reinstall it: delete
`install-<name>.sh`, its `SCRIPTS` entry, and its `stow_package` / `OLD_CONFIGS` lines.

Confirm nothing lingers:

```bash
systemctl --user list-unit-files | grep <unit>
find ~/.config/systemd/user -name '<unit>*'
command -v <tool>
```

Leave group memberships alone unless certain — groups are shared, and an unused one is inert.
