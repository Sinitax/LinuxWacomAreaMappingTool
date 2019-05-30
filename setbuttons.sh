#!/bin/bash

# get name of tablet devices
tabletstylus=$(xsetwacom --list | grep STYLUS | sed -r 's/  .*//g')
tableteraser=$(xsetwacom --list | grep ERASER | sed -r 's/  .*//g')
tabletpad=$(xsetwacom --list | grep PAD | sed -r 's/    .*//g')
if [ -z $tabletpad ]; then
    echo "[!] no tabletpad detected to configure .. skipping"
else
    xsetwacom set "$tabletpad" Button 1 "key e" # Eraser
    xsetwacom set "$tabletpad" Button 2 "key Shift_L" # Resize widget with Krita
    xsetwacom set "$tabletpad" Button 3 "key Control_L" # Control color picker
    xsetwacom set "$tabletpad" Button 8 "key KP_Divide" # '/' key to swap current brush preset with previous used on Krita.
fi

xsetwacom set "$tabletstylus" RawSample 4

echo "done."

# alternative example config:
# xsetwacom set "$tabletpad" Button 1 "key greater" # '>' Symbol ; I map on it a color selector, or a custom feature of Krita  
# xsetwacom set "$tabletpad" Button 8 "key comma" # ',' key ; another easy key to bind an on-canvas color selector
# xsetwacom set "$tabletstylus" Button 2 "key ctrl" # A way to add Color picker on stylus.
