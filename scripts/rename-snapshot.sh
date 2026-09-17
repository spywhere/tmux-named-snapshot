#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

main() {
  local old_name
  local new_name
  local old_path
  local new_path

  if [ "$1" = "--pending" ]; then
    old_name="$(get_tmux_option "$pending_rename_from_option" "")"
    new_name="$(get_tmux_option "$pending_rename_to_option" "")"
    unset_tmux_option "$pending_rename_from_option"
    unset_tmux_option "$pending_rename_to_option"
  else
    old_name="$1"
    new_name="$2"
  fi

  valid_snapshot_name "$old_name" || {
    tmux display-message "Invalid snapshot name"
    return 1
  }

  valid_snapshot_name "$new_name" || {
    tmux display-message "Invalid new snapshot name"
    return 1
  }

  old_path="$(snapshot_path "$old_name")"
  new_path="$(snapshot_path "$new_name")"

  if [ ! -L "$old_path" ]; then
    tmux display-message "Snapshot '$old_name' not found"
    return 1
  fi

  if [ -e "$new_path" ] || [ -L "$new_path" ]; then
    tmux display-message "Snapshot '$new_name' already exists"
    return 1
  fi

  if mv "$old_path" "$new_path"; then
    tmux display-message "Snapshot '$old_name' renamed to '$new_name'"
  else
    tmux display-message "Could not rename snapshot '$old_name'"
    return 1
  fi
}

main "$@"
