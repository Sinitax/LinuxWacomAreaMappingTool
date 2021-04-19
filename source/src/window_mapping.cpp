#include <iostream>
#include <cmath>
#include <fstream>
#include <cstdlib>
#include <cstring>

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/freeglut.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>


// for getting bitmask shift when decoding XImage format

int getShift (long mask) {
    int shift = 0;
    while (mask) {
    if (mask & 1) break;
        shift++;
        mask >>=1;
    }
    return shift;
}


// GLUT and Displaying

static GLuint screenshotTexture;
bool renderReady = false;
const int framecap = 40;


// Events

bool lmousePressed = false;
bool mousePressed = false;
int mouseX = -1;
int mouseY = -1;

bool isDraggingVertex = false;
int dragVertexX = 0;
int dragVertexY = 0;

bool enterPressed = false;
bool ratioPressed = false;


// Screen and Tablet

int screenWidth;
int screenHeight;
int monitorWidth;
int monitorHeight;
int monitorOffsetX;
int monitorOffsetY;
int windowWidth;
int windowHeight;

float tabletX;
float tabletY;
float tabletWidth;
float tabletHeight;
float tabletRealRatio;

const char* scriptPath;



/* FUNC START */


// Settings

void updateSettings() {
    char command_buffer[200];
    sprintf(command_buffer, "%s %f %f %f %f", scriptPath, (float) tabletX / windowWidth, (float) tabletY / windowHeight,
            (float) tabletWidth / windowWidth, (float) tabletHeight / windowHeight);
    int rc = system(command_buffer);
    if (rc != 0) {
        std::cout << "[X] Error running script.." << std::endl;
        glutLeaveMainLoop();
    }
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
    glutPostRedisplay();
}

// Input Handlers

void onKeyboardDown(unsigned char key, int x, int y) {
    if (key == 27) {
        glutLeaveMainLoop();
        return;
    } else if (key == 'r' && !ratioPressed) {
        ratioPressed = true;
        updateRatio();
    } else if (key == 13 && !enterPressed) {
        enterPressed = true;
        updateSettings();
    }
}

void onKeyboardUp(unsigned char key, int x, int y) {
    if (key == 13) enterPressed = false;
    else if (key == 'r') ratioPressed = false;
}

void onMouseMove(int x, int y) {
    if (mouseX == -1) mouseX = x;
    if (mouseY == -1) mouseY = y;

    if (isDraggingVertex) {
        if (dragVertexX) {
            tabletWidth = std::min(windowWidth - tabletX, std::max(0.f, x - tabletX));
        } else {
            tabletWidth = std::min(windowWidth - tabletX, std::max(0.f, tabletWidth + tabletX - x));
            tabletX = (float) std::min(windowWidth, std::max(0, x));
        }
        if (dragVertexY) {
            tabletHeight = std::min(windowHeight - tabletY, std::max(0.f, y - tabletY));
        } else {
            tabletHeight = std::min(windowHeight - tabletY, std::max(0.f, tabletHeight + tabletY - y));
            tabletY = (float) std::min(windowHeight, std::max(0, y));
        }
    } else if (x > tabletX && x < tabletX + tabletWidth && y > tabletY && y < tabletY + tabletHeight) {
        tabletX = std::min(windowWidth - tabletWidth, std::max(0.f, tabletX + x - mouseX));
        tabletY = std::min(windowHeight - tabletHeight, std::max(0.f, tabletY + y - mouseY));
    }

    mouseX = x;
    mouseY = y;

    glutPostRedisplay();
}

void onMousePress(int m, int e, int x, int y) {
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            int vx = tabletX + i * tabletWidth;
            int vy = tabletY + j * tabletHeight;

            int d = abs(vx - x) + abs(vy - y);
            isDraggingVertex = (d < 10);
            if (isDraggingVertex) {
                dragVertexX = i;
                dragVertexY = j;
                break;
            }
        }
        if (isDraggingVertex) break;
    }
    mouseX = x;
    mouseY = y;
}

