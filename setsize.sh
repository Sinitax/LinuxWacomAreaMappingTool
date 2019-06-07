#!/bin/bash

if [ $# != 4 ]; then
    echo "USAGE $0 <reloffset_x> <reloffset_y> <relsize_x> <relsize_y>"
    exit
fi

reloffx=$1
reloffy=$2
relsizex=$3
relsizey=$4

# get tablet settings
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/settings

# get name of tablet devices
tabletstylus=$(xsetwacom --list | grep STYLUS | sed -r 's/  .*//g')
tableteraser=$(xsetwacom --list | grep ERASER | sed -r 's/  .*//g')
tabletpad=$(xsetwacom --list | grep PAD | sed -r 's/    .*//g')

# reset area
xsetwacom --set "$tabletstylus" ResetArea
xsetwacom --set "$tableteraser" ResetArea

# get tablet area vars
fulltabletarea=`xsetwacom get "$tabletstylus" Area | grep "[0-9]\+ [0-9]\+$" -o`
Xtabletmaxarea=`echo $fulltabletarea | grep "^[0-9]\+" -o`
Ytabletmaxarea=`echo $fulltabletarea | grep "[0-9]\+$" -o`

# get screen area vars
Xscreenpix=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
Yscreenpix=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)
screenPPI=$(xdpyinfo | grep dots | awk '{print $2}' | awk -Fx '{print $1}')
XscreenPPI=$(bc <<< "scale = 2; $Xscreenpix / $screenPPI")
YscreenPPI=$(bc <<< "scale = 2; $Yscreenpix / $screenPPI")
XscreenCM=$(bc <<< "scale = 0; $Xscreenpix * 0.0254")
YscreenCM=$(bc <<< "scale = 0; $Yscreenpix * 0.0254")

# calculate area from relative input params
XtabletactiveareaPIX=$(bc <<< "scale = 0; $Xscreenpix * $relsizex")
YtabletactiveareaPIX=$(bc <<< "scale = 0; $Yscreenpix * $relsizey")
XtabletactiveareaPIX=$(bc <<< "scale = 0; ($XtabletactiveareaPIX + 0.5) / 1") # round to nearest
YtabletactiveareaPIX=$(bc <<< "scale = 0; ($YtabletactiveareaPIX + 0.5) / 1")
XOffsettabletactiveareaPIX=$(bc <<< "scale = 0; $Xscreenpix * $reloffx")
YOffsettabletactiveareaPIX=$(bc <<< "scale = 0; $Yscreenpix * $reloffy")
XOffsettabletactiveareaPIX=$(bc <<< "scale = 0; ($XOffsettabletactiveareaPIX + 0.5) / 1")
YOffsettabletactiveareaPIX=$(bc <<< "scale = 0; ($YOffsettabletactiveareaPIX + 0.5) / 1")

# Verbose for debugging
echo "Configuring graphic tablet: $tabletpad"
echo "-----------------------------------------"
echo "Debug information:"
echo "Tablet size (cm) :" "$XtabletactiveareaCM" x "$YtabletactiveareaCM" 
echo "Screen size (px) :" "$Xscreenpix" x "$Yscreenpix" 
echo "Screen size (cm) :" "$XscreenCM" x "$YscreenCM" 
echo "Screen ppi :" "$screenPPI"
echo "Correction factor :" "$correctionscalefactor"
echo "Maximum tablet-Area (Wacom unit):" "$Xtabletmaxarea" x "$Ytabletmaxarea"
echo "Precision-mode area (px):" "$XtabletactiveareaPIX" x "$YtabletactiveareaPIX"
echo "Precision-mode offset (px):" "$XOffsettabletactiveareaPIX" x "$YOffsettabletactiveareaPIX"


# In case of Nvidia GFX:
xsetwacom set "$tabletstylus" MapToOutput "HEAD-0"
xsetwacom set "$tableteraser" MapToOutput "HEAD-0"
if [ ! -z $tabletpad ];then
    xsetwacom set "$tabletpad" MapToOutput "HEAD-0"
fi

xsetwacom set "$tabletstylus" Area 0 0 "$Xtabletmaxarea" "$Ytabletmaxarea"
xsetwacom set "$tableteraser" Area 0 0 "$Xtabletmaxarea" "$Ytabletmaxarea"
xsetwacom set "$tabletstylus" MapToOutput "$XtabletactiveareaPIX"x"$YtabletactiveareaPIX"+"$XOffsettabletactiveareaPIX"+"$YOffsettabletactiveareaPIX"
notify-send -i /usr/share/icons/gnome/22x22/devices/input-tablet.png "Custom mode" "$XtabletactiveareaPIX x $YtabletactiveareaPIX"
