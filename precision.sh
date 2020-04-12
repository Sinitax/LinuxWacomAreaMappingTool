#!/bin/bash

# attempts to create a 1:1 matching between tablet size and monitor


SCRIPTPATH="$(dirname "$(realpath "$0")")"

source $SCRIPTPATH/loadsettings.sh

if [ $((tabletWidthMM)) -gt $((monitorWidthMM)) -o $((tabletHeightMM)) -gt $((monitorHeightMM)) ]; then
    echo "[X] Unable to establish 1:1 relation, monitor is to small"
    exit 1
fi

tabletWidthRelMon=$(bc <<< "scale = 3;
    $tabletWidthMM / $monitorWidthMM");
tabletHeightRelMon=$(bc <<< "scale = 3;
    $tabletHeightMM / $monitorHeightMM");

$SCRIPTPATH/apply.sh 0 0 $tabletWidthRelMon $tabletHeightRelMon

echo "[*] use the custommapping.sh script to adjust the mapping position"
