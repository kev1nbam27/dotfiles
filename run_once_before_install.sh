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
$sudo pacman -S - < .packages_pacman

echo Installing yay
cd $HOME
$sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
$sudo makepkg -si

yay -Syu
echo Installing yay packages
yay -S - < .packages_yay

mkdir -p $HOME/.config/chezmoi && touch $_/already_installed
