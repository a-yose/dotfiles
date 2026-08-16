# shows --help piped into bat for the tool that is passed as an args
# for example: hlp ls will show ls --help piped to bat
hlp() {
  [[ $# -eq 0 ]] && {
    echo "usage: hlp <command> [args...]" >&2
    return 1
  }
  command -v bat >/dev/null || {
    "$@" --help 2>&1 | ${PAGER:-less}
    return
  }
  "$@" --help 2>&1 | bat --plain --language=help
}
