#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

main() {
  local name="$1"
  local resurrect_save_script_path="$(get_tmux_option "$resurrect_save_path_option" "")"
  local last_file
  local original_path
  local last_snapshot
  local target_file
  local name_path

  [ -n "$resurrect_save_script_path" ] || return 0

  valid_snapshot_name "$name" || {
    tmux display-message "Invalid snapshot name"
    return 1
  }

  name_path="$(snapshot_path "$name")"
  if [ -e "$name_path" ] && [ ! -L "$name_path" ]; then
    tmux display-message "Cannot overwrite '$name': path is not a named snapshot"
    return 1
  fi

  tmux display-message "Saving snapshot '$name'..."

  last_file="$(last_resurrect_file)"
  original_path="$(last_resurrect_path)"

  "$resurrect_save_script_path" "quiet" >/dev/null 2>&1

  last_snapshot="$(last_resurrect_path)"
  if [ -z "$last_snapshot" ] || [ ! -f "$last_file" ]; then
    if [ -n "$original_path" ]; then
      ln -fs "$original_path" "$last_file"
    fi
    tmux display-message "Could not save snapshot '$name'"
    return 1
  fi

  target_file="$(readlink -f "$last_file")"
  if [ -z "$target_file" ] || [ ! -f "$target_file" ]; then
    if [ -n "$original_path" ]; then
      ln -fs "$original_path" "$last_file"
    fi
    tmux display-message "Could not find saved tmux-resurrect snapshot"
    return 1
  fi

  if ! mkdir -p "$(snapshot_dir)"; then
    if [ -n "$original_path" ]; then
      ln -fs "$original_path" "$last_file"
    fi
    tmux display-message "Could not create named snapshot directory: $(snapshot_dir)"
    return 1
  fi

  if ! ln -fs "$target_file" "$name_path"; then
    if [ -n "$original_path" ]; then
      ln -fs "$original_path" "$last_file"
    fi
    tmux display-message "Could not save snapshot '$name'"
    return 1
  fi

  if [ -n "$original_path" ]; then
    ln -fs "$original_path" "$last_file"
  fi

  tmux display-message "Snapshot '$name' saved"
}

main "$@"
