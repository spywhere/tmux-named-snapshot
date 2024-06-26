#!/usr/bin/env bash

CURRENT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/scripts/variables.sh"

bind_prompt_key() {
  local action="$1"
  local key="$2"
  local switch_client="$4"
  local client_name=""

  if [[ "$action" == "save" ]]; then
    local prompt='Save Snapshot as:'
  else
    local prompt='Restore Snapshot:'
  fi
  if [ -n "$switch_client" ]; then
    client_name="$(echo "$switch_client" | cut -d':' -f2)"
    tmux bind-key -T "$client_name" "$key" command-prompt -p "$prompt" "run-shell '$CURRENT_DIR/scripts/$action-snapshot.sh %1'"
  else
    tmux bind-key "$key" command-prompt -p "$prompt" "run-shell '$CURRENT_DIR/scripts/$action-snapshot.sh %1'"
  fi
}

bind_key() {
  local action="$1"
  local key="$2"
  local name="$3"
  local switch_client="$4"

  if test "$name" = "*"; then
    bind_prompt_key "$@"
  else
    if [ -n "$switch_client" ]; then
      local client_name="$(echo "$switch_client" | cut -d':' -f2)"
      tmux bind-key -T "$client_name" "$key" run-shell "$CURRENT_DIR/scripts/$action-snapshot.sh $name"
    else
      tmux bind-key "$key" run-shell "$CURRENT_DIR/scripts/$action-snapshot.sh $name"
    fi
  fi
}

set_switch_client_table() {
  local switch_client="$1"
  local key="$(echo "$switch_client" | cut -d':' -f1)"
  local name="$(echo "$switch_client" | cut -d':' -f2)"

  tmux bind-key "$key" "switch-client -T $name; display-message 'Named Snapshot Mode'"
}

set_save_bindings() {
  local switch_client="$1"
  local key_bindings="$(get_tmux_option "$named_save_option" "$default_save_option")"
  local keymap
  for keymap in $key_bindings; do
    local key="$(echo "$keymap" | cut -d':' -f1)"
    local name="$(echo "$keymap" | cut -d':' -f2)"
    bind_key save "$key" "$name" "$switch_client"
  done
}

set_restore_bindings() {
  local switch_client="$1"
  local key_bindings="$(get_tmux_option "$named_restore_option" "$default_restore_option")"
  local keymap
  for keymap in $key_bindings; do
    local key="$(echo "$keymap" | cut -d':' -f1)"
    local name="$(echo "$keymap" | cut -d':' -f2)"
    bind_key restore "$key" "$name" "$switch_client"
  done
}

main() {
  local switch_client="$(get_tmux_option "$switch_client_option" "$default_switch_client_option")"
  if [ -n "$switch_client" ]; then
    set_switch_client_table "$switch_client"
  fi

  set_save_bindings "$switch_client"
  set_restore_bindings "$switch_client"
}

main
