#!/bin/bash

## meta script for easier handling ##

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
REPOROOT="$SCRIPTPATH"

if [ -z "$(which xinput)" ]; then
    echo "Please install xorg-xinput first"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo "Please supply a command"
    exit 1
fi

if [ "$1" == "precision" ]; then
    target="scripts/precision.sh"
elif [ "$1" == "window" ]; then
    target="scripts/window_mapping.sh"
elif [ "$1" == "overlay" ]; then
    target="scripts/overlay_mapping.sh"
elif [ "$1" == "recover" ]; then
    target="scripts/recover.sh"
else
    echo "Command not found"
    exit 1
fi

"$REPOROOT/$target" ${@:1}
