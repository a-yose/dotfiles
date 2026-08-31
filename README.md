# dotfiles

Configs symlinked into `$HOME` with GNU Stow. Each top-level dir is a package whose layout
mirrors the path under `$HOME` (`dotfiles/git/.config/git/config` → `~/.config/git/config`).

The installer lives in the other repo: `~/omarchy-setup/install-dotfiles.sh`. Adding
something here is half the job — wire it up there too, or a fresh machine won't get it.

Not every dir here is stowed. `dygma`, `Bazecor`, `profile`, `wsl-mise`, `zsh` are not in
the installer's list.

## Adding an entry

Pick the pattern first. Getting this wrong is the main way a config silently stops
working.

| Pattern                           | When                                            | Example         |
| --------------------------------- | ----------------------------------------------- | --------------- |
| `stow_package <pkg>`              | you own the whole config dir                    | `nvim`          |
| `stow_package <pkg> --no-folding` | target dir also holds files you don't own       | `git`, `claude` |
| don't stow; append an include     | Omarchy owns the file and rewrites it on update | `ghostty`       |
| `stow_package <pkg> --adopt`      | last resort — see the warning below             | `hypr`          |

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
- use the **same flags** locally as in the installer. Locally the target dir
  usually already exists, so stow won't fold either way; on a fresh machine it
  doesn't exist and stow symlinks the whole directory. The mismatch only shows
  up on the fresh machine.

Commit in both repos.

```bash
stow -D <pkg>    # unlink
stow -R <pkg>    # restow, clears stale links
```

### Configs Omarchy owns

Omarchy rewrites some of its config files on update, so stowing over one means
losing your version at the next `omarchy update`. Layer instead: keep an
overrides file in the repo and have Omarchy's config pull it in.

`ghostty` is the worked example. `overrides.conf` is stowed, and `install-dotfiles.sh`
appends the include to Omarchy's config:

```ini
config-file = ?"~/.config/ghostty/overrides.conf"
```

**The include is appended once and does not heal itself.** When Omarchy
rewrites `~/.config/ghostty/config` the line is gone, and the overrides stop
applying with no error. Re-run `install-dotfiles.sh` to restore it.

```bash
grep -n overrides.conf ~/.config/ghostty/config
```

### `hypr` is stowed `--adopt`

`--adopt` overwrites **the repo's** copy with whatever is on the machine, then
links it. On a fresh install that means Omarchy's stock templates land on top of
your config.

`install-dotfiles.sh` prints what it adopted, but `master-install.sh` keeps going
and exits 0 — so it scrolls past. After any install run:

```bash
git -C ~/dotfiles status --short -- hypr/
git -C ~/dotfiles diff -- hypr/
git -C ~/dotfiles checkout -- hypr/    # discard adopted stock templates
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
in `master-install.sh`. Order matters: **after** `install-dotfiles` for anything
needing stowed files to already exist (services, unit files), **before** it for
anything that writes a config `install-dotfiles.sh` then has to patch, or the
patch is overwritten. `install-ghostty.sh` sits after and is safe only because
Omarchy seeds that config at base install, so its `command -v ghostty` check
short-circuits.

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

## Checks

`~/omarchy-setup/bashrc-drift-check` verifies `~/.bashrc` is the stowed symlink
and still sources `~/.config/bash/rc.sh`. It is not wired into
`master-install.sh` — run it by hand.
