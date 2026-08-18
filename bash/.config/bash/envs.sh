export EDITOR="nvim"
export VISUAL="nvim"
export PGDATABASE_URL="postgres://postgres:postgres@localhost:54322/postgres"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export PRETTIERD_DEFAULT_CONFIG="$HOME/.config/prettier/.prettierrc"
# Short path shortcuts. A name set by anything other than this file (system,
# Omarchy, /etc/profile.d) wins; _ENVS_SH_OWNED tracks the ones we set so
# editing a value here still takes effect in shells that inherited the old one.
set_shortcut() {
  local name="$1" value="$2"
  if [[ -v $name && " ${_ENVS_SH_OWNED-} " != *" $name "* ]]; then
    printf 'envs.sh: %s already set to %q, not overriding with %q\n' \
      "$name" "${!name}" "$value" >&2
    return 0
  fi
  export "$name=$value"
  [[ " ${_ENVS_SH_OWNED-} " == *" $name "* ]] || export _ENVS_SH_OWNED="${_ENVS_SH_OWNED-}$name "
}

set_shortcut HC "$HOME/.config/"
set_shortcut DF "$HOME/dotfiles/"
set_shortcut OMS "$HOME/omarchy-setup/"
unset -f set_shortcut
