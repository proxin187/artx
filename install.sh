#!/bin/bash

echo "Info: Starting Artx Setup"

echo "Info: Installing yay AUR helper"

sudo pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si --noconfirm)

echo "Info: Installing base dependencies"

sudo pacman -S --noconfirm wireless_tools bash dmenu ttf-iosevka-nerd noto-fonts-emoji feh xorg-server xorg-xinit xorg-xsetroot libx11 libxft libxinerama libxrender libxcb alsa-utils
yay -S --noconfirm ttf-material-design-icons-desktop-git

echo "Info: Cloning into Artx and building packages"

git clone https://github.com/proxin187/artx $HOME/.config/artx
cd $HOME/.config/artx

(cd dwm && sudo make clean install)
(cd st && sudo make clean install)

echo "Info: Setting up dotfiles"
cat > $HOME/.xinitrc << 'EOF'
#!/bin/sh
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

echo "Info: The setup is done"
echo "Note: Please restart your system before running startx"


