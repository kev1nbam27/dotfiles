#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

# option --output/-o requires 1 argument
LONGOPTS=restart,add:,display:
OPTIONS=ra:d:

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

r=false addFile=- display=eDP-1
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -r|--restart)
            r=true
            shift
            ;;
        -a|--add)
            addFile="$2"
            shift 2
            ;;
        -d|--display)
            display="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

if [[ $r = true ]]; then
    if pgrep mpvpaper; then pkill mpvpaper; fi
    mpvpaper -f $display ~/Videos/$(tail -n 1 ~/.config/wpg/wp_init.sh | awk '{ print $4 }' | sed "s/'//g" | sed "s/\.jpg/.mp4/g" ) -o "no-audio --loop"
elif [[ $addFile != - ]]; then
    newFile=~/Videos/$(echo $addFile | sed "s/.*\///" | sed "s/mylivewallpapers[-|\.]com-//" | sed "s/-4K//")
    ffmpeg -i $addFile -vf "fps=fps=30,crop=3456:2160,scale=1920:1200" -c:v libx265 -c:a copy -preset veryslow -tune fastdecode -threads 14 $newFile
    previewImg=$(echo $newFile | sed "s/\.mp4/.jpg/")
    ffmpeg -i $newFile -vf "select=eq(n\,0)" -q:v 3 $previewImg
    wpg -a $previewImg
    wpg -A $(echo $previewImg | sed "s/.*\///")
fi
