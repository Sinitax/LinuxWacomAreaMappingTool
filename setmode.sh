#! /bin/bash

if [[ $# != 1 || "$1" -ne "fullscreen" && "$1" -ne "precision" ]]; then
    echo "USAGE: $0 <mode>"
    echo "Available modes: precision, fullscreen"
    exit
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source $SCRIPTPATH/settings

# get name of tablet devices
tabletstylus=$(xsetwacom --list | grep STYLUS | sed -r 's/  .*//g')
tableteraser=$(xsetwacom --list | grep ERASER | sed -r 's/  .*//g')
tabletpad=$(xsetwacom --list | grep PAD | sed -r 's/    .*//g')

if [ -z $tabletstylus -o -z $tableteraser ]; then
    echo "Cant find tablet!"
    exit # tablet not plugged in
fi

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

# create new areas for: Precise Mode + Ratio
Ytabletmaxarearatiosized=$(bc <<< "scale = 0; $Yscreenpix * $Xtabletmaxarea / $Xscreenpix")
XtabletactiveareaPIX=$(bc <<< "scale = 0; $XtabletactiveareaCM * $screenPPI / 2.54 * $correctionscalefactor")
YtabletactiveareaPIX=$(bc <<< "scale = 0; $YtabletactiveareaCM * $screenPPI / 2.54 * $correctionscalefactor")
XtabletactiveareaPIX=$(bc <<< "scale = 0; ($XtabletactiveareaPIX + 0.5) / 1")
YtabletactiveareaPIX=$(bc <<< "scale = 0; ($YtabletactiveareaPIX + 0.5) / 1")
XOffsettabletactiveareaPIX=$(bc <<< "scale = 0; ($Xscreenpix - $XtabletactiveareaPIX) / 2")
YOffsettabletactiveareaPIX=$(bc <<< "scale = 0; ($Yscreenpix - $YtabletactiveareaPIX) / 2")

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

# apply settings
if [ $1 == "precision" ]; then
    # Precision mode: full tablet area maps 1:1 to a portion of the screen
    echo "Precision mode"
    xsetwacom set "$tabletstylus" Area 0 0 "$Xtabletmaxarea" "$Ytabletmaxarea"
    xsetwacom set "$tableteraser" Area 0 0 "$Xtabletmaxarea" "$Ytabletmaxarea"
    xsetwacom set "$tabletstylus" MapToOutput "$XtabletactiveareaPIX"x"$YtabletactiveareaPIX"+"$XOffsettabletactiveareaPIX"+"$YOffsettabletactiveareaPIX"
    notify-send -i /usr/share/icons/gnome/22x22/devices/input-tablet.png "Precision mode" "$XtabletactiveareaPIX x $YtabletactiveareaPIX part-of-screen"

    # save settings to ".lastset"
    echo "$XOffsettabletactiveareaPIX $YOffsettabletactiveareaPIX $XtabletactiveareaPIX $YtabletactiveareaPIX" > "$SCRIPTPATH/.lastset"
else
    # Fullscreen mode; tablet area maps to full area of screen with ratio correction
    echo "Full-screen mode with ratio correction"
    xsetwacom set "$tabletstylus" Area 0 0 "$Xtabletmaxarea" "$Ytabletmaxarearatiosized"
    xsetwacom set "$tableteraser" Area 0 0 "$Xtabletmaxarea" "$Ytabletmaxarearatiosized"
    xsetwacom set "$tabletstylus" MapToOutput "$Xscreenpix"x"$Yscreenpix"+0+0
    notify-send -i /usr/share/icons/gnome/22x22/devices/input-tablet.png "Normal mode" "full-screen"

    # save settings to ".lastset"
    echo "0 0 $Xscreenpix $Yscreenpix" > "$SCRIPTPATH/.lastset"
fi

