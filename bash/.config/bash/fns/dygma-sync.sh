# copies the newest Dygma Defy backup into the dotfiles repo and prunes older
# copies so only the N most recent (default 5) are kept.
# the device-id subfolder under ~/Dygma/Backups/Defy can change, so the newest
# file is searched for across every subfolder.
dygsync() {
  local src_root="${DYGMA_BACKUP_DIR:-$HOME/Dygma/Backups/Defy}"
  local dest="${DYGMA_DOTFILES_DIR:-$HOME/dotfiles/dygma/backups/Defy}"
  local keep="${1:-5}"

  [[ $keep =~ ^[1-9][0-9]*$ ]] || {
    echo "usage: dygsync [keep_count]" >&2
    return 1
  }
  [[ -d $src_root ]] || {
    echo "dygsync: no backup dir at $src_root" >&2
    return 1
  }

  local newest
  newest=$(find "$src_root" -type f -name '*.json' -printf '%T@\t%p\n' 2>/dev/null |
    sort -rn | head -1 | cut -f2-)
  [[ -n $newest ]] || {
    echo "dygsync: no backups found under $src_root" >&2
    return 1
  }

  mkdir -p "$dest" || return 1

  if [[ -e $dest/${newest##*/} ]]; then
    echo "dygsync: ${newest##*/} already saved"
  else
    # -p keeps the mtime so the prune below sorts the same as the source
    cp -p "$newest" "$dest/" || return 1
    echo "dygsync: saved ${newest##*/}"
  fi

  local -a stale
  mapfile -t stale < <(find "$dest" -maxdepth 1 -type f -name '*.json' -printf '%T@\t%p\n' |
    sort -rn | tail -n +$((keep + 1)) | cut -f2-)
  if ((${#stale[@]})); then
    rm -f "${stale[@]}"
    printf 'dygsync: removed %s\n' "${stale[@]##*/}"
  fi
}
