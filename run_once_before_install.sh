#!/bin/bash

# check if script has been run before
if [[ -f $HOME/.config/chezmoi/already_installed ]]; then
    exit;
fi

dir=$(pwd)
# check whether we should use sudo or doas
[ command -v doas &> /dev/null ] && sudo=doas || sudo=sudo
echo Using $sudo

echo Checking for updates...
$sudo pacman -Syu
echo Installing pacman packages...
$sudo pacman -S - < $CHEZMOI_SOURCE_DIR/.packages_pacman

echo Installing yay...
cd $HOME
$sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -Syu
echo Installing yay packages..
yay -S - < $CHEZMOI_SOURCE_DIR/.packages_yay

echo Installing oh-my-zsh...
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir -p $HOME/.config/chezmoi && touch $_/already_installed
