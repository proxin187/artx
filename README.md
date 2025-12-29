# Artx

Artx is an opinionated install script for setting up a minimal dwm environment on Artix systems.

## Installation

This script is intended for use on a fresh Artix Linux runit base install.

### Prerequisites:
- A working internet connection.
- Base system installed with runit.

### Install:

```bash
$ curl -L https://github.com/proxin187/artx/raw/refs/heads/main/install.sh | sh
```

After installation completes, restart your system and run `startx` to launch dwm.

## Features

### dwm ([flexipatch](https://github.com/bakkeby/dwm-flexipatch))
Patched with:
- BAR_STATUSCMD - Execute shell commands on mouse events inside statusbar
- BAR_STATUS2D - Allow colors in statusbar
- BAR_UNDERLINETAGS - Underline on selected tag
- BAR_IGNORE_XFT_ERRORS_WHEN_DRAWING_TEXT - Ignore xft errors
- BAR_STATUSPADDING - Horizontal and vertical padding in the statusbar
- COOL_AUTOSTART - Execute a set of commands on startup, automatically kill them on exit
- RESTARTSIG - Adds a keyboard shortcut to restart dwm
- ROTATESTACK - Rotate the stack with keyboard shortcuts
- SEAMLESS_RESTART - Persists windows and layout across window manager restarts

Includes a multi-threaded C statusbar [dwm-statusbar.c](https://github.com/proxin187/artx/blob/main/dwm/dwm-statusbar.c) with volume controls via amixer.

### st ([flexipatch](https://github.com/bakkeby/st-flexipatch))
Patched with:
- SCROLLBACK - Buffer scrolling support
- SCROLLBACK_MOUSE_ALTSCREEN - Mouse scrolling
- SIXEL - Sixel graphics

### Doas
Artx replaces sudo with [opendoas](https://github.com/Duncaen/OpenDoas), a small alternative to sudo. doas acts as a drop-in replacement through /usr/local/bin/sudo, a bash script that executes doas and filters any arguments that are incompatible with doas.

### Yazi
Artx will install [yazi](https://github.com/sxyazi/yazi), a terminal file manager with support for image previews though sixel graphics, code highlighting in previews, and much more.

### Neovim
Artx will install [neovim](https://github.com/neovim/neovim), a modern vim fork. Artx has a vimscript based config, vimscript is outdated, but why use lua when vimscript works perfectly fine.

### Audio
Artx uses ALSA for minimal, low-latency audio with zero overhead. This comes at the expense of limited audio mixing capabilities - multiple audio sources playing simultaneously may not work as expected. You will get the option to disable alsa powersaving, the option to disable alsa restore on boot and the ability to select the default volume configuration that gets set on boot if you disable alsa restore.

### Colorscheme
Uses the [Moonfly](https://github.com/bluz71/vim-moonfly-colors) theme.

## Keybindings

*These keybindings are optimized for colemak-dh.*

### dwm keybindings

| Keybinding | Action | Category |
|------------|--------|----------|
| `Super + d` | Launch dmenu | Launch |
| `Super + q` | Kill focused window | Window |
| `Super + Shift + q` | Quit DWM | System |
| `Super + Shift + w` | Restart DWM (statusbar causes 5-10s delay) | System |
| `Super + l` | Focus next window | Navigation |
| `Super + h` | Focus previous window | Navigation |
| `Super + Period` | Rotate stack up | Layout |
| `Super + Comma` | Rotate stack down | Layout |
| `Super + Shift + l` | Move window down | Window |
| `Super + Shift + h` | Move window up | Window |
| `Super + Shift + a` | Move to tag 1 | Tags |
| `Super + Shift + r` | Move to tag 2 | Tags |
| `Super + Shift + s` | Move to tag 3 | Tags |
| `Super + Shift + t` | Move to tag 4 | Tags |
| `Super + a` | View tag 1 | Tags |
| `Super + r` | View tag 2 | Tags |
| `Super + s` | View tag 3 | Tags |
| `Super + t` | View tag 4 | Tags |

### yazi keybindings

| Keybinding | Action | Category |
|------------|--------|----------|
| `q` | Quit | File manager |
| `n` | Move cursor down | File manager |
| `e` | Move cursor up | File manager |
| `h` | Go to parent directory | File manager |
| `l` | Enter directory | File manager |
| `a` | Create a file or directory | File manager |
| `r` | Rename a file or directory | File manager |
| `d` | Delete a file or directory | File manager |

### neovim keybindings

*These are only the keybindings that are unique for artx, everything else is the same as normal*

| Keybinding | Action | Category |
|------------|--------|----------|
| `n` | Move cursor down | Movement |
| `e` | Move cursor up | Movement |
| `t` | Move one word to the right | Movement |
| `s` | Move one word to the left | Movement |
| `j` | Change window | Window |

## Credits
The statusbar design is based on [bedwm](https://github.com/namishh/dwm). Rewrote it in C and added volume controls.

## License
Artx is licensed under the MIT license.