// Graphics

void refresh(int) {
    renderReady = true;
    glutTimerFunc(1000/framecap, refresh, 0);
}

void drawRect(int x1, int y1, int x2, int y2, bool filled) {
    if (filled) glBegin(GL_QUADS);
    else glBegin(GL_LINE_LOOP);
    glVertex2f(x1, y1);
    glVertex2f(x2, y1);
    glVertex2f(x2, y2);
    glVertex2f(x1, y2);
    glVertex2f(x1, y1);
    glEnd();
}

void drawCircle(int x, int y, int r) {
    const int circleFacets = 10;
    const float facetAngle = 2 *2 *  M_PI / circleFacets;
    glBegin(GL_LINE_LOOP);
    for (int i = 0; i <= circleFacets; i++) {
        glVertex2f(x + cos(i * facetAngle) * r, y + sin(i * facetAngle) * r);
    }
    glEnd();
}

void drawBackground() {
    // draw screenshot
    glClear(GL_COLOR_BUFFER_BIT);
    glEnable(GL_TEXTURE_2D);

    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
    glBindTexture(GL_TEXTURE_2D, screenshotTexture);

    glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0); glVertex2f(0.0, 0.0);
    glTexCoord2f(0.0, 1.0); glVertex2f(0.0, windowHeight);
    glTexCoord2f(1.0, 1.0); glVertex2f(windowWidth, windowHeight);
    glTexCoord2f(1.0, 0.0); glVertex2f(windowWidth, 0.0);
    glEnd();

    glDisable(GL_TEXTURE_2D);
    // glDrawPixels(windowWidth, windowHeight, GL_RGB, GL_UNSIGNED_BYTE, screenshot);

    // draw grid
    glColor4f(0.2f, 0.2f, 0.2f, 0.7f);
    const int lineSpacing = 40;
    int cols = windowWidth / lineSpacing + 1;
    int rows = windowHeight / lineSpacing + 1;
    int offsetx = (windowWidth - cols * lineSpacing) / 2;
    int offsety = (windowHeight - rows * lineSpacing) / 2;
    glBegin(GL_LINES);
    for (int i = 0; i < cols; i++) {
        glVertex2f(offsetx + i * lineSpacing, 0);
        glVertex2f(offsetx + i * lineSpacing, windowHeight);
    }
    for (int i = 0; i < rows; i++) {
        glVertex2f(0, offsety + i * lineSpacing);
        glVertex2f(windowWidth, offsety + i * lineSpacing);
    }
    glEnd();
}

void drawTabletArea() {
    glColor4f(0.9f, 0.9f, 0.9f, 0.5f);
    drawRect(tabletX, tabletY, tabletX + tabletWidth, tabletY + tabletHeight, true);
    glColor4f(1, 1, 1, 0.8f);
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            drawCircle(tabletX + i * tabletWidth, tabletY + j * tabletHeight, 3);
        }
        glBegin(GL_LINES);
        glVertex2f(tabletX + i * tabletWidth, tabletY); 
        glVertex2f(tabletX + i * tabletWidth, tabletY + tabletHeight); 
        glEnd();
    }
    glBegin(GL_LINES);
    for (int i = 0; i < 2; i++) {
        glVertex2f(tabletX, tabletY + i * tabletHeight); 
        glVertex2f(tabletX + tabletWidth, tabletY + i * tabletHeight); 
    }
    glEnd();
}

void updateDisplay() {
    if (!renderReady) return;
    drawBackground();
    drawTabletArea();
    glutSwapBuffers();
    renderReady = false;
}

void onResize(int width, int height) {
    if (width != windowWidth || windowHeight != height) {
        glutReshapeWindow(windowWidth, windowHeight);
        renderReady = true;
        updateDisplay();
        glutSwapBuffers();
    }
}

// Setup

