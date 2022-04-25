# tmux-named-snapshot

This plugin will allow you to save and restore
[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) snapshots
into its own separate snapshot, making it easy to keep track of tmux session setup.

### Key Bindings

- `@named-snapshot-save`  
Description: A list of key mapping to be bound to save command  
Default: `C-m:manual`  
Values: a space separated keymap, in which consists of comma separated strings
- `@named-snapshot-restore`  
Description: A list of key mapping to be bound to restore command  
Default: `C-n:manual`  
Values: a space separated keymap, in which consists of comma separated strings

Each mapping should consists of key and its corresponding snapshot name. So
a mapping of `C-m:manual` will map a `manual` snapshot to `C-m` key binding.

You can always map multiple key bindings to the same snapshot name.

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
