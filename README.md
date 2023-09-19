# tmux-named-snapshot

This plugin will allow you to save and restore
[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) snapshots
into its own separate snapshot, making it easy to keep track of tmux session setup.

## Getting Started

This plugin is shipped with these key bindings

- `Prefix + Ctrl-m`: Save 'manual' snapshot
- `Prefix + M`: Prompt for a name and save the snapshot under that name
- `Prefix + Ctrl-n`: Restore 'manual' snapshot
- `Prefix + N`: Prompt for a name and restore the snapshot by that name

Check out [Configurations](#configurations) section below to customize the
key bindings and any additional options.

## Configurations

- `@named-snapshot-save`  
Description: A list of key mapping to be bound to save command  
Default: `C-m:manual M:*`  
Values: a space separated keymap, in which consists of comma separated strings
- `@named-snapshot-restore`  
Description: A list of key mapping to be bound to restore command  
Default: `C-n:manual N:*`  
Values: a space separated keymap, in which consists of comma separated strings

Each mapping should consists of key and its corresponding snapshot name. So
a mapping of `C-m:manual` will map a `manual` snapshot to `C-m` key binding.

A special snapshot name `*` will prompt for a snapshot name before
performing the action.

You can always map multiple key bindings to the same snapshot name.

- `@named-snapshot-dir`  
Description: A path (without a trailing slash) to the directory for storing
named snapshots (missing directory will **NOT** be created automatically)  
Default: _Empty_ (default to `@resurrect_dir` option)  
Value: a string to be used as a path

### Examples

To setup the key bindings, the configuration should be put in `.tmux.conf`
file.

For example,

```
set -g @named-snapshot-save 'C-m:manual M:* C-d:dev'
set -g @named-snapshot-restore 'C-n:manual N:* D:dev'
```

will setup the following key bindings

- `Prefix + Ctrl-m`: Save 'manual' snapshot
- `Prefix + M`: Prompt for a name and save the snapshot under that name
- `Prefix + Ctrl-d`: Save 'dev' snapshot
- `Prefix + Ctrl-n`: Restore 'manual' snapshot
- `Prefix + N`: Prompt for a name and restore the snapshot by that name
- `Prefix + D`: Restore 'dev' snapshot

## Installation

### Requirements

Please note that this plugin utilize multiple unix tools to deliver its
functionalities (most of these tools should be already installed on most unix systems)

- `sed`
- `cut`
- `readlink`
- `cmp`

### Using [TPM](https://github.com/tmux-plugins/tpm)

```
set -g @plugin 'spywhere/tmux-named-snapshot'
```

### Manual

Clone the repo

```
$ git clone https://github.com/spywhere/tmux-named-snapshot ~/target/path
```

Then add this line into your `.tmux.conf`

```
run-shell ~/target/path/named-snapshot.tmux
```

Once you reloaded your tmux configuration, all the format strings in the status
bar should be updated automatically.

## License

MIT
