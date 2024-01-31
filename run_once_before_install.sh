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

echo Installing yay...
cd $HOME
$sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

echo Installing waybar...
cd $HOME
$sudo pacman -S meson ninja git gtkmm
yay -Sy cmake scdoc wayland-protocols git meson ninja gtkmm3 jsoncpp libsigc++ fmt wayland chrono-date spdlog libgtk-3-dev gobject-introspection libgirepository1.0-dev libpulse libnl libappindicator-gtk3 libdbusmenu-gtk3 libmpdclient libsndio libevdev xkbregistry upower
git clone https://github.com/kev1nbam27/Waybar.git
cd Waybar
meson build
ninja -C build install

yay -Syu
echo Installing yay packages..
yay -S $(cat $CHEZMOI_SOURCE_DIR/.packages_yay)

echo Installing oh-my-zsh...
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s /bin/zsh

echo Installing doom emacs...
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

echo Adding user to groups...
$sudo usermod -a -G video $(whoami)
$sudo usermod -a -G network $(whoami)
$sudo usermod -a -G rfkill $(whoami)
$sudo usermod -a -G power $(whoami)
$sudo usermod -a -G lp $(whoami)

echo Setting GTK theme...
gsettings set org.gnome.desktop.interface gtk-theme linea-nord-color

echo Configuring greetd...
echo "[terminal]\nvt = \"next\"\n\n[default_session]\ncommand = \"tuigreet --user-menu --user-menu-min-uid 1000 --remember --remember-session --time --issue --asterisks\"\nuser = \"greeter\"" | $sudo tee /etc/greetd/config.toml
echo "* {\n    background-image: none;\n}\nwindow {\n    background-color: @transparent_background_color;\n}" | $sudo tee /etc/greetd/style.css
$sudo systemctl enable greetd.service

echo Creating user directories...
cd $HOME
mkdir Screenshots Desktop Downloads Templates Public Documents Music Pictures Videos

mkdir -p $HOME/.config/chezmoi && touch $_/already_installed
