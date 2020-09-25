#!/bin/bash

SCRIPTPATH="$(dirname $(readlink -f "$0"))"
REPOROOT="$SCRIPTPATH/.."
WINDOW_MAPPING_PATH="$REPOROOT/source/bin/window_mapping"
LOADSETTINGS_PATH="$REPOROOT/scripts/loadsettings.sh"

# load settings
source "$LOADSETTINGS_PATH"

# check if binary has been built
if [ ! -f "$WINDOW_MAPPING_PATH" ]; then
    echo "[*] Tablet tool binary is missing, attempting to build.."
    make -C source
    if [ $? -ne 0 ]; then
        echo "[X] Build failed."
        exit 1
    fi
fi

# get tablet ratio for mapping
tabletRatio=$(bc <<< "scale = 3; $tabletWidthMM / $tabletHeightMM")

if [ -z "$monitorWidthPX" ]; then
    echo "[X] Failed to parse monitor settings"
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

echo ""
echo "Configuring graphic tablet: '$tabletName'"
echo "-----------------------------------------"
echo "General debug information:"
echo "Screen size (px)          :" "$screenWidthPX" x "$screenHeightPX"
echo "Monitor size (px)         :" "$monitorWidthPX" x "$monitorHeightPX"
echo "Tablet size (mm)          :" "$tabletWidthMM" x "$tabletHeightMM" 
echo "Monitor size (mm)         :" "$monitorWidthMM" x "$monitorHeightMM" 
echo ""

# check if settings have been set before
if [ -f "$REPOROOT/.lastset" ]; then
    args="$tabletRatio $monitorXOffsetPX $monitorYOffsetPX $monitorWidthPX $monitorHeightPX $(cat "$REPOROOT/.lastset")"
else
    args="$tabletRatio $monitorXOffsetPX $monitorYOffsetPX $monitorWidthPX $monitorHeightPX"
fi
$WINDOW_MAPPING_PATH "$REPOROOT/scripts/apply.sh" $args
