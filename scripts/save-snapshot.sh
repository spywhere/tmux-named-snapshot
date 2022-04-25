#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

main() {
  local name="$1"
  local resurrect_save_script_path="$(get_tmux_option "$resurrect_save_path_option" "")"
  if [ -n "$resurrect_save_script_path" ] && [ -n "$name" ]; then
    local last_file="$(last_resurrect_file)"
    local original_path="$(last_resurrect_path)"
    local name_path="$(resurrect_dir)/$name"

    "$resurrect_save_script_path" "quiet" >/dev/null 2>&1
    local last_snapshot="$(last_resurrect_path)"

    if files_differ "$name_path" "$last_snapshot"; then
      ln -fs "$last_snapshot" "$name_path"
    fi

    if [ -n "$original_path" ]; then
      ln -fs "$original_path" "$last_file"
    fi
  fi
}

main "$@"
