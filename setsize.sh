#!/bin/bash

if [ $# != 4 ]; then
    echo "USAGE $0 <reloffset_x> <reloffset_y> <relsize_x> <relsize_y>"
    exit
fi

reloffx=$1
reloffy=$2
relsizex=$3
relsizey=$4

set -e

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/loadsettings.sh

xinput set-prop "$tabletname" --type=float "Coordinate Transformation Matrix" $relsizex 0 $reloffx 0 $relsizey $reloffy 0 0 1

# calculate area from relative input params
tabletareawidthPX=$(bc <<< "scale = 0; ($screenwidthPX * $relsizex + 0.5) / 1")
tabletareaheightPX=$(bc <<< "scale = 0; ($screenheightPX * $relsizey + 0.5) / 1")
offsettabletareawidthPX=$(bc <<< "scale = 0; ($screenwidthPX * $reloffx + 0.5) / 1")
offsettabletareaheightPX=$(bc <<< "scale = 0; ($screenheightPX * $reloffy + 0.5) / 1")

# apply settings
notify-send -i /usr/share/icons/gnome/22x22/devices/input-tablet.png "Custom mode" "$tabletareawidthPX x $tabletareaheightPX"

# save settings in PX in .lastset
echo "$offsettabletareawidthPX $offsettabletareaheightPX $tabletareawidthPX $tabletareaheightPX" > "$SCRIPTPATH/.lastset"
