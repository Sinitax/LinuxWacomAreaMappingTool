#!/bin/bash

SCRIPTPATH="$(dirname $(readlink -f "$0"))"
REPOROOT="$SCRIPTPATH/.."
SETTINGS_PATH="$REPOROOT/.settings"

if [ ! -e "$SETTINGS_PATH" ];then
    cp "$REPOROOT/.settings-template" "$SETTINGS_PATH"
    echo "[!] Created .settings file.. configure and re-run"
    exit 1
fi

source "$SETTINGS_PATH"

if [ -z "$tabletName" -o -z "$tabletWidthMM" -o -z "$tabletHeightMM" -o -z "$display" ]; then
    echo "[X] Settings file not complete!"
    exit 1
fi

# total resolution
screenRes=$(xrandr | head -n1 | cut -d',' -f2);
screenWidthPX=$(echo $screenRes | cut -d' ' -f2);
screenHeightPX=$(echo $screenRes | cut -d' ' -f4);

xrandrOut=$(xrandr --current | grep $display)

# display resolution
monitorInfo=$(echo $xrandrOut | sed -e "s/ /\n/g" | grep -e ".*x.*+.\++.\+")
monitorWidthPX=$(echo $monitorInfo | cut -d'+' -f1 | cut -d 'x' -f1)
monitorHeightPX=$(echo $monitorInfo | cut -d'+' -f1 | cut -d 'x' -f2)
monitorXOffsetPX=$(echo $monitorInfo | cut -d'+' -f2)
monitorYOffsetPX=$(echo $monitorInfo | cut -d'+' -f3)

# display dimensions
monitorDim=$(echo $xrandrOut | cut -d',' -f3 | sed -e 's/mm//g' | rev)
monitorWidthMM=$(echo $monitorDim | cut -d' ' -f3 | rev);
monitorHeightMM=$(echo $monitorDim | cut -d' ' -f1 | rev);
