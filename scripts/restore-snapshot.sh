#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

main() {
  local name="$1"
  local resurrect_restore_script_path="$(get_tmux_option "$resurrect_restore_path_option" "")"
  if [ -n "$resurrect_restore_script_path" ] && [ -n "$name" ]; then
    tmux display-message "Restoring snapshot '$name'..."
    local last_file="$(last_resurrect_file)"
    local original_path="$(last_resurrect_path)"
    local name_path="$(snapshot_dir)/$name"

    if [[ -L "$name_path" ]]; then
      local last_snapshot="$(readlink "$name_path")"
      ln -fs "$last_snapshot" "$last_file"
      "$resurrect_restore_script_path" "quiet" >/dev/null 2>&1
      ln -fs "$original_path" "$last_file"
    else
      tmux display-message "Snapshot '$name' not found"
    fi
  fi
}

main "$@"
