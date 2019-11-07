#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

source $SCRIPTPATH/.settings

if [ -z "$tabletname" -o -z "$tabletareawidthCM" -o -z "$tabletareaheightCM" ]; then
    echo "[X] Settings file not complete!"
    exit 1
fi

# get screen area vars
screenwidthPX=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
screenheightPX=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)
screenPPI=$(xdpyinfo | grep dots | awk '{print $2}' | awk -Fx '{print $1}')
screenwidthIN=$(bc <<< "scale = 2; $screenwidthPX / $screenPPI")
screenheightIN=$(bc <<< "scale = 2; $screenheightPX / $screenPPI")
screenwidthCM=$(bc <<< "scale = 0; $screenwidthIN * 2.54")
screenheightCM=$(bc <<< "scale = 0; $screenheightIN * 2.54")

# Verbose for debugging
echo ""
echo "Configuring graphic tablet: '$tabletname'"
echo "-----------------------------------------"
echo "Debug information:"
echo "Tablet size (cm) :" "$tabletareawidthCM" x "$tabletareaheightCM" 
echo "Screen size (px) :" "$screenwidthPX" x "$screenheightPX"
echo "Screen size (cm) :" "$screenwidthCM" x "$screenheightCM" 
echo "Screen ppi :" "$screenPPI"
echo "Correction factor :" "$correctionscalefactor"
echo ""
