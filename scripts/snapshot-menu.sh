#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"
source "$CURRENT_DIR/variables.sh"

menu_page_size() {
  local height
  local size

  height="$(tmux display-message -p '#{client_height}' 2>/dev/null)"
  case "$height" in
    ''|*[!0-9]*) height=24 ;;
  esac

  size=$((height - 6))
  [ "$size" -lt 1 ] && size=1
  [ "$size" -gt 20 ] && size=20
  printf '%s\n' "$size"
}

load_snapshots() {
  SNAPSHOTS=()
  local name

  while IFS= read -r name; do
    SNAPSHOTS[${#SNAPSHOTS[@]}]="$name"
  done < <(list_snapshots)
}

show_list_menu() {
  local mode="$1"
  local page="${2:-0}"
  local page_size
  local total
  local pages
  local start
  local end
  local index
  local title
  local name
  local label
  local command
  local -a args

  load_snapshots
  total=${#SNAPSHOTS[@]}

  if [ "$total" -eq 0 ]; then
    tmux display-message "No named snapshots"
    return 0
  fi

  page_size="$(menu_page_size)"
  pages=$(((total + page_size - 1) / page_size))

  case "$page" in
    ''|*[!0-9]*) page=0 ;;
  esac
  [ "$page" -ge "$pages" ] && page=$((pages - 1))

  start=$((page * page_size))
  end=$((start + page_size))
  [ "$end" -gt "$total" ] && end="$total"

  if [ "$mode" = "restore" ]; then
    title="Restore Snapshot"
  else
    title="Manage Snapshots"
  fi
  if [ "$pages" -gt 1 ]; then
    title="$title ($((page + 1))/$pages)"
  fi

  args=(display-menu -T "$title")

  index="$start"
  while [ "$index" -lt "$end" ]; do
    name="${SNAPSHOTS[$index]}"
    label="$(escape_tmux_format "$name")"

    if [ "$mode" = "restore" ]; then
      command="run-shell '$CURRENT_DIR/restore-snapshot.sh --index $index'"
    else
      command="run-shell '$CURRENT_DIR/snapshot-menu.sh actions $index'"
    fi

    args+=("$label" "" "$command")
    index=$((index + 1))
  done

  if [ "$page" -gt 0 ]; then
    args+=("< Previous" "p" "run-shell '$CURRENT_DIR/snapshot-menu.sh $mode $((page - 1))'")
  fi
  if [ "$page" -lt $((pages - 1)) ]; then
    args+=("Next >" "n" "run-shell '$CURRENT_DIR/snapshot-menu.sh $mode $((page + 1))'")
  fi

  tmux "${args[@]}"
}

show_actions_menu() {
  local index="$1"
  local name
  local title

  name="$(snapshot_name_by_index "$index")" || {
    tmux display-message "Snapshot not found"
    return 1
  }

  title="Snapshot: $(escape_tmux_format "$name")"

  tmux display-menu -T "$title" \
    "Restore" "r" "run-shell '$CURRENT_DIR/restore-snapshot.sh --index $index'" \
    "Rename" "n" "run-shell '$CURRENT_DIR/snapshot-menu.sh rename-prompt $index'" \
    "Delete" "d" "run-shell '$CURRENT_DIR/snapshot-menu.sh confirm-delete $index'"
}

rename_prompt() {
  local index="$1"
  local name
  local prompt
  local template

  name="$(snapshot_name_by_index "$index")" || {
    tmux display-message "Snapshot not found"
    return 1
  }

  set_tmux_option "$pending_rename_from_option" "$name"
  unset_tmux_option "$pending_rename_to_option"

  prompt="Rename snapshot '$name' to:"
  template="set-option -gq $pending_rename_to_option \"%%%\" ; run-shell '$CURRENT_DIR/rename-snapshot.sh --pending'"
  tmux command-prompt -p "$prompt" "$template"
}

confirm_delete() {
  local index="$1"
  local name
  local prompt

  name="$(snapshot_name_by_index "$index")" || {
    tmux display-message "Snapshot not found"
    return 1
  }

  prompt="Delete snapshot '$name'? (y/n)"
  tmux confirm-before -p "$prompt" "run-shell '$CURRENT_DIR/delete-snapshot.sh --index $index'"
}

case "$1" in
  restore)
    show_list_menu restore "${2:-0}"
    ;;
  manage)
    show_list_menu manage "${2:-0}"
    ;;
  actions)
    show_actions_menu "$2"
    ;;
  rename-prompt)
    rename_prompt "$2"
    ;;
  confirm-delete)
    confirm_delete "$2"
    ;;
  list)
    list_snapshots
    ;;
  *)
    tmux display-message "Unknown snapshot menu action"
    exit 1
    ;;
esac
