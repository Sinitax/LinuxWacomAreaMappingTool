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

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/loadsettings.sh

# convert monitor relative offset to ones relative to screen
tabletXOffsetRelScr=$(bc <<< "scale = 3;
    ($monitorXOffsetPX + $tabletXOffsetRelMon * $monitorWidthPX) / $screenWidthPX")
tabletYOffsetRelScr=$(bc <<< "scale = 3;
    ($monitorYOffsetPX + $tabletYOffsetRelMon * $monitorHeightPX) / $screenHeightPX")
tabletWidthRelScr=$(bc <<< "scale = 3;
    $tabletWidthRelMon * $monitorWidthPX / $screenWidthPX")
tabletHeightRelScr=$(bc <<< "scale = 3;
    $tabletHeightRelMon * $monitorHeightPX / $screenHeightPX")

# Verbose for debugging
echo ""
echo "Configuring graphic tablet: '$tabletName'"
echo "-----------------------------------------"
echo "Debug information:"
echo "Screen size (px)          :" "$screenWidthPX" x "$screenHeightPX"
echo "Monitor size (px)         :" "$monitorWidthPX" x "$monitorHeightPX"
echo "Tablet size (mm)          :" "$tabletWidthMM" x "$tabletHeightMM" 
echo "Monitor size (mm)         :" "$monitorWidthMM" x "$monitorHeightMM" 
echo "Tablet size (rel to mon)  :" "$tabletWidthRelMon" x "$tabletHeightRelMon" 
echo "Tablet size (rel to scr)  :" "$tabletWidthRelScr" x "$tabletHeightRelScr" 
echo "Tablet offset (rel on mon):" "$tabletXOffsetRelMon" x "$tabletYOffsetRelMon"
echo "Tablet offset (rel on scr):" "$tabletXOffsetRelScr" x "$tabletYOffsetRelScr"
echo ""

xinput set-prop "$tabletName" --type=float "Coordinate Transformation Matrix" $tabletWidthRelScr 0 $tabletXOffsetRelScr 0 $tabletHeightRelScr $tabletYOffsetRelScr 0 0 1

# save settings in PX in .lastset
echo "$tabletXOffsetRelMon $tabletYOffsetRelMon $tabletWidthRelMon $tabletHeightRelMon" > "$SCRIPTPATH/.lastset"