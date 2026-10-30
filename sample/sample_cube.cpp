/*
 * ============================================================================
 * FreeGLUT & OpenGL Sample: Rotating 3D Color Cube
 * 
 * Purpose: An interactive 3D OpenGL application demonstrating FreeGLUT timers,
 *          depth testing, 3D transformations, and double buffering.
 * 
 * Controls:
 *   - SPACE: Pause / Resume rotation
 *   - ESC: Exit
 * ============================================================================
 */

#include <GL/glut.h>
#include <stdlib.h>

static float angleX = 30.0f;
static float angleY = 45.0f;
static bool isRotating = true;

// Render the 3D Cube
void display(void) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();

    // Move cube back so it is visible to the camera
    glTranslatef(0.0f, 0.0f, -5.0f);

    // Apply rotation angles
    glRotatef(angleX, 1.0f, 0.0f, 0.0f);
    glRotatef(angleY, 0.0f, 1.0f, 0.0f);

    glBegin(GL_QUADS);
        // Front face (Red)
        glColor3f(1.0f, 0.2f, 0.2f);
        glVertex3f(-1.0f, -1.0f,  1.0f);
        glVertex3f( 1.0f, -1.0f,  1.0f);
        glVertex3f( 1.0f,  1.0f,  1.0f);
        glVertex3f(-1.0f,  1.0f,  1.0f);

        // Back face (Green)
        glColor3f(0.2f, 0.9f, 0.3f);
        glVertex3f(-1.0f, -1.0f, -1.0f);
        glVertex3f(-1.0f,  1.0f, -1.0f);
        glVertex3f( 1.0f,  1.0f, -1.0f);
        glVertex3f( 1.0f, -1.0f, -1.0f);

        // Top face (Blue)
        glColor3f(0.2f, 0.5f, 1.0f);
        glVertex3f(-1.0f,  1.0f, -1.0f);
        glVertex3f(-1.0f,  1.0f,  1.0f);
        glVertex3f( 1.0f,  1.0f,  1.0f);
        glVertex3f( 1.0f,  1.0f, -1.0f);

        // Bottom face (Yellow)
        glColor3f(1.0f, 0.9f, 0.2f);
        glVertex3f(-1.0f, -1.0f, -1.0f);
        glVertex3f( 1.0f, -1.0f, -1.0f);
        glVertex3f( 1.0f, -1.0f,  1.0f);
        glVertex3f(-1.0f, -1.0f,  1.0f);

        // Right face (Magenta)
        glColor3f(0.9f, 0.2f, 0.9f);
        glVertex3f( 1.0f, -1.0f, -1.0f);
        glVertex3f( 1.0f,  1.0f, -1.0f);
        glVertex3f( 1.0f,  1.0f,  1.0f);
        glVertex3f( 1.0f, -1.0f,  1.0f);

        // Left face (Cyan)
        glColor3f(0.2f, 0.9f, 0.9f);
        glVertex3f(-1.0f, -1.0f, -1.0f);
        glVertex3f(-1.0f, -1.0f,  1.0f);
        glVertex3f(-1.0f,  1.0f,  1.0f);
        glVertex3f(-1.0f,  1.0f, -1.0f);
    glEnd();

    // Swap double buffers
    glutSwapBuffers();
}

// Timer for 60 FPS animation
void timer(int value) {
    if (isRotating) {
        angleX += 0.8f;
        angleY += 1.2f;
        if (angleX > 360.0f) angleX -= 360.0f;
        if (angleY > 360.0f) angleY -= 360.0f;
        glutPostRedisplay();
    }
    glutTimerFunc(16, timer, 0);
}

// Reshape projection matrix
void reshape(int width, int height) {
    if (height == 0) height = 1;
    glViewport(0, 0, width, height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0, (double)width / (double)height, 1.0, 100.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

// Keyboard input
void keyboard(unsigned char key, int x, int y) {
    if (key == 27 || key == 'q' || key == 'Q') {
        exit(0);
    } else if (key == ' ') {
        isRotating = !isRotating;
    }
}

int main(int argc, char** argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(700, 500);
    glutInitWindowPosition(150, 150);
    glutCreateWindow("FreeGLUT & OpenGL - 3D Cube Demo [SPACE: Pause, ESC: Exit]");

    // Enable Depth Testing
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.08f, 0.08f, 0.12f, 1.0f);

    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutKeyboardFunc(keyboard);
    glutTimerFunc(16, timer, 0);

    glutMainLoop();
    return 0;
}
