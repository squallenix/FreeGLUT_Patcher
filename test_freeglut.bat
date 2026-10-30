@echo off
setlocal EnableDelayedExpansion

REM ============================================================================
REM Standalone OpenGL & FreeGLUT Verification Test Script
REM ============================================================================

title OpenGL ^& FreeGLUT Verification Test

cd /d "%~dp0"

cls
echo ============================================================================
echo               OPENGL ^& FREEGLUT SETUP VERIFICATION TEST
echo ============================================================================
echo.

REM Detect g++
set "GXX="

for %%d in (
    "C:\Program Files\CodeBlocks\MinGW\bin\g++.exe"
    "C:\Program Files (x86)\CodeBlocks\MinGW\bin\g++.exe"
    "C:\CodeBlocks\MinGW\bin\g++.exe"
    "D:\CodeBlocks\MinGW\bin\g++.exe"
    "E:\CodeBlocks\MinGW\bin\g++.exe"
    "%~dp0..\CodeBlocks\MinGW\bin\g++.exe"
) do (
    if not defined GXX (
        if exist "%%~fd" set "GXX=%%~fd"
    )
)

if not defined GXX (
    for /f "delims=" %%g in ('where g++.exe 2^>nul') do (
        if not defined GXX set "GXX=%%g"
    )
)

if not defined GXX (
    echo [INFO] Could not find g++.exe automatically.
    echo.
    echo Choose an option:
    echo   [B]     Open folder choosing window to locate MinGW bin
    echo   [ENTER] Open folder choosing window to locate MinGW bin
    echo   [Path]  Type or paste the path to g++.exe or MinGW bin
    echo.
    set "USER_GXX="
    set /p "USER_GXX=> "
    set "USER_GXX=!USER_GXX:"=!"
    if "!USER_GXX!"=="" goto :browse_gxx
    if /i "!USER_GXX!"=="B" goto :browse_gxx
    set "GXX=!USER_GXX!"
    if exist "!GXX!\g++.exe" set "GXX=!GXX!\g++.exe"
    goto :check_gxx

    :browse_gxx
    echo.
    echo [*] Opening folder chooser window...
    set "PICKED_GXX="
    for /f "usebackq delims=" %%f in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\select_folder.ps1" 2^>nul`) do (
        set "PICKED_GXX=%%f"
    )
    if not "!PICKED_GXX!"=="" (
        if exist "!PICKED_GXX!\g++.exe" set "GXX=!PICKED_GXX!\g++.exe"
        if exist "!PICKED_GXX!\bin\g++.exe" set "GXX=!PICKED_GXX!\bin\g++.exe"
    )
)

:check_gxx

if not exist "%GXX%" (
    echo.
    echo [ERROR] Could not find g++.exe at: "%GXX%"
    echo Please make sure MinGW is installed with Code::Blocks.
    echo.
    echo Press ENTER to exit...
    pause
    exit /b 1
)

echo [+] Using C++ Compiler: "%GXX%"
for %%p in ("%GXX%\..") do set "PATH=%%~fp;!PATH!"
echo.
echo Choose a test demo to compile and run:
echo   [1] 2D Color Triangle Demo [Basic GLUT verification]
echo   [2] 3D Rotating Color Cube Demo [Advanced 3D, depth buffer, timer]
echo.
set "DEMO_CHOICE=1"
set /p "DEMO_CHOICE=Enter choice [1 or 2, default is 1]: "
set "DEMO_CHOICE=!DEMO_CHOICE: =!"

if "!DEMO_CHOICE!"=="2" (
    set "SAMPLE_SRC=%~dp0sample\sample_cube.cpp"
    set "SAMPLE_EXE=%~dp0sample\sample_cube_test.exe"
    set "DEMO_NAME=3D Rotating Color Cube"
) else (
    set "SAMPLE_SRC=%~dp0sample\sample_triangle.cpp"
    set "SAMPLE_EXE=%~dp0sample\sample_triangle_test.exe"
    set "DEMO_NAME=2D Color Triangle"
)

echo.
echo [*] Compiling %DEMO_NAME%...
echo     Command: "%GXX%" "%SAMPLE_SRC%" -lfreeglut -lopengl32 -lglu32 -o "%SAMPLE_EXE%"
"%GXX%" "%SAMPLE_SRC%" -lfreeglut -lopengl32 -lglu32 -o "%SAMPLE_EXE%"

if not exist "%SAMPLE_EXE%" (
    echo.
    echo [*] Retrying with -lglut32...
    "%GXX%" "%SAMPLE_SRC%" -lglut32 -lopengl32 -lglu32 -o "%SAMPLE_EXE%"
)

if exist "%SAMPLE_EXE%" (
    echo.
    echo ============================================================================
    echo [SUCCESS] Compilation succeeded!
    echo Launching the OpenGL window now... [Close the window or press ESC to finish]
    echo ============================================================================
    start "" /wait "%SAMPLE_EXE%"
    del "%SAMPLE_EXE%" >nul 2>&1
    echo.
    echo [+] OpenGL FreeGLUT test completed successfully!
) else (
    echo.
    echo ============================================================================
    echo [ERROR] Compilation failed!
    echo Please make sure you have run patch_freeglut.bat as Administrator first.
    echo ============================================================================
)

echo.
echo Press ENTER to exit...
pause
exit /b 0
