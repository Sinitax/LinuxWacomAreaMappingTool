## Graphic Tablet Tool

A tool for configuring graphic tablets through xinput.

Use `configure.sh` to do one of the following:

- `window`: change the tablet area mapping in a graphical window
- `overlay`: change the tablet area mapping with a graphical screen overlay (experimental)
- `precision`: apply a 1 : 1 mapping for tablet area to screen area at the current position
- `recover`: apply setting configured on a previous run
- `monitor`: apply settings every time a new pointer device is pluged in (good for .xprofile)

### Demo

Graphical Configuration:

<img alt="Graphical Interface" src="/docs/media/interface.gif" width="100%" height="440">

1 to 1 Mapping:

<img alt="Precision Mapping" src="/docs/media/precision.gif" width="100%" height="440">

### Dependencies

It depends on the following..

**libraries:** libX11 libgl libglu libfreeglut

**binaries:** bc xinput xrandr
