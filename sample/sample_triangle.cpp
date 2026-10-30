/*
 * ============================================================================
 * FreeGLUT & OpenGL Verification Sample: Colored Triangle
 * 
 * Purpose: A lightweight, beginner-friendly OpenGL program to verify that
 *          FreeGLUT, OpenGL, and Code::Blocks are configured properly.
 * 
 * Controls:
 *   - Press ESC to exit.
 * ============================================================================
 */

#include <GL/glut.h>
#include <stdlib.h>

// Called to render the scene
void display(void) {
    // Clear screen to dark slate gray
    glClearColor(0.12f, 0.15f, 0.18f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // Draw a smooth interpolated RGB triangle
    glBegin(GL_TRIANGLES);
        // Top vertex: Bright Red
        glColor3f(1.0f, 0.2f, 0.2f);
        glVertex2f(0.0f, 0.65f);

        // Bottom-left vertex: Vibrant Green
        glColor3f(0.2f, 0.9f, 0.3f);
        glVertex2f(-0.65f, -0.55f);

        // Bottom-right vertex: Electric Blue
        glColor3f(0.2f, 0.5f, 1.0f);
        glVertex2f(0.65f, -0.55f);
    glEnd();

    // Flush rendering commands to screen
    glFlush();
}

// Called when the window is resized
void reshape(int width, int height) {
    if (height == 0) height = 1;
    glViewport(0, 0, width, height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    // Maintain aspect ratio
    float aspect = (float)width / (float)height;
    if (width >= height) {
        glOrtho(-aspect, aspect, -1.0, 1.0, -1.0, 1.0);
    } else {
        glOrtho(-1.0, 1.0, -1.0 / aspect, 1.0 / aspect, -1.0, 1.0);
    }

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

// Handle keyboard inputs
void keyboard(unsigned char key, int x, int y) {
    // 27 is the ASCII code for ESC
    if (key == 27 || key == 'q' || key == 'Q') {
        exit(0);
    }
}

int main(int argc, char** argv) {
    // Initialize GLUT
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
    glutInitWindowSize(640, 480);
    glutInitWindowPosition(150, 150);

    // Create window
    glutCreateWindow("FreeGLUT & OpenGL - Setup Verified Successfully!");

    // Register callbacks
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutKeyboardFunc(keyboard);

    // Start GLUT main event loop
    glutMainLoop();
    return 0;
}
