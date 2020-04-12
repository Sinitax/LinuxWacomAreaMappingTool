#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# load settings
source $SCRIPTPATH/loadsettings.sh

# check if binary has been built
if [ ! -f $SCRIPTPATH/src/tablet-tool ]; then
    echo "[!] You must first build the binary in the src directory"
    exit 1
fi

# get tablet ratio for mapping
tabletRatio=$(bc <<< "scale = 3; $tabletWidthMM / $tabletHeightMM")

# warning messages
echo "[!] Do NOT resize the GUI, it is supposed to have the same ratio as your screen!"
echo "[.] Press <Enter> to save the current mapping"
echo "[.] Press <ESC> to safely exit the program"
echo "[.] Press 'r' to adjust the mapped area to the ratio of your tablet"
echo ""
read -n 1 -s -r -p "Press Any Key to Continue.."
echo ""

echo ""
echo "Configuring graphic tablet: '$tabletName'"
echo "-----------------------------------------"
echo "General debug information:"
echo "Screen size (px)          :" "$screenWidthPX" x "$screenHeightPX"
echo "Monitor size (px)         :" "$monitorWidthPX" x "$monitorHeightPX"
echo "Tablet size (mm)          :" "$tabletWidthMM" x "$tabletHeightMM" 
echo "Monitor size (mm)         :" "$monitorWidthMM" x "$monitorHeightMM" 
echo ""

if [ -z "$monitorWidthPX" ]; then
    echo "[X] Failed to parse monitor settings"
    exit 1
fi

# check if settings have been set before
if [ -f "$SCRIPTPATH/.lastset" ]; then
    $SCRIPTPATH/src/tablet-tool "$SCRIPTPATH/apply.sh" $tabletRatio $monitorXOffsetPX $monitorYOffsetPX $monitorWidthPX $monitorHeightPX $(cat "$SCRIPTPATH/.lastset")
else
    $SCRIPTPATH/src/tablet-tool "$SCRIPTPATH/apply.sh" $tabletRatio $monitorXOffsetPX $monitorYOffsetPX $monitorWidthPX $monitorHeightPX
fi
