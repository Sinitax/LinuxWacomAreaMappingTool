## Wacom Tablet Configuration Tool

### Usage

Add the dimensions of your graphic tablet to the `settings` file in cm.

Run the `setmode.sh` script to enable on of the following modes:

- **precision mode** : tablet area maps 1:1 to your screen
- **fullscreen mode** : partial tablet area maps to full area of screen with correct ratio

Run the `setsize.sh` script to configure a custom area mapping from the commandline using relative values

Run the `recover.sh` script to re-use the settings last set

Run the `custommapping.sh` script to configure a custom area mapping using a graphical interface

![Screenshot](https://github.com/Sinitax/LinuxWacomAreaMappingTool/raw/master/data/screenshot.png)

### Persistency

By default the settings will only stay in effect until reboot. To make the changes persistent, one must recover the last set values when the tablet is plugged in.

There is an example `tablet-reset.sh` script included in the data directory which can be configured as a startup application.

### Dependencies

- libx11-dev
- libwacom (xsetwacom)
- libgl1-mesa-dev (opengl)
- freeglut3-dev
- bc cmdlet
- xrandr

### Credits

- Original gist for `setmode.sh` script by [Deevad](https://github.com/Deevad)

