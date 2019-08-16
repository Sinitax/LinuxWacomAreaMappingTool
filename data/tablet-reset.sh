#!/bin/bash

REALPATH="$(readlink -f "$0")" # binary in /usr/bin is a symlink
SCRIPTPATH="$(cd "$(dirname "$REALPATH")" ; pwd -P )"
REPOPATH="$SCRIPTPATH/.." # /pentablet/data/*bin*

# check if graphics tablet is already plugged in
tabletstylus=$(xsetwacom --list | grep STYLUS | sed -r 's/  .*//g')
if [ -n "$tabletstylus" ];then
    bash "$REPOPATH/recover.sh"
    exit
fi

# wait for graphic tablet to be plugged in
inotifywait -e create -q -m /dev/input/ |
while read -r directory events filename; do
    echo $filename
    if [[ "$filename" =~ ^mouse.$ ]]; then
        # wait for device to init
        sleep 2
        # check if its the tablet
        tabletstylus=$(xsetwacom --list | grep STYLUS | sed -r 's/  .*//g')
        if [ -n "$tabletstylus" ]; then
            # run script to set to precision mode
            bash "$REPOPATH/recover.sh"
            exit
        fi
    fi
done
