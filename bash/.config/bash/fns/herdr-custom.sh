hdsc() {
  [[ -n $1 ]] && {
    echo "Usage: hdsc"
    return 1
  }
  [[ -z $HERDR_PANE_ID ]] && {
    echo "You must start herdr to use hdsc."
    return 1
  }
  local current_dir="${PWD}"
  local editor_pane diff_pane terminal_pane claude_pane
  editor_pane="$HERDR_PANE_ID"
  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null
  terminal_pane=$(_herdr_split "$editor_pane" down 0.5 "$current_dir")
  diff_pane=$(_herdr_split "$editor_pane" right 0.5 "$current_dir")
  claude_pane=$(_herdr_split "$terminal_pane" right 0.5 "$current_dir")
  herdr pane run "$editor_pane" "nvim" >/dev/null
  herdr pane run "$diff_pane" "hunk diff --watch" >/dev/null
  herdr pane run "$claude_pane" "claude" >/dev/null
}
