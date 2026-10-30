================================================================================
           FREEGLUT & OPENGL AUTO-PATCHER FOR CODE::BLOCKS (MinGW)
                Created for Educational Ease & Non-Profit Learning
================================================================================

1. WHAT IS THIS?
----------------
Setting up FreeGLUT for OpenGL programming in Code::Blocks with MinGW on Windows
is notoriously frustrating for students and beginners. Most tutorials are
outdated and fail on modern 64-bit MinGW installations, resulting in errors like:
  - "fatal error: GL/glut.h: No such file or directory"
  - "cannot find -lglut32: No such file or directory"
  - "skipping incompatible libfreeglut.a when searching for -lfreeglut"
  - "The code execution cannot proceed because freeglut.dll was not found"

This package provides a 1-click automatic patcher batch script (`patch_freeglut.bat`)
that detects your Code::Blocks MinGW installation, determines whether you have a
32-bit or 64-bit compiler, and copies the necessary headers, libraries, and DLLs
to the exact correct locations automatically.


2. QUICK START (3 STEPS)
------------------------
Step 1: Unzip or extract this folder anywhere on your computer.
Step 2: Right-click `patch_freeglut.bat` and select "Run as administrator".
        (If you double-click it, Windows UAC will prompt you for administrator
         permission automatically.)
Step 3: Press ENTER to accept the auto-detected Code::Blocks MinGW folder,
        or type 'B' to open a folder chooser window and select your folder visually.

That's it! Your MinGW and Code::Blocks are now 100% ready for OpenGL & FreeGLUT.


3. VERIFYING YOUR SETUP
-----------------------
You can test your setup at any time:
- Run `test_freeglut.bat` included in this folder.
- It will automatically compile `sample\sample_triangle.cpp` using your MinGW
  compiler and open a test OpenGL window. If you see the colored triangle,
  everything is working perfectly!


4. HOW TO CREATE AN OPENGL PROJECT IN CODE::BLOCKS
--------------------------------------------------

### METHOD A: Using the GLUT Project Wizard
1. Open Code::Blocks.
2. Click "File" -> "New" -> "Project...".
3. Select "GLUT project" and click "Go".
4. Follow the wizard:
   - When asked for "GLUT's location", select your MinGW folder:
     e.g., C:\Program Files\CodeBlocks\MinGW
   - Click "Next" and finish the wizard.
5. Click the "Build and run" button (the green play button with the yellow gear,
   or press F9).
   Your GLUT application will compile and run immediately!

### METHOD B: Using an Empty or Console Project (Recommended for Assignments)
1. Open Code::Blocks.
2. Click "File" -> "New" -> "Project..." -> "Console Application" (or "Empty project").
3. Choose C++ (or C). Name your project and click "Finish".
4. Add your OpenGL code (or copy the code from `sample\sample_triangle.cpp`).
5. Go to menu: "Project" -> "Build options...".
6. In the left panel, click the top-level project name (so settings apply to
   both Debug and Release).
7. Go to the "Linker settings" tab.
8. In the "Link libraries" box on the left, click "Add" and add these three:
     freeglut
     opengl32
     glu32
   (Note: If your code uses `-lglut32`, you can write `glut32` instead of `freeglut`.)
9. Click "OK".
10. Press F9 ("Build and run")!


5. FOLDER CONTENTS
------------------
  patch_freeglut.bat      -> Main 1-click installer / auto-patcher script.
  test_freeglut.bat       -> Verification test script (compiles sample demo).
  README.txt              -> This instruction and guide file.
  LICENSE.txt             -> Non-profit educational disclaimer & open-source licenses.
  files/                  -> Headers, 32-bit & 64-bit import libraries, and DLLs.
    include/GL/           -> freeglut.h, glut.h, freeglut_ext.h, freeglut_std.h
    lib/x86/              -> 32-bit libraries (libfreeglut.a, libglut32.a, etc.)
    lib/x64/              -> 64-bit libraries (libfreeglut.a, libglut32.a, etc.)
    bin/x86/              -> 32-bit runtime DLLs (freeglut.dll, glut32.dll)
    bin/x64/              -> 64-bit runtime DLLs (freeglut.dll, glut32.dll)
  sample/                 -> Tested sample OpenGL source codes:
    sample_triangle.cpp   -> Colorful 2D RGB triangle demo.
    sample_cube.cpp       -> Interactive 3D rotating color cube demo.


6. LEGAL & NON-PROFIT EDUCATIONAL STATEMENT
-------------------------------------------
This utility is created strictly for non-profit educational purposes to help
students, teachers, and beginners learn OpenGL programming. All original
third-party libraries (FreeGLUT, MinGW, Code::Blocks) belong to their respective
copyright holders. See LICENSE.txt for full details.
================================================================================
