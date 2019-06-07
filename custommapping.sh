#!/bin/bash

# check if binary has been built
if [ ! -f $SCRIPTPATH/src/wacom-tool ]; then
    echo "[!] You must first build the binary in the src directory"
    exit 1
fi

# load settings
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/settings

# warning messages
echo "[!] Do NOT resize the GUI, it is supposed to have the same ratio as your screen!"
echo "[.] Press <Enter> to save the current mapping"
echo "[.] Press 'r' to adjust the mapped area to the ratio of your tablet"
echo ""
read -n 1 -s -r -p "Press Any Key to Continue.."
echo ""

$SCRIPTPATH/src/wacom-tool $SCRIPTPATH
