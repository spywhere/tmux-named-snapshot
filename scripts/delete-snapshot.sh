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
  local name_path
  local target_name
  local target_file
  local last_file
  local last_target
  local last_target_name=""
  local latest_snapshot

  name="$(resolve_name "$@")" || {
    tmux display-message "Snapshot not found"
    return 1
  }

  valid_snapshot_name "$name" || {
    tmux display-message "Invalid snapshot name"
    return 1
  }

  name_path="$(snapshot_path "$name")"
  if [ ! -L "$name_path" ]; then
    tmux display-message "Snapshot '$name' not found"
    return 1
  fi

  target_name="$(snapshot_target_name "$name" 2>/dev/null)" || {
    rm -f "$name_path"
    tmux display-message "Snapshot '$name' deleted; snapshot data was not recognized"
    return 0
  }

  target_file="$(resurrect_dir)/$target_name"
  last_file="$(last_resurrect_file)"
  last_target="$(last_resurrect_path)"
  if [ -n "$last_target" ]; then
    last_target_name="${last_target##*/}"
  fi

  if ! rm -f "$name_path"; then
    tmux display-message "Could not delete snapshot '$name'"
    return 1
  fi

  if other_snapshot_references_target "$target_name" "$name"; then
    tmux display-message "Snapshot '$name' deleted"
    return 0
  fi

  if [ -e "$target_file" ] && ! rm -f "$target_file"; then
    tmux display-message "Snapshot '$name' link deleted, but snapshot data could not be removed"
    return 1
  fi

  if [ "$last_target_name" = "$target_name" ]; then
    rm -f "$last_file"

    latest_snapshot="$(latest_resurrect_snapshot_name 2>/dev/null)" || latest_snapshot=""
    if [ -n "$latest_snapshot" ]; then
      ln -fs "$latest_snapshot" "$last_file"
    fi
  fi

  tmux display-message "Snapshot '$name' deleted"
}

main "$@"
