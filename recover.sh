#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -f "$SCRIPTPATH/.lastset" ]; then
    echo "Active tablet area must be configured for it to be recovered"
    exit 1
fi

source $SCRIPTPATH/loadsettings.sh

lastset="$(cat "$SCRIPTPATH/.lastset")"
IFS=' ' read -ra oldvals <<< "$lastset"

# convert to relative
reloffx=$(bc <<< "scale=4; ${oldvals[0]} / $screenwidthPX")
reloffy=$(bc <<< "scale=4; ${oldvals[1]} / $screenheightPX")
relwidth=$(bc <<< "scale=4; ${oldvals[2]} / $screenwidthPX")
relheight=$(bc <<< "scale=4; ${oldvals[3]} / $screenheightPX")

# set size
$SCRIPTPATH/setsize.sh $reloffx $reloffy $relwidth $relheight
