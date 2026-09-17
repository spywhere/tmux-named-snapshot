if [ -d "$HOME/.tmux/resurrect" ]; then
  default_resurrect_dir="$HOME/.tmux/resurrect"
else
  default_resurrect_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/tmux/resurrect
fi

RESURRECT_FILE_PREFIX="tmux_resurrect"
RESURRECT_FILE_EXTENSION="txt"

set_tmux_option() {
  local option=$1
  local value=$2
  tmux set-option -gq "$option" "$value"
}

unset_tmux_option() {
  local option="$1"
  tmux set-option -gu "$option" 2>/dev/null || true
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
    # expands tilde, $HOME and $HOSTNAME if used in @resurrect-dir
    echo "$path" | sed "s,\$HOME,$HOME,g; s,\$HOSTNAME,$(hostname),g; s,\~,$HOME,g"
  else
    echo "$_RESURRECT_DIR"
  fi
}

snapshot_dir() {
  local path="$(get_tmux_option "$snapshot_dir_option" "$(resurrect_dir)")"
  echo "$path" | sed "s,\$HOME,$HOME,g; s,\$HOSTNAME,$(hostname),g; s,\~,$HOME,g"
}

snapshot_path() {
  echo "$(snapshot_dir)/$1"
}

last_resurrect_file() {
  echo "$(resurrect_dir)/last"
}

last_resurrect_path() {
  readlink "$(last_resurrect_file)" 2>/dev/null
}

check_last_snapshot_exists() {
  local resurrect_file="$(last_resurrect_file)"
  if [ ! -f "$resurrect_file" ]; then
    return 1
  fi
}

files_differ() {
  ! cmp -s "$1" "$2"
}

valid_snapshot_name() {
  local name="$1"

  [ -n "$name" ] || return 1
  [ "$name" != "." ] || return 1
  [ "$name" != ".." ] || return 1
  [ "$name" != "last" ] || return 1

  case "$name" in
    */*|*$'\n'*|*$'\r'*) return 1 ;;
  esac
}

snapshot_exists() {
  [ -L "$(snapshot_path "$1")" ]
}

list_snapshots() {
  local dir="$(snapshot_dir)"
  local path
  local name

  [ -d "$dir" ] || return 0

  for path in "$dir"/*; do
    [ -L "$path" ] || continue
    name="${path##*/}"
    [ "$name" = "last" ] && continue
    printf '%s\n' "$name"
  done
}

snapshot_name_by_index() {
  local wanted="$1"
  local index=0
  local name

  case "$wanted" in
    ''|*[!0-9]*) return 1 ;;
  esac

  while IFS= read -r name; do
    if [ "$index" -eq "$wanted" ]; then
      printf '%s\n' "$name"
      return 0
    fi
    index=$((index + 1))
  done < <(list_snapshots)

  return 1
}

is_resurrect_snapshot_name() {
  local name="$1"
  case "$name" in
    ${RESURRECT_FILE_PREFIX}_*.${RESURRECT_FILE_EXTENSION}) return 0 ;;
    *) return 1 ;;
  esac
}

snapshot_target_name_from_path() {
  local path="$1"
  local target
  local target_name

  [ -L "$path" ] || return 1
  target="$(readlink "$path" 2>/dev/null)" || return 1
  [ -n "$target" ] || return 1
  target_name="${target##*/}"

  is_resurrect_snapshot_name "$target_name" || return 1
  printf '%s\n' "$target_name"
}

snapshot_target_name() {
  snapshot_target_name_from_path "$(snapshot_path "$1")"
}

snapshot_target_file() {
  local target_name
  target_name="$(snapshot_target_name "$1")" || return 1
  printf '%s/%s\n' "$(resurrect_dir)" "$target_name"
}

other_snapshot_references_target() {
  local target_name="$1"
  local excluded_name="$2"
  local name
  local current_target

  while IFS= read -r name; do
    [ "$name" = "$excluded_name" ] && continue
    current_target="$(snapshot_target_name "$name" 2>/dev/null)" || continue
    if [ "$current_target" = "$target_name" ]; then
      return 0
    fi
  done < <(list_snapshots)

  return 1
}

latest_resurrect_snapshot_name() {
  local dir="$(resurrect_dir)"
  local path
  local name
  local latest=""

  [ -d "$dir" ] || return 1

  for path in "$dir"/${RESURRECT_FILE_PREFIX}_*.${RESURRECT_FILE_EXTENSION}; do
    [ -f "$path" ] || continue
    name="${path##*/}"
    if [ -z "$latest" ] || [[ "$name" > "$latest" ]]; then
      latest="$name"
    fi
  done

  [ -n "$latest" ] || return 1
  printf '%s\n' "$latest"
}

escape_tmux_format() {
  local value="$1"
  printf '%s\n' "${value//\#/\#\#}"
}
