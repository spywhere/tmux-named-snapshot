# tmux-named-snapshot

This plugin allows you to save and restore
[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) snapshots
under stable names, making it easy to keep track of different tmux session
setups.

It also provides native tmux menus to list, restore, rename, and delete named
snapshots.

## Getting Started

This plugin is shipped with these key bindings:

- `Prefix + Ctrl-m` (or `Prefix + Enter`): Save the `manual` snapshot
- `Prefix + M`: Prompt for a name and save a snapshot under that name
- `Prefix + Ctrl-n`: Restore the `manual` snapshot
- `Prefix + N`: Prompt for a name and restore that snapshot
- `Prefix + R`: Select a snapshot from a list and restore it
- `Prefix + S`: Open the snapshot management menu

The management menu lists named snapshots. Selecting one opens an actions menu
with:

- Restore
- Rename
- Delete

Deleting a named snapshot also deletes its underlying `tmux-resurrect` save
file when no other named snapshot points to that same file. If the deleted
file was the target of tmux-resurrect's `last` symlink, `last` is repointed to
the newest remaining `tmux_resurrect_*.txt` file. If no save files remain,
`last` is removed, which is the same state as a fresh tmux-resurrect
installation before its first save.

Check the [Configurations](#configurations) section below to customize the key
bindings and other options.

## Configurations

- `@named-snapshot-save`
Description: A list of key mappings to be bound to the save command
Default: `C-m:manual Enter:manual M:*`
Values: A space-separated list of colon-separated `key:snapshot` mappings

- `@named-snapshot-restore`
Description: A list of key mappings to be bound to the restore command
Default: `C-n:manual N:* R:?`
Values: A space-separated list of colon-separated `key:snapshot` mappings

Each mapping consists of a key and its corresponding snapshot name. For
example, `C-m:manual` maps the `manual` snapshot to `C-m`.

Two special snapshot names are available in mappings:

- `*`: Prompt for a snapshot name before performing the action
- `?`: For restore mappings only, open the snapshot selection menu

You can map multiple key bindings to the same snapshot name.

- `@named-snapshot-manage`
Description: Key binding used to open the snapshot management menu
Default: `S`
Value: A tmux key name

- `@named-snapshot-switch-client`
Description: A specification of an optional
[switch-client](https://man7.org/linux/man-pages/man1/tmux.1.html)
key binding to define all save, restore, and management bindings in a separate
key table
Default: _Empty_ (not used by default)
Values: A colon-separated `key:table_name` string

- `@named-snapshot-dir`
Description: A path, without a trailing slash, used to store named snapshot
symlinks. The directory is **not** created automatically.
Default: _Empty_ (defaults to the `@resurrect-dir` option)
Value: A filesystem path

Snapshot names must be single path components. Empty names, `.`, `..`, `last`,
names containing `/`, and names containing line breaks are rejected.

### Examples

To set up key bindings, put the configuration in `.tmux.conf`.

For example:

```tmux
set -g @named-snapshot-save 'C-m:manual M:* C-d:dev'
set -g @named-snapshot-restore 'C-n:manual N:* R:? D:dev'
set -g @named-snapshot-manage 'S'
```

This creates the following bindings:

- `Prefix + Ctrl-m`: Save the `manual` snapshot
- `Prefix + M`: Prompt for a name and save the snapshot under that name
- `Prefix + Ctrl-d`: Save the `dev` snapshot
- `Prefix + Ctrl-n`: Restore the `manual` snapshot
- `Prefix + N`: Prompt for a name and restore the snapshot by that name
- `Prefix + R`: Select a snapshot from a list and restore it
- `Prefix + D`: Restore the `dev` snapshot
- `Prefix + S`: Open the snapshot management menu

You can also define a separate key table for all named-snapshot bindings using
tmux's `switch-client` feature.

For example:

```tmux
set -g @named-snapshot-switch-client 'N:tns'
set -g @named-snapshot-save 'm:manual p:* d:dev'
set -g @named-snapshot-restore 'M:manual P:* R:? D:dev'
set -g @named-snapshot-manage 'S'
```

This creates:

- `Prefix + N`: Enter `Named Snapshot Mode`

While in this mode:

- `m`: Save the `manual` snapshot
- `p`: Prompt for a name and save a snapshot
- `d`: Save the `dev` snapshot
- `M`: Restore the `manual` snapshot
- `P`: Prompt for a name and restore a snapshot
- `R`: Select a snapshot from a list and restore it
- `D`: Restore the `dev` snapshot
- `S`: Open the snapshot management menu

## Installation

### Requirements

- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- Bash
- tmux 3.0 or later for the native `display-menu` snapshot menus

The existing direct save and restore commands do not depend on
`display-menu`, but the list and management features do.

The plugin also uses standard Unix tools that are normally already installed:

- `sed`
- `cut`
- `readlink`
- `cmp`
- `ln`
- `rm`
- `mv`

### Using [TPM](https://github.com/tmux-plugins/tpm)

```tmux
set -g @plugin 'spywhere/tmux-named-snapshot'
```

### Manual

Clone the repository:

```sh
git clone https://github.com/spywhere/tmux-named-snapshot ~/target/path
```

Then add this line to `.tmux.conf`:

```tmux
run-shell ~/target/path/named-snapshot.tmux
```

Reload the tmux configuration:

```sh
tmux source-file ~/.tmux.conf
```

## License

MIT
