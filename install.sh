#!/bin/bash

echo "Info: Starting Artx Setup"

echo "Info: Installing doas"
sudo pacman -S --noconfirm opendoas

sudo cat > /etc/doas.conf << 'EOF'
permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel

permit nopass :wheel as root cmd poweroff
permit nopass :wheel as root cmd reboot
EOF
sudo chown -c root:root /etc/doas.conf
sudo chmod -c 0400 /etc/doas.conf

sudo cat > /usr/local/bin/sudo << 'EOF'
#!/bin/bash
doas "$@"
EOF
sudo chmod +x /usr/local/bin/sudo

doas pacman -R --noconfirm sudo

echo "Info: Installing yay AUR helper"
doas pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si --noconfirm)

echo "Info: Installing base dependencies"
doas pacman -S --noconfirm wireless_tools bash neovim yazi dmenu ttf-iosevka-nerd noto-fonts-emoji feh xorg-server xorg-xinit xorg-xsetroot libx11 libxft libxinerama libxrender libxcb alsa-utils alsa-utils-runit
yay -S --noconfirm ttf-material-design-icons-desktop-git

echo "Info: Enabling alsa runit service"
doas ln -s /etc/runit/sv/alsa /run/runit/service/

echo "Info: Cloning into Artx and building packages"
git clone https://github.com/proxin187/artx $HOME/.config/artx
cd $HOME/.config/artx

(cd dwm && doas make clean install)
(cd st && doas make clean install)

echo "Info: Setting up dotfiles"
cat > $HOME/.xinitrc << 'EOF'
#!/bin/bash
feh --bg-scale $HOME/.config/artx/wallpapers/wallpaper-5.jpg &
exec dwm
EOF
chmod +x $HOME/.xinitrc

cat > $HOME/.bashrc << 'EOF'
[[ $- != *i* ]] && return
PS1='\[\e[31m\][\[\e[33m\]\u\[\e[32m\]@\[\e[34m\]\h\[\e[0m\] \[\e[35m\]\W\[\e[31m\]]\[\e[0m\]\$ '
alias ls='ls --color=auto'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
EOF
chmod +x $HOME/.bashrc

mkdir -p $HOME/.config/yazi
cat > $HOME/.config/yazi/keymap.toml << 'EOF'
[mgr]
prepend_keymap = [
    { on = "q", run = "quit", desc = "Quit" },
    { on = "n", run = "arrow 1", desc = "Move cursor down" },
    { on = "e", run = "arrow -1", desc = "Move cursor up" },
    { on = "l", run = "leave", desc = "Go to parent directory" },
    { on = "h", run = "enter", desc = "Enter directory" },
    { on = "a", run = "create", desc = "Create a file or directory"},
    { on = "r", run = "rename", desc = "Rename a file or directory"},
    { on = "d", run = "remove --permanently", desc = "Delete a file or directory"},
]
EOF

mkdir -p $HOME/.config/nvim
cat > $HOME/.config/nvim/init.vim << 'EOF'
set nocompatible
set showmatch
set ignorecase
set mouse=v
set hlsearch
set incsearch
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set autoindent
set relativenumber
set wildmode=longest,list
filetype plugin indent on
syntax on
set clipboard=unnamedplus
set scrolloff=10
filetype plugin on
set ttyfast
set termguicolors
set nowrap
set formatoptions-=t
set list
set listchars=trail:⋅

call plug#begin()
 Plug 'ryanoasis/vim-devicons'
 Plug 'scrooloose/nerdtree'
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 Plug 'vim-airline/vim-airline-themes'
 Plug 'vim-airline/vim-airline'
 Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
call plug#end()

set background=dark
colorscheme moonfly

autocmd VimEnter * NERDTree

let g:NERDTreeMenuUp = 'e'
let g:NERDTreeMapOpenExpl = '['

noremap j <C-W>w

noremap n j
noremap e k

noremap t e
noremap s b

noremap g h
noremap m l

map N :
EOF

cat > $HOME/.config/nvim/coc-settings.json << 'EOF'
{
  "inlayHint.enable": false,
  "typescript.autoClosingTags": false
}
EOF

echo "Info: The setup is done"
echo "Note: Please restart your system before running startx"


