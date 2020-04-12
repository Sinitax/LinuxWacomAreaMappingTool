#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -f "$SCRIPTPATH/.lastset" ]; then
    echo "[X] No saved settings found!"
    exit 1
fi

# set size
$SCRIPTPATH/apply.sh $(cat "$SCRIPTPATH/.lastset")
