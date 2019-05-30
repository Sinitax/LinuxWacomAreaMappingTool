#include <iostream>
#include <cmath>
#include <fstream>
#include <cstdlib>

#include <GL/gl.h>
#include <GL/freeglut.h>
#include <GL/glu.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>

int windowWidth,
    windowHeight;

Display *display;

unsigned char* screenshot;

bool isReady = false;

int getShift (long mask) {
    int shift = 0;
    while (mask) {
    if (mask & 1) break;
        shift++;
        mask >>=1;
    }
    return shift;
}

bool lmousePressed = false;
bool mousePressed = false;
int mouseX = -1,
    mouseY = -1;

float tabletX;
float tabletY;
float tabletWidth;
float tabletHeight;
float tabletRatio;

bool isDraggingVertex = false;
int dragVertexX = 0;
int dragVertexY = 0;

bool enterPressed = false;
bool ratioPressed = false;

char* filePath;

const int framecap = 30;

// system command

void refresh(int) {
    isReady = true;
    glutTimerFunc(1000/framecap, refresh, 0);
}

void updateSettings() {
    char buffer[200];
    sprintf(buffer, "%s/setsize.sh %f %f %f %f", filePath, tabletX / windowWidth, tabletY / windowHeight, tabletWidth / windowWidth, tabletHeight / windowHeight);
    FILE* pipe = popen(buffer, "r");
    if (!pipe) std::cout << "[!] Failed to apply tablet settings.." << std::endl;
    try {
        while (fgets(buffer, sizeof buffer, pipe) != NULL);
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
}

void updateRatio() {
    int adjustedTabletWidth = tabletHeight * tabletRatio;
    if (windowWidth - tabletX < adjustedTabletWidth) tabletX = windowWidth - adjustedTabletWidth;
    tabletWidth = adjustedTabletWidth;
    glutPostRedisplay();
}

// input

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

// graphics

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
    glDrawPixels(windowWidth, windowHeight, GL_RGB, GL_UNSIGNED_BYTE, screenshot);

    // draw grid
    glColor4f(0.2f, 0.2f, 0.2f, 1.f);
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
    if (!isReady) return;
    drawBackground();
    drawTabletArea();
    glFlush();
    isReady = false;
}

void onResize(int width, int height) {
    if (width != windowWidth || windowHeight != height) glutReshapeWindow(windowWidth, windowHeight);
}

//setup

void initGlut(int argc, char** argv) {
    // glutInit(nullptr, 0);
    glutInit(&argc, argv);
    glutInitDisplayMode( GLUT_RGB | GLUT_SINGLE);

    windowWidth = glutGet(GLUT_SCREEN_WIDTH) / 2.f;
    windowHeight = glutGet(GLUT_SCREEN_HEIGHT) / 2.f;

    // get screenshot before window opens
    display = XOpenDisplay((char *) NULL);
    XImage *image = XGetImage(display, XRootWindow(display, XDefaultScreen(display)), 0, 0, windowWidth * 2, windowHeight * 2, AllPlanes, XYPixmap);

    int blue_shift = getShift(image->blue_mask);
    int red_shift = getShift(image->red_mask);
    int green_shift = getShift(image->green_mask);

    screenshot = new unsigned char[3 * windowWidth * windowHeight];

    for (int x = 0; x < windowWidth; x++) {
        for (int y = 0; y < windowHeight; y++) {
            unsigned long pixel = XGetPixel(image, x * 2, (windowHeight - 1 - y) * 2);
            unsigned char* pix = screenshot + 3 * (y * windowWidth + x);
            pix[0] = ((pixel & image->red_mask) >> red_shift) / 3.f;
            pix[1] = ((pixel & image->green_mask) >> green_shift) / 3.f;
            pix[2] = ((pixel & image->blue_mask) >> blue_shift) / 3.f;
        }
    }

    glutInitWindowSize(windowWidth, windowHeight);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("Wacom Tool");

    glutDisplayFunc(updateDisplay);
    glutMotionFunc(onMouseMove);
    glutMouseFunc(onMousePress);
    glutKeyboardFunc(onKeyboardDown);
    glutKeyboardUpFunc(onKeyboardUp);
    glutReshapeFunc(onResize);

    glClearColor(0, 0, 0, 0);
    gluOrtho2D(0, windowWidth, windowHeight, 0);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void cleanUp() {
    XFree(screenshot);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        std::cout << "Specify path of setsize.sh script!" << std::endl;
        return 1;
    }

    filePath = argv[1];

    // read settings from file
    char buffer[200];
    sprintf(buffer, "%s/settings", filePath);
    std::ifstream ifile(buffer);
    if (!ifile.is_open()) {
        std::cout << "cant read from 'settings' file ... exiting!" << std::endl;
        return 1;
    }

    float tabletWidthRaw, tabletHeightRaw;
    char floatStrings[2][100];
    int lineCounter = 0, 
        charCounter = 0;
    char c;
    bool beginRead = false;
    while (ifile.get(c) && lineCounter < 2) {
        if (beginRead) {
            floatStrings[lineCounter][charCounter] = c;
            charCounter++;
        }

        if (c == '=') {
            beginRead = true;
        } else if (c == '\n') {
            floatStrings[lineCounter][charCounter] = 0;
            lineCounter++;
            charCounter = 0;
            beginRead = false;
        }
    }

    tabletWidthRaw = atof(floatStrings[0]);
    tabletHeightRaw = atof(floatStrings[1]);

    tabletRatio = tabletWidthRaw / tabletHeightRaw;

    initGlut(argc, argv);

    tabletWidth = windowWidth / 2;
    tabletHeight = windowHeight / 2;
    tabletX = windowWidth / 4;
    tabletY = windowHeight / 4;

    refresh(0);
    glutMainLoop();
    cleanUp();
    return 0;
}
