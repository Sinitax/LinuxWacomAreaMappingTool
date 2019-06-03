## Wacom Tablet Configuration Tool

### Usage

Add the dimensions of your graphic tablet to the `settings` file in cm.

Run the `setmode.sh` script to enable on of the following modes:

- **precision mode** : tablet area maps 1:1 to your screen
- **fullscreen mode** : partial tablet area maps to full area of screen

Run the `setbuttons.sh` script to enable a custom buttom mapping useful for drawing with Krita

Run the `custommapping.sh` script to configure a custom area mapping using a graphical interface

Run the `setsize.sh` script to configure a custom area mapping from the commandline using relative values

![Screenshot](https://github.com/Sinitax/LinuxWacomAreaMappingTool/raw/master/data/screenshot.png)

### Dependencies

- libwacom (xsetwacom)
- bash and bc for math
- xrandr

### Credits

- Original gist for `setmode.sh` script by [Deevad](https://github.com/Deevad)



