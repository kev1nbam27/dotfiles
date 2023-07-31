#!/bin/bash

# check if dir or symlink already exists
if [[ -e /usr/share/sway/scripts ]]; then
    exit;
fi

# check whether we should use sudo or doas
[ command -v doas &> /dev/null ] && sudo=doas || sudo=sudo

echo "Creating symlink '/usr/share/sway/scripts' -> '$(pwd)/scripts'"
$sudo ln -s $(pwd)/scripts /usr/share/sway/scripts
