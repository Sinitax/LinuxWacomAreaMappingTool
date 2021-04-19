#!/bin/bash

if [ $# != 4 ]; then
    echo "USAGE $0 <reloffset_x> <reloffset_y> <relsize_x> <relsize_y>"
    exit
fi

tabletXOffsetRelMon=$1
tabletYOffsetRelMon=$2
tabletWidthRelMon=$3
tabletHeightRelMon=$4

set -e

SCRIPTPATH="$(dirname $(readlink -f "$0"))"
REPOROOT="$SCRIPTPATH/.."
LOADSETTINGS_PATH="$REPOROOT/scripts/loadsettings.sh"
LASTSET_PATH="$REPOROOT/.lastset"

source "$LOADSETTINGS_PATH"

# convert monitor relative offset to ones relative to screen
tabletXOffsetRelScr=$(bc <<< "scale = 5;
    ($monitorXOffsetPX + $tabletXOffsetRelMon * $monitorWidthPX) / $screenWidthPX")
tabletYOffsetRelScr=$(bc <<< "scale = 5;
    ($monitorYOffsetPX + $tabletYOffsetRelMon * $monitorHeightPX) / $screenHeightPX")
tabletWidthRelScr=$(bc <<< "scale = 5;
    $tabletWidthRelMon * $monitorWidthPX / $screenWidthPX")
tabletHeightRelScr=$(bc <<< "scale = 5;
    $tabletHeightRelMon * $monitorHeightPX / $screenHeightPX")

# Verbose for debugging

echo ""
echo "Configuration information:"
echo "Active Area size (rel to mon)  :" "$tabletWidthRelMon" x "$tabletHeightRelMon" 
echo "Active Area size (rel to scr)  :" "$tabletWidthRelScr" x "$tabletHeightRelScr" 
echo "Active Area offset (rel on mon):" "$tabletXOffsetRelMon" x "$tabletYOffsetRelMon"
echo "Active Area offset (rel on scr):" "$tabletXOffsetRelScr" x "$tabletYOffsetRelScr"
echo ""

xinput set-prop "$tabletName" --type=float "Coordinate Transformation Matrix" $tabletWidthRelScr 0 $tabletXOffsetRelScr 0 $tabletHeightRelScr $tabletYOffsetRelScr 0 0 1

# save settings in PX in .lastset
echo "$tabletXOffsetRelMon $tabletYOffsetRelMon $tabletWidthRelMon $tabletHeightRelMon" > "$LASTSET_PATH"
