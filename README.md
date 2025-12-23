# Artx

Artx is a minimalist install script for setting up a patched dwm and st environment on Artix systems.

## Installation

This script is intended for use on a fresh Artix Linux installation.

### Prerequisites:
- A working internet connection.
- Base system installed and booted.
- [yay](https://github.com/Jguer/yay) installed and in path.

### Run the following command as root:

```bash
$ curl -L https://raw.githubusercontent.com/proxin187/artx/main/install.sh | sh
```

## Features

### dwm (flexipatch)
Patched with:
- BAR_LTSYMBOL
- BAR_STATUS
- BAR_STATUSCMD
- BAR_STATUS2D
- BAR_TAGS
- BAR_UNDERLINETAGS
- BAR_IGNORE_XFT_ERRORS_WHEN_DRAWING_TEXT
- BAR_STATUSPADDING
- COOL_AUTOSTART
- RESTARTSIG
- ROTATESTACK
- SEAMLESS_RESTART
- VANITYGAPS
- FLEXTILE_DELUXE
- TILE
- MONOCLE

Includes a multi-threaded C statusbar (dwm-statusbar.c) with volume controls via pamixer.

### st (flexipatch)
Patched with:
- SCROLLBACK
- SCROLLBACK_MOUSE_ALTSCREEN

### Colorscheme
Uses the [Moonfly](https://github.com/bluz71/vim-moonfly-colors) theme.

## Inspiration

The statusbar design is based on [bedwm](https://github.com/namishh/dwm). Rewrote it in C and added volume controls.

## License
Artx is licensed under the MIT license.


