#include <iostream>
#include <cmath>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <chrono>
#include <thread>

#include "GL/gl.h"
#include "GL/glx.h"

#include "X11/Xlib.h"
#include "X11/X.h"
#include "X11/Xutil.h"

#include "cairo/cairo.h"
#include "cairo/cairo-xlib.h"



// GLUT and Displaying

Window overlay;
Display* dpy;
int frameTime = 40; // millis

// Input

bool shiftModifier = false;
char pressMap[256];

// Screen and Tablet

int screenWidth;
int screenHeight;
int monitorWidth;
int monitorHeight;
int monitorOffsetX;
int monitorOffsetY;
int windowWidth;
int windowHeight;

float relativeMoveX = 0.3 * frameTime / 1000.f;
float relativeMoveY = 0.3 * frameTime / 1000.f;

float tabletX;
float tabletY;
float tabletWidth;
float tabletHeight;
float tabletRealRatio;

const char* scriptPath;

void updateDisplay();

// Misc

long get_millis() {
    return std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()
            ).count();
}

void sleep(long millis) {
    std::this_thread::sleep_for(std::chrono::milliseconds(millis));
}

// Settings

void updateSettings() {
    char commandBuffer[200];
    sprintf(commandBuffer, "%s %f %f %f %f", scriptPath, (float) tabletX / windowWidth, (float) tabletY / windowHeight,
            (float) tabletWidth / windowWidth, (float) tabletHeight / windowHeight);
    int rc = system(commandBuffer);
    if (rc != 0) {
        std::cout << "[X] Error running script.." << std::endl;
    }
}

// Input Handlers

void checkKeyboard() {
    XEvent xev;
    while (XPending(dpy)) {
        XNextEvent(dpy, &xev);
        switch (xev.type) {
            case KeyPress:
            case KeyRelease:
                KeySym ks;
                XComposeStatus comp;
                if (XLookupString(&xev.xkey, nullptr, 0, &ks, &comp) == 1 && ks < 256 && ks >= 0) {
                    pressMap[ks] = (xev.type == KeyPress);
                    pressMap[ks ^ 0x20] = false;
                }
                break;
            case ConfigureNotify:
                XConfigureEvent xce = xev.xconfigure;
                if (xce.width != windowWidth || xce.height != windowHeight) {
                    windowWidth = xce.width;
                    windowHeight = xce.height;
                    glViewport(0, 0, windowWidth, windowHeight);
                    std::cout << "resize to " << windowWidth << "x" << windowHeight << std::endl;
                }
                break;
        }
    }
}


// Graphics

// converts to glx to traditional (0,0) in upper left corner and pixel coordinates
void drawRect(int x1, int y1, int x2, int y2, bool filled) {
    y1 = windowHeight - y1;
    y2 = windowHeight - y2;
    if (filled) glBegin(GL_QUADS);
    else glBegin(GL_LINE_LOOP);
    glVertex2f(2.f * x1 / windowWidth - 1, 2.f * y1 / windowHeight - 1);
    glVertex2f(2.f * x2 / windowWidth - 1, 2.f * y1 / windowHeight - 1);
    glVertex2f(2.f * x2 / windowWidth - 1, 2.f * y2 / windowHeight - 1);
    glVertex2f(2.f * x1 / windowWidth - 1, 2.f * y2 / windowHeight - 1);
    glVertex2f(2.f * x1 / windowWidth - 1, 2.f * y1 / windowHeight - 1);
    glEnd();
}

void updateRatio() {
    int tabletWidth_New = tabletHeight * tabletRealRatio;
    if (tabletWidth_New > windowWidth) {
        tabletWidth = windowWidth -  tabletX;
    } else {
        if (tabletWidth_New + tabletX > windowWidth) {
            tabletX = windowWidth - tabletWidth_New;
        }
        tabletWidth = tabletWidth_New;
    }
}

void drawTabletArea() {
    glColor4f(0.9f, 0.9f, 0.9f, 0.5f);
    drawRect(tabletX, tabletY, tabletX + tabletWidth, tabletY + tabletHeight, true);
    glColor4f(0.f, 0.f, 0.f, 0.5f);
    drawRect(tabletX, tabletY, tabletX + tabletWidth, tabletY + tabletHeight, false);
}

