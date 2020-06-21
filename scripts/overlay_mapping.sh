#!/bin/bash

SCRIPTPATH="$(dirname $(readlink -f "$0"))"
REPOROOT="$SCRIPTPATH/.."
OVERLAY_MAPPING_PATH="$REPOROOT/source/bin/overlay_mapping"
LOADSETTINGS_PATH="$REPOROOT/scripts/loadsettings.sh"

# load settings
source "$LOADSETTINGS_PATH"

# check if binary has been built
if [ ! -f "$OVERLAY_MAPPING_PATH" ]; then
    echo "[*] Relmove binary is missing, attempting to build.."
    make -C source
    if [ $? -ne 0 ]; then
        echo "[X] Build failed."
        exit 1
    fi
fi

if [ -z "$monitorWidthPX" ]; then
    echo "[X] Failed to parse monitor settings"
    exit 1
fi

echo ""
echo "Configuring graphic tablet: '$tabletName'"
echo "-----------------------------------------"
echo "General debug information:"
echo "Screen size (px)          :" "$screenWidthPX" x "$screenHeightPX"
echo "Monitor size (px)         :" "$monitorWidthPX" x "$monitorHeightPX"
echo "Tablet size (mm)          :" "$tabletWidthMM" x "$tabletHeightMM" 
echo "Monitor size (mm)         :" "$monitorWidthMM" x "$monitorHeightMM" 
echo ""

# get tablet ratio for mapping
tabletRatio=$(bc <<< "scale = 3; $tabletWidthMM / $tabletHeightMM")

# check if settings have been set before
if [ ! -f "$REPOROOT/.lastset" ]; then
    tabletX=0.2
    tabletY=0.2
    tabletWidth=0.6
    tabletHeight=0.6
    args="$tabletRatio $monitorXOffsetPX $monitorYOffsetPX $monitorWidthPX $monitorHeightPX $tabletX $tabletY $tabletWidth $tabletHeight"
else
    args="$tabletRatio $monitorXOffsetPX $monitorYOffsetPX $monitorWidthPX $monitorHeightPX $(cat "$REPOROOT/.lastset")"
fi

echo "[*] Press 'q' to exit."

$OVERLAY_MAPPING_PATH "$REPOROOT/scripts/apply.sh" $args