void initGlut(int argc, char** argv) {
    // init glut
    glutInit(&argc, argv);
    glutInitDisplayMode( GLUT_RGB | GLUT_DOUBLE);

    // get screenshot before window opens
    Display* display = XOpenDisplay(nullptr);
    XImage *image = XGetImage(display,
            XRootWindow(display, XDefaultScreen(display)),
            monitorOffsetX, monitorOffsetY, monitorWidth,
            monitorHeight, AllPlanes, XYPixmap);

    // calculate bit mask shifts
    int blue_shift = getShift(image->blue_mask);
    int red_shift = getShift(image->red_mask);
    int green_shift = getShift(image->green_mask);

    // convert screenshot to rgb byte array
    unsigned char* screenshot = new unsigned char[3 * monitorWidth * monitorHeight];
    for (int x = 0; x < monitorWidth; x++) {
        for (int y = 0; y < monitorHeight; y++) {
            unsigned long pixel = XGetPixel(image, x, y);
            unsigned char* pix = &screenshot[3 * (y * monitorWidth + x)];
            pix[0] = ((pixel & image->red_mask) >> red_shift) / 3.f;
            pix[1] = ((pixel & image->green_mask) >> green_shift) / 3.f;
            pix[2] = ((pixel & image->blue_mask) >> blue_shift) / 3.f;
        }
    }

    // set window properties
    glutInitWindowSize(windowWidth, windowHeight);
    glutInitWindowPosition(monitorOffsetX + monitorWidth / 4.f, monitorOffsetY + monitorHeight / 4.f);
    glutCreateWindow("Tablet Tool");

    // set event handlers
    glutDisplayFunc(updateDisplay);
    glutMotionFunc(onMouseMove);
    glutMouseFunc(onMousePress);
    glutKeyboardFunc(onKeyboardDown);
    glutKeyboardUpFunc(onKeyboardUp);
    glutReshapeFunc(onResize);

    // glut settings
    glClearColor(0, 0, 0, 0);
    gluOrtho2D(0, windowWidth, windowHeight, 0);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glShadeModel(GL_FLAT);

    // create screenshot texture
    glGenTextures(1, &screenshotTexture);
    glBindTexture(GL_TEXTURE_2D, screenshotTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, monitorWidth, monitorHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, screenshot);

    // cleanup
    XDestroyImage(image);
    XCloseDisplay(display);
    delete[] screenshot;
}

void cleanup() {
    glDeleteTextures(1, &screenshotTexture);
}

int main(int argc, char** argv) {
    if (argc != 7 && argc != 11) {
        std::cout << "USAGE: " << argv[0] << " <apply_script> <tablet_ratio> <mon_offx> <mon_offy> <mon_width> <mon_height> [<prev_x> <prev_y> <prev_width> <prev_height>]!" << std::endl;
        return 1;
    }

    // parse arguments
    try {
        scriptPath = argv[1];
        tabletRealRatio = std::stof(argv[2]);

        monitorOffsetX = std::stoi(argv[3]);
        monitorOffsetY = std::stoi(argv[4]);
        monitorWidth = std::stoi(argv[5]);
        monitorHeight = std::stoi(argv[6]);

        windowWidth = monitorWidth / 2.f;
        windowHeight = monitorHeight / 2.f;

        if (argc == 11) {
            tabletX = windowWidth * std::stof(argv[7]);
            tabletY = windowHeight * std::stof(argv[8]);
            tabletWidth = windowWidth * std::stof(argv[9]);
            tabletHeight = windowHeight * std::stof(argv[10]);
        } else {
            tabletX = windowWidth / 4;
            tabletY = windowWidth / 4;
            tabletWidth = windowWidth / 2;
            tabletHeight = windowWidth / 2;
        }
    } catch (std::exception& e) {
        std::cerr << "[X] Failed to parse input params" << std::endl;
        return 1;
    }

    initGlut(argc, argv);

    // register cleanup of texture
    if (atexit(cleanup)) {
        std::cerr << "[X] Unable to setup garbage collection, exiting.." << std::endl;
        return 1;
    };

    refresh(0);
    glutMainLoop();
    return 0;
}
