#!/bin/bash


install_doas() {
    sudo pacman -S --noconfirm opendoas

    cat << 'EOF' | sudo tee /etc/doas.conf
permit persist setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel

permit nopass :wheel as root cmd poweroff
permit nopass :wheel as root cmd reboot
EOF
    sudo chown -c root:root /etc/doas.conf
    sudo chmod -c 0400 /etc/doas.conf

    cat << 'EOF' | sudo tee /usr/local/bin/sudo
#!/bin/bash
doas ${@//-k}
EOF
    sudo chmod +x /usr/local/bin/sudo

    doas pacman -Rdd --noconfirm sudo
}

install_alsa() {
    doas pacman -S --noconfirm alsa-utils alsa-utils-runit

    doas ln -sf /etc/runit/sv/alsa /run/runit/service/

    echo "Info: Disabling powersave"

    cat << 'EOF' | doas tee /etc/modprobe.d/alsa-disable-powersave.conf
options snd_hda_intel power_save=0 power_save_controller=N
EOF

    aplay -l

    while true
    do
        read -r -p "Enter the default card and device (format: card:device): " _cd </dev/tty

        if [[ ! "$_cd" =~ ^[0-9]+:[0-9]+$ ]]; then
            echo "Error: Invalid format: Use card:device (e.g. 1:0)"
            continue
        fi

        card=$(echo $_cd | awk -F ':' '{print $1}')
        device=$(echo $_cd | awk -F ':' '{print $2}')

        if aplay -l | awk -v c="$card" -v d="$device" '
            /^card [0-9]+:/ {
                match($0, /card ([0-9]+):/, card_match)
                match($0, /device ([0-9]+):/, dev_match)
                if (card_match[1] == c && dev_match[1] == d) {
                    found=1
                    exit
                }
            }
            END { exit !found }
        '; then
            echo "Info: Valid selection: card=$card device=$device"
            break
        else
            echo "Error: Card $card with device $device does not exist."
        fi
    done


    doas tee /etc/asound.conf > /dev/null <<EOF
pcm.!default {
    type hw
    card $card
    device $device
}

ctl.!default {
    type hw
    card $card
}
EOF

    echo "Info: Disabling restore/store"

    doas rm -f /etc/runit/sv/alsa/finish

    cat << 'EOF' | doas tee /etc/runit/sv/alsa/run
#!/bin/sh
set -e
EOF

    mapfile -t controls < <(
        amixer scontents |
        awk -F"'" '
            /Simple mixer control/ {
                if (name && has_playback && not_mic)
                    print name
                name = $2
                has_playback = 0
                not_mic = 1
            }
            /Playback/ {
                has_playback = 1
            }
            /Mic/ {
                not_mic = 0
            }
        '
    )

    declare -A mixer_settings

    for (( i=${#controls[@]}-1; i>=0; i-- ))
    do
        control="${controls[i]}"

        while true
        do
            echo "Simple Mixer Control: ${control}"
            read -r -p "Set the volume (0–100 | m/M): " input </dev/tty

            case "$input" in
                m|M)
                    mixer_settings["$control"]="0% mute"
                    break
                    ;;
                [0-9]|[0-9][0-9]|100)
                    mixer_settings["$control"]="$input% unmute"
                    break
                    ;;
                *)
                    echo "Error: Invalid mixer settings"
                    ;;
            esac
        done
    done

    for (( i=${#controls[@]}-1; i>=0; i-- ))
    do
        control="${controls[i]}"
        setting="${mixer_settings[$control]}"


        doas tee -a /etc/runit/sv/alsa/run > /dev/null <<EOF
amixer sset $control $setting >/dev/null
EOF
    done

    cat << 'EOF' | doas tee -a /etc/runit/sv/alsa/run
exec chpst -b alsa pause
EOF

    doas chmod +x /etc/runit/sv/alsa/run
}

install_artx() {
    git clone https://github.com/proxin187/artx $HOME/.config/artx
    cd $HOME/.config/artx

    (cd dwm && doas make clean install)
    (cd st && doas make clean install)
}

setup_dotfiles() {
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
    { on = "h", run = "leave", desc = "Go to parent directory" },
    { on = "l", run = "enter", desc = "Enter directory" },
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
EOF

    cat > $HOME/.config/nvim/coc-settings.json << 'EOF'
{
  "inlayHint.enable": false,
  "typescript.autoClosingTags": false
}
EOF

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    sh -c 'nvm install node && nvm use node'

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

echo "Info: Starting Artx Setup"

if ! groups | grep -q wheel; then
    echo "Error: User must be part of the wheel group"
    exit 2
fi

if ! [ -d "/etc/runit" ]; then
    echo "Error: Artx can only run on runit based systems"
    exit 2
fi

echo "Info: Installing doas"
install_doas

echo "Info: Installing base dependencies"
doas pacman -S --noconfirm wireless_tools git bash neovim yazi dmenu ttf-iosevka-nerd noto-fonts-emoji feh xorg-server xorg-xinit xorg-xsetroot libx11 libxft libxinerama libxrender libxcb xclip

echo "Info: Installing Material Design Icons"
git clone https://github.com/Templarian/MaterialDesign-Font.git /tmp/MaterialDesign-Font

install -D -m644 /tmp/MaterialDesign-Font/MaterialDesignIconsDesktop.ttf /usr/share/fonts/TTF/MaterialDesignIconsDesktop.ttf

echo "Info: Installing ALSA"
install_alsa

echo "Info: Cloning into Artx and building packages"
install_artx

echo "Info: Setting up dotfiles"
setup_dotfiles

echo "Info: The setup is done"
echo "Note: Please restart your system before running startx"


