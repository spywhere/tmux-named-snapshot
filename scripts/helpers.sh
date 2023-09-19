if [ -d "$HOME/.tmux/resurrect" ]; then
  default_resurrect_dir="$HOME/.tmux/resurrect"
else
  default_resurrect_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/tmux/resurrect
fi

set_tmux_option() {
  local option=$1
  local value=$2
  tmux set-option -gq "$option" "$value"
}

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-option -qv "$option")"
  if [ -z "$option_value" ]; then
    option_value="$(tmux show-option -gqv "$option")"
  fi
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

resurrect_dir() {
  if [ -z "$_RESURRECT_DIR" ]; then
    local path="$(get_tmux_option "$resurrect_dir_option" "$default_resurrect_dir")"
    # expands tilde, $HOME and $HOSTNAME if used in $resurrect-dir
    echo "$path" | sed "s,\$HOME,$HOME,g; s,\$HOSTNAME,$(hostname),g; s,\~,$HOME,g"
  else
    echo "$_RESURRECT_DIR"
  fi
}

snapshot_dir() {
  local path="$(get_tmux_option "$snapshot_dir_option" "$(resurrect_dir)")"
  echo "$path" | sed "s,\$HOME,$HOME,g; s,\$HOSTNAME,$(hostname),g; s,\~,$HOME,g"
}

last_resurrect_file() {
  echo "$(resurrect_dir)/last"
}

last_resurrect_path() {
  readlink "$(last_resurrect_file)"
}

check_last_snapshot_exists() {
  local resurrect_file=$(last_resurrect_file)
  if [ ! -f "$resurrect_file" ]; then
    return 1
  fi
}

files_differ() {
  ! cmp -s "$1" "$2"
}
