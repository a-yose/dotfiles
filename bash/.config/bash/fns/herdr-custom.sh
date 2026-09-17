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
  local left_pane middle_pane diff_pane
  left_pane="$HERDR_PANE_ID"
  herdr tab rename "$HERDR_TAB_ID" "$(basename "$current_dir")" >/dev/null
  middle_pane=$(_herdr_split "$left_pane" right 0.3333 "$current_dir")
  diff_pane=$(_herdr_split "$middle_pane" right 0.5 "$current_dir")
  herdr pane run "$diff_pane" "hunk diff --watch" >/dev/null
}
