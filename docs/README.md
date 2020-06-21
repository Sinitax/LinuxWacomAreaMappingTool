## Xinput Tablet Tool

A graphical tool to configure graphic tablets through xinput.

Following utilities are available in the `scripts` directory:

- `configure.sh` to graphically configure the tablet area mapping
- `precision.sh` to generate a 1 : 1 mapping for tablet area to screen area
- `recover.sh` to apply setting configured on previous run
- `tablet-reset.sh` to wait for tablet to be plugged in before previous settings are applied

### Demo

Graphical Configuration:

<img alt="Graphical Interface" src="/docs/media/interface.gif" width="600" height="340">

1 to 1 Mapping:

<img alt="Precision Mapping" src="/docs/media/precision.gif" width="600" height="340">

### Dependencies

It depends on the following..

**libraries:** libX11 libgl libglu libfreeglut

**binaries:** bc xinput xrandr
