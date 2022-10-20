#!/usr/bin/env bash

CURRENT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"
source "$CURRENT_DIR/scripts/variables.sh"

bind_prompt_key() {
  local action="$1"
  local key="$2"
  tmux bind-key "$key" command-prompt -p 'Snapshot Name:' "run-shell '$CURRENT_DIR/scripts/$action-snapshot.sh %1'"
}

bind_key() {
  local action="$1"
  local key="$2"
  local name="$3"

  if test "$name" = "*"; then
    bind_prompt_key "$@"
  else
    tmux bind-key "$key" run-shell "$CURRENT_DIR/scripts/$action-snapshot.sh $name"
  fi
}

set_save_bindings() {
  local key_bindings="$(get_tmux_option "$named_save_option" "$default_save_option")"
  local keymap
  for keymap in $key_bindings; do
    local key="$(echo "$keymap" | cut -d':' -f1)"
    local name="$(echo "$keymap" | cut -d':' -f2)"
    bind_key save "$key" "$name"
  done
}

set_restore_bindings() {
  local key_bindings="$(get_tmux_option "$named_restore_option" "$default_restore_option")"
  local keymap
  for keymap in $key_bindings; do
    local key="$(echo "$keymap" | cut -d':' -f1)"
    local name="$(echo "$keymap" | cut -d':' -f2)"
    bind_key restore "$key" "$name"
  done
}

main() {
  set_save_bindings
  set_restore_bindings
}

main