void updateLogic() {
    static bool settingsUpdated = false;

    if (pressMap['q']) {
        exit(EXIT_SUCCESS);
    }

    if (pressMap['w']) {
        tabletY = std::max(0.f, tabletY - relativeMoveY * windowHeight);
    } else if (pressMap['s']) {
        tabletY = std::min(1.f * windowHeight - tabletHeight, tabletY + relativeMoveY * windowHeight);
    }

    if (pressMap['a']) {
        tabletX = std::max(0.f, tabletX - relativeMoveX * windowWidth);
    } else if (pressMap['d']) {
        tabletX = std::min(1.f * windowWidth - tabletWidth, tabletX + relativeMoveX * windowWidth);
    }

    if (pressMap['W']) {
        float newTabletY = std::max(0.f, tabletY - relativeMoveY * windowHeight);
        tabletHeight = std::min(1.f * windowHeight - tabletY, tabletHeight + tabletY - newTabletY);
        tabletY = newTabletY;
    } else if (pressMap['S']) {
        float newTabletHeight = std::max(100.f, tabletHeight - relativeMoveY * windowHeight);
        tabletY = std::min(1.f * windowHeight - tabletHeight, tabletY + tabletHeight - newTabletHeight);
        tabletHeight = newTabletHeight;
    }

    if (pressMap['A']) {
        tabletWidth = std::max(100.f, tabletWidth - relativeMoveX * windowWidth);
    } else if (pressMap['D']) {
        tabletWidth = std::min(1.f * windowWidth - tabletX, tabletWidth + relativeMoveX * windowWidth);
    }

    if (pressMap['r'] || pressMap['R']) {
        updateRatio();
    }

    if (pressMap['c'] && !settingsUpdated) {
        updateSettings();
        settingsUpdated = true;
    } else {
        settingsUpdated = false;
    }
}

void updateDisplay() {
    glClear(GL_COLOR_BUFFER_BIT);
    // glColor4f(1, 1, 1, 0.5);
    // drawRect(0, 0, windowWidth * 0.5f, windowHeight * 0.5f, true);
    drawTabletArea();
    glXSwapBuffers(dpy, overlay);
}

void createWindow() {
    dpy = XOpenDisplay(NULL);
    if (dpy == nullptr) {
        throw std::runtime_error("Failed to connect to X server");
    }

    Window root = DefaultRootWindow(dpy);

    GLint attributes[] = { GLX_RGBA, GLX_DEPTH_SIZE, 32, GLX_DOUBLEBUFFER, None };
    XVisualInfo vinfo;
    if (!XMatchVisualInfo(dpy, DefaultScreen(dpy), 32, TrueColor, &vinfo) || !vinfo.visual) {
        throw std::runtime_error("No visual found supporting 32 bit color");
    }

    XSetWindowAttributes attrs;
    attrs.override_redirect = true;
    attrs.colormap = XCreateColormap(dpy, root, vinfo.visual, AllocNone);
    attrs.background_pixel = 0;
    attrs.background_pixmap = None;
    attrs.border_pixel = 0;

    overlay = XCreateWindow(dpy, root, monitorOffsetX, monitorOffsetY,
            windowWidth, windowHeight, 0, vinfo.depth, InputOutput, vinfo.visual,
            CWOverrideRedirect | CWColormap | CWBackPixmap | CWBackPixel | CWBorderPixel, &attrs);

    // XStoreName(dpy, overlay, "Tablet Area Display");

    XMapWindow(dpy, overlay);

    GLXContext glc = glXCreateContext(dpy, &vinfo, NULL, GL_TRUE);
    glXMakeCurrent(dpy, overlay, glc);
}

void setupGL() {
    // gl settings
    glClearColor(0, 0, 0, 0);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glShadeModel(GL_FLAT);
    glLineWidth(2.f);
}

void cleanup() {
    XUnmapWindow(dpy, overlay);
    XCloseDisplay(dpy);
}

int main(int argc, char** argv) try {
    if (argc != 11) {
        std::cout << "USAGE: " << argv[0] << " <apply_script> <real_ratio> <mon_offx> <mon_offy> <mon_width> <mon_height> <prev_x> <prev_y> <prev_width> <prev_height>!" << std::endl;
        return EXIT_FAILURE;
    }

    // parse arguments
    scriptPath = argv[1];

    tabletRealRatio = std::stof(argv[2]);

    monitorOffsetX = std::stoi(argv[3]);
    monitorOffsetY = std::stoi(argv[4]);
    monitorWidth = std::stoi(argv[5]);
    monitorHeight = std::stoi(argv[6]);

    windowWidth = monitorWidth;
    windowHeight = monitorHeight;

    tabletX = windowWidth * std::stof(argv[7]);
    tabletY = windowHeight * std::stof(argv[8]);
    tabletWidth = windowWidth * std::stof(argv[9]);
    tabletHeight = windowHeight * std::stof(argv[10]);

    atexit(cleanup);

    createWindow();
    setupGL();

    XGrabKeyboard(dpy, DefaultRootWindow(dpy),
                 True, GrabModeAsync, GrabModeAsync, CurrentTime);

    while (true) {
        checkKeyboard();
        updateLogic();
        updateDisplay();
        sleep(frameTime);
    }

    return EXIT_SUCCESS;
} catch (std::exception& e) {
    std::cout << "FATAL: " << e.what() << std::endl;
    return EXIT_FAILURE;
}
