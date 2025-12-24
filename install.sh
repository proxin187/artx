#!/bin/bash

echo "Info: Starting Artx Setup"

echo "Info: Installing yay AUR helper"

sudo pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si --noconfirm)

echo "Info: Installing base dependencies"

sudo pacman -S --noconfirm bash dmenu ttf-iosevka-nerd noto-fonts-emoji feh xorg-server xorg-xinit libx11 libxft libxinerama libxrender libxcb alsa-utils
yay -S --noconfirm ttf-material-design-icons-desktop-git

echo "Info: Cloning into Artx and building packages"

git clone https://github.com/proxin187/artx $HOME/.config/artx
cd $HOME/.config/artx

(cd dwm && sudo make clean install)
(cd st && sudo make clean install)

echo "Info: Setting up .xinitrc"
cat > $HOME/.xinitrc << 'EOF'
#!/bin/sh

feh --bg-scale $HOME/.config/artx/wallpapers/wallpaper-5.jpg &

exec dwm
EOF
chmod +x $HOME/.xinitrc

# TODO: setup bash config

echo "Info: The setup is done"
echo "Note: Please restart your system before running startx"


