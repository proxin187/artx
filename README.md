# Artx

Artx is a minimalist install script for setting up a patched dwm and st environment on Artix systems.

## Installation

This script is intended for use on a fresh Artix Linux installation.

### Prerequisites:
- A working internet connection.
- Base system installed and booted.

### Install:

```bash
$ curl -L https://raw.githubusercontent.com/proxin187/artx/main/install.sh | sh
```

After installation completes, restart your system and run `startx` to launch dwm.

## Features

### dwm (flexipatch)
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

### st (flexipatch)
Patched with:
- SCROLLBACK - Buffer scrolling support
- SCROLLBACK_MOUSE_ALTSCREEN - Mouse scrolling

### Audio
Artx uses ALSA for minimal, low-latency audio with zero overhead. This comes at the expense of limited audio mixing capabilities - multiple audio sources playing simultaneously may not work as expected.

### Colorscheme
Uses the [Moonfly](https://github.com/bluz71/vim-moonfly-colors) theme.

## Credits

The statusbar design is based on [bedwm](https://github.com/namishh/dwm). Rewrote it in C and added volume controls.

## License
Artx is licensed under the MIT license.


