#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# load settings
source $SCRIPTPATH/settings

# check if binary has been built
if [ ! -f $SCRIPTPATH/src/wacom-tool ]; then
    echo "[!] You must first build the binary in the src directory"
    exit 1
fi

# warning messages
echo "[!] Do NOT resize the GUI, it is supposed to have the same ratio as your screen!"
echo "[.] Press <Enter> to save the current mapping"
echo "[.] Press <ESC> to safely exit the program"
echo "[.] Press 'r' to adjust the mapped area to the ratio of your tablet"
echo ""
read -n 1 -s -r -p "Press Any Key to Continue.."
echo ""


# check if settings have been set before
if [ -f "$SCRIPTPATH/.lastset" ]; then
    $SCRIPTPATH/src/wacom-tool $SCRIPTPATH $(cat "$SCRIPTPATH/.lastset")
else
    $SCRIPTPATH/src/wacom-tool $SCRIPTPATH
fi

# For now only settings which have been set with the provided utilities can be cached for the gui program. This is because the xsetwacom parameter used to apply the settings "MapToOutput" is write-only.
