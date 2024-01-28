#!/bin/bash

# check if script has been run before
if [[ -f $HOME/.config/chezmoi/already_installed ]]; then
    exit;
fi

dir=$(pwd)
# check whether we should use sudo or doas
[ command -v doas &> /dev/null ] && sudo=doas || sudo=sudo
echo Using $sudo

echo Changing mirrors...
{ echo "Server = https://cloudflaremirrors.com/archlinux/\$repo/os/\$arch"; cat /etc/pacman.d/mirrorlist; } | $sudo tee /etc/pacman.d/mirrorlist
$sudo pacman -Syyu

echo Checking for updates...
$sudo pacman -Syu
echo Installing pacman packages...
$sudo pacman -S - < $CHEZMOI_SOURCE_DIR/.packages_pacman

echo Installing waybar...
cd $HOME
sudo pacman -S meson ninja
git clone https://github.com/kev1nbam27/Waybar.git
cd Waybar
meson build
ninja -C build install

echo Installing yay...
cd $HOME
$sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -Syu
echo Installing yay packages..
yay -S $(cat $CHEZMOI_SOURCE_DIR/.packages_yay)

echo Installing oh-my-zsh...
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo Adding user to groups...
$sudo usermod -a -G video $(whoami)
$sudo usermod -a -G network $(whoami)
$sudo usermod -a -G rfkill $(whoami)
$sudo usermod -a -G power $(whoami)
$sudo usermod -a -G lp $(whoami)

mkdir -p $HOME/.config/chezmoi && touch $_/already_installed
