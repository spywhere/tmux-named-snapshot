#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

resolve_name() {
  if [ "$1" = "--index" ]; then
    snapshot_name_by_index "$2"
  else
    printf '%s\n' "$1"
  fi
}

main() {
  local name
  local resurrect_restore_script_path="$(get_tmux_option "$resurrect_restore_path_option" "")"
  local last_file
  local original_path
  local target_name
  local target_file
  local restore_status

  [ -n "$resurrect_restore_script_path" ] || return 0

  name="$(resolve_name "$@")" || {
    tmux display-message "Snapshot not found"
    return 1
  }

  valid_snapshot_name "$name" || {
    tmux display-message "Invalid snapshot name"
    return 1
  }

  if ! snapshot_exists "$name"; then
    tmux display-message "Snapshot '$name' not found"
    return 1
  fi

  target_name="$(snapshot_target_name "$name" 2>/dev/null)" || {
    tmux display-message "Snapshot '$name' data not found"
    return 1
  }
  target_file="$(resurrect_dir)/$target_name"

  if [ ! -f "$target_file" ]; then
    tmux display-message "Snapshot '$name' data not found"
    return 1
  fi

  tmux display-message "Restoring snapshot '$name'..."
  last_file="$(last_resurrect_file)"
  original_path="$(last_resurrect_path)"

  ln -fs "$target_name" "$last_file" || {
    tmux display-message "Could not prepare snapshot '$name' for restore"
    return 1
  }

  "$resurrect_restore_script_path" "quiet" >/dev/null 2>&1
  restore_status=$?

  if [ -n "$original_path" ]; then
    ln -fs "$original_path" "$last_file"
  else
    rm -f "$last_file"
  fi

  if [ "$restore_status" -ne 0 ]; then
    tmux display-message "Could not restore snapshot '$name'"
    return 1
  fi

  tmux display-message "Snapshot '$name' restored"
}

main "$@"
