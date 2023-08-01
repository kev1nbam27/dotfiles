#!/bin/bash

# check if symlink already exists
if [[ -L /usr/share/sway/scripts ]]; then
    exit;
fi

# check whether we should use sudo or doas
[ command -v doas &> /dev/null ] && sudo=doas || sudo=sudo

# remove preinstalled sway scripts if they exist
[[ -e /usr/share/sway/scripts ]] && $sudo rm -rf /usr/share/sway/scripts

# create sway dir if it doesn't exist yet
$sudo mkdir -p /usr/share/sway

echo "Creating symlink '/usr/share/sway/scripts' -> '$(pwd)/scripts'"
$sudo ln -s $(pwd)/scripts /usr/share/sway/scripts
