#!/bin/bash

REALPATH="$(readlink -f "$0")" # binary in /usr/bin is a symlink
SCRIPTPATH="$(dirname $(readlink -f "$0"))"
REPOPATH="$SCRIPTPATH/.." # /pentablet/data/*bin*
RECOVER_PATH="$REPOPATH/scripts/recover.sh"
LOADSETTINGS_PATH="$REPOPATH/scripts/loadsettings.sh"

source "$LOADSETTINGS_PATH"

function check_tablet() {
    echo $(xinput --list | grep "$tabletName")
}

tablet_found=0

# check if graphics tablet is already plugged in
if [ -z "$(check_tablet)" ]; then
    while read -r directory events filename; do
        if [[ "$filename" =~ ^mouse[1-9]*[0-9]$ ]]; then
            # wait for device to init
            sleep 2
            # check if its the tablet
            if [ ! -z "$(check_tablet)" ]; then
                break
            fi
        fi
    done < <(inotifywait -e create -q -m /dev/input)
fi

source "$RECOVER_PATH"
