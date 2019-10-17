#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -f "$SCRIPTPATH/.lastset" ]; then
    echo "Active tablet area must be configured for it to be recovered"
    exit 1
fi

lastset="$(cat "$SCRIPTPATH/.lastset")"
IFS=' ' read -ra oldvals <<< "$lastset"

# get screen area vars
Xscreenpix=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
Yscreenpix=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

# convert to relative
reloffx=$(bc <<< "scale=4; ${oldvals[0]} / $Xscreenpix")
reloffy=$(bc <<< "scale=4; ${oldvals[1]} / $Yscreenpix")
relwidth=$(bc <<< "scale=4; ${oldvals[2]} / $Xscreenpix")
relheight=$(bc <<< "scale=4; ${oldvals[3]} / $Yscreenpix")

# set size
$SCRIPTPATH/setsize.sh $reloffx $reloffy $relwidth $relheight
