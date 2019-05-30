#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/settings

echo "[!] Do NOT resize the GUI, it is supposed to have the same ratio as your screen!"
echo "[.] Press <Enter> to save the current mapping"
echo "[.] Press 'r' to adjust the mapped area to the ratio of your tablet"
echo ""
read -n 1 -s -r -p "Press Any Key to Continue.."
echo ""

$SCRIPTPATH/data/wacom-tool $SCRIPTPATH
