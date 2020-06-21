#!/bin/bash

SCRIPTPATH="$(dirname $(readlink -f "$0"))"
REPOROOT=$SCRIPTPATH/..
LASTSET_FILE=$REPOROOT/.lastset

if [ ! -f "$LASTSET_FILE" ]; then
    echo "[X] No saved settings found!"
    exit 1
fi

source $SCRIPTPATH/apply.sh $(cat "$LASTSET_FILE")
