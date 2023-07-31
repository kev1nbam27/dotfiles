#!/bin/bash

dir=$(pwd)
# check whether we should use sudo or doas
[ command -v doas &> /dev/null ] && sudo=doas || sudo=sudo

$sudo pacman -Syu
$sudo pacman -S - < .packages_pacman

# install yay
cd $HOME
$sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
$sudo makepkg -si

yay -Syu
yay -S - < .packages_yay
