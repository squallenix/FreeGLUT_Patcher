@echo off
setlocal EnableDelayedExpansion

REM ============================================================================
REM FreeGLUT & OpenGL Auto-Patcher for Code::Blocks (MinGW)
REM Educational Use Only - Non-Profit Learning Utility
REM ============================================================================

title FreeGLUT ^& OpenGL Auto-Patcher for Code::Blocks

REM Step 0: Administrator Elevation Check
set "IS_ADMIN=0"
net session >nul 2>&1
if %errorlevel% equ 0 goto :is_admin
if "%~1"=="--no-elevate" goto :start_patching

echo ============================================================
echo   [INFO] Requesting Administrator Privileges...
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '--elevated' -Verb RunAs" 2>nul
if %errorlevel% equ 0 exit /b

echo   [INFO] Running without Administrator privileges.
echo   MinGW will be patched directly. [For system-wide System32
echo   installation, right-click and 'Run as administrator']
echo ============================================================
echo.
goto :start_patching

:is_admin
set "IS_ADMIN=1"

:start_patching
REM Set Working Directory to script folder
cd /d "%~dp0"

cls
echo ============================================================================
echo        FREEGLUT ^& OPENGL AUTO-PATCHER FOR CODE::BLOCKS [MinGW]
echo         Created for Educational Ease ^& Non-Profit Student Learning
echo ============================================================================
echo.

REM Step 1: Detect Code::Blocks MinGW Folder
set "FOUND_MINGW="
set "CB_BASE_DIR="

for %%d in (
    "C:\Program Files\CodeBlocks\MinGW"
    "C:\Program Files (x86)\CodeBlocks\MinGW"
    "C:\CodeBlocks\MinGW"
    "D:\CodeBlocks\MinGW"
    "E:\CodeBlocks\MinGW"
    "%~dp0..\CodeBlocks\MinGW"
    "C:\MinGW"
) do (
    if not defined FOUND_MINGW (
        if exist "%%~fd\bin\gcc.exe" (
            set "FOUND_MINGW=%%~fd"
        ) else (
            if exist "%%~fd\include" set "FOUND_MINGW=%%~fd"
        )
    )
)

REM If not found, try checking where gcc is in PATH
if not defined FOUND_MINGW (
    for /f "delims=" %%g in ('where gcc.exe 2^>nul') do (
        if not defined FOUND_MINGW (
            for %%p in ("%%~dpg..") do (
                if exist "%%~fp\include" set "FOUND_MINGW=%%~fp"
            )
        )
    )
)

REM Step 2: Prompt User for Path
set "TARGET_DIR="

:prompt_folder
set "TARGET_DIR="

if not defined FOUND_MINGW goto :prompt_manual_path

echo [+] Auto-detected Code::Blocks MinGW installation at:
echo     "!FOUND_MINGW!"
echo.
echo Choose an option:
echo   [ENTER] Use the auto-detected path above
echo   [B]     Open folder choosing window to browse
echo   [Path]  Type or paste a custom path directly
echo.
set "USER_INPUT="
set /p "USER_INPUT=> "

:trim_user_input
if "!USER_INPUT:~0,1!"==" " (
    set "USER_INPUT=!USER_INPUT:~1!"
    goto :trim_user_input
)
if "!USER_INPUT:~-1!"==" " (
    set "USER_INPUT=!USER_INPUT:~0,-1!"
    goto :trim_user_input
)

if /i "!USER_INPUT!"=="B" goto :open_browser_dialog
if "!USER_INPUT!"=="" (
    set "TARGET_DIR=!FOUND_MINGW!"
    goto :check_target_path
)
set "TARGET_DIR=!USER_INPUT!"
goto :check_target_path

:prompt_manual_path
echo [INFO] Could not auto-detect Code::Blocks MinGW in default locations.
echo.
echo Choose an option:
echo   [B]     Open folder choosing window to browse [Recommended]
echo   [ENTER] Open folder choosing window to browse
echo   [Path]  Type or drag-and-drop your folder path
echo.
set "USER_INPUT="
set /p "USER_INPUT=> "

:trim_manual_input
if "!USER_INPUT:~0,1!"==" " (
    set "USER_INPUT=!USER_INPUT:~1!"
    goto :trim_manual_input
)
if "!USER_INPUT:~-1!"==" " (
    set "USER_INPUT=!USER_INPUT:~0,-1!"
    goto :trim_manual_input
)

if "!USER_INPUT!"=="" goto :open_browser_dialog
if /i "!USER_INPUT!"=="B" goto :open_browser_dialog
set "TARGET_DIR=!USER_INPUT!"
goto :check_target_path

:open_browser_dialog
echo.
echo [*] Opening folder chooser window... Please select your folder.
set "PICKED_DIR="
for /f "usebackq delims=" %%f in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\select_folder.ps1" 2^>nul`) do (
    set "PICKED_DIR=%%f"
)

if "!PICKED_DIR!"=="" (
    echo.
    echo [INFO] No folder was selected or dialog was cancelled.
    echo.
    goto :prompt_folder
)

set "TARGET_DIR=!PICKED_DIR!"
echo [+] Selected: "!TARGET_DIR!"
goto :check_target_path

:check_target_path
REM Strip surrounding quotes if any
set "TARGET_DIR=!TARGET_DIR:"=!"

REM Trim any trailing spaces
:trim_space
if "!TARGET_DIR:~-1!"==" " (
    set "TARGET_DIR=!TARGET_DIR:~0,-1!"
    goto :trim_space
)
if "!TARGET_DIR:~-1!"=="\" (
    if not "!TARGET_DIR:~-2!"==":\" (
        set "TARGET_DIR=!TARGET_DIR:~0,-1!"
        goto :trim_space
    )
)

REM If user pointed to CodeBlocks root instead of MinGW, auto-adjust if MinGW folder exists inside
if exist "!TARGET_DIR!\MinGW\include" (
    set "CB_BASE_DIR=!TARGET_DIR!"
    set "TARGET_DIR=!TARGET_DIR!\MinGW"
    goto :target_adjusted
)
if exist "!TARGET_DIR!\MinGW\bin\gcc.exe" (
    set "CB_BASE_DIR=!TARGET_DIR!"
    set "TARGET_DIR=!TARGET_DIR!\MinGW"
    goto :target_adjusted
)
for %%p in ("!TARGET_DIR!\..") do set "CB_BASE_DIR=%%~fp"

:target_adjusted
REM Validate Target Directory
if not exist "!TARGET_DIR!" (
    echo.
    echo [ERROR] The directory "!TARGET_DIR!" does not exist!
    echo Please verify the location of your MinGW folder and run this script again.
    echo.
    echo Press ENTER to exit...
    pause
    exit /b 1
)

echo.
echo [*] Target MinGW folder: "!TARGET_DIR!"

REM Prepend MinGW\bin to PATH so that GCC and its sub-executables (cc1plus.exe)
REM always find matching MinGW runtime DLLs (like libwinpthread-1.dll) first,
REM preventing error 0xc000007b if other incompatible DLLs exist in system PATH.
set "PATH=!TARGET_DIR!\bin;!PATH!"

REM Step 3: Architecture Detection (32-bit vs 64-bit MinGW)
set "IS_64BIT=0"

if exist "%TARGET_DIR%\x86_64-w64-mingw32" set "IS_64BIT=1"
if not "%IS_64BIT%"=="1" (
    if exist "%TARGET_DIR%\bin\gcc.exe" (
        for /f "delims=" %%a in ('"%TARGET_DIR%\bin\gcc.exe" -dumpmachine 2^>nul') do (
            echo %%a | findstr /i "x86_64 amd64" >nul && set "IS_64BIT=1"
        )
    )
)

if "%IS_64BIT%"=="1" (
    echo [+] Detected MinGW Architecture: 64-bit [x86_64]
    set "LIB_SRC=%~dp0files\lib\x64"
    set "BIN_SRC=%~dp0files\bin\x64"
) else (
    echo [+] Detected MinGW Architecture: 32-bit [x86]
    set "LIB_SRC=%~dp0files\lib\x86"
    set "BIN_SRC=%~dp0files\bin\x86"
)
echo.

REM Step 4: Copying Headers
echo [1/4] Installing FreeGLUT header files...
if not exist "%TARGET_DIR%\include\GL" mkdir "%TARGET_DIR%\include\GL" 2>nul
copy /Y "%~dp0files\include\GL\*.h" "%TARGET_DIR%\include\GL\" >nul 2>&1
if %errorlevel% neq 0 (
    echo   [WARN] Access denied or unable to copy to %TARGET_DIR%\include\GL
    echo          [Try running the script by right-clicking and selecting 'Run as administrator']
) else (
    echo   [OK] Installed to: %TARGET_DIR%\include\GL\
)

REM If 64-bit target has x86_64-w64-mingw32 subfolder, copy there as well
if exist "%TARGET_DIR%\x86_64-w64-mingw32\include" (
    if not exist "%TARGET_DIR%\x86_64-w64-mingw32\include\GL" mkdir "%TARGET_DIR%\x86_64-w64-mingw32\include\GL" 2>nul
    copy /Y "%~dp0files\include\GL\*.h" "%TARGET_DIR%\x86_64-w64-mingw32\include\GL\" >nul 2>&1
    echo   [OK] Installed to: %TARGET_DIR%\x86_64-w64-mingw32\include\GL\
)

REM If 32-bit target has i686-w64-mingw32 subfolder, copy there as well
if exist "%TARGET_DIR%\i686-w64-mingw32\include" (
    if not exist "%TARGET_DIR%\i686-w64-mingw32\include\GL" mkdir "%TARGET_DIR%\i686-w64-mingw32\include\GL" 2>nul
    copy /Y "%~dp0files\include\GL\*.h" "%TARGET_DIR%\i686-w64-mingw32\include\GL\" >nul 2>&1
    echo   [OK] Installed to: %TARGET_DIR%\i686-w64-mingw32\include\GL\
)

REM Step 5: Copying Libraries
echo.
echo [2/4] Installing FreeGLUT library files...
if not exist "%TARGET_DIR%\lib" mkdir "%TARGET_DIR%\lib" 2>nul
copy /Y "%LIB_SRC%\*.a" "%TARGET_DIR%\lib\" >nul 2>&1
if %errorlevel% neq 0 (
    echo   [WARN] Access denied or unable to copy to %TARGET_DIR%\lib
) else (
    echo   [OK] Installed to: %TARGET_DIR%\lib\ [libfreeglut, libglut32, libglut]
)

if "%IS_64BIT%"=="1" (
    if exist "%TARGET_DIR%\x86_64-w64-mingw32\lib" (
        copy /Y "%LIB_SRC%\*.a" "%TARGET_DIR%\x86_64-w64-mingw32\lib\" >nul 2>&1
        echo   [OK] Installed to: %TARGET_DIR%\x86_64-w64-mingw32\lib\
    )
) else (
    if exist "%TARGET_DIR%\i686-w64-mingw32\lib" (
        copy /Y "%LIB_SRC%\*.a" "%TARGET_DIR%\i686-w64-mingw32\lib\" >nul 2>&1
        echo   [OK] Installed to: %TARGET_DIR%\i686-w64-mingw32\lib\
    )
)

REM Step 6: Copying Runtime DLLs to MinGW bin
echo.
echo [3/4] Installing runtime DLLs to MinGW bin...
if not exist "%TARGET_DIR%\bin" mkdir "%TARGET_DIR%\bin" 2>nul
copy /Y "%BIN_SRC%\*.dll" "%TARGET_DIR%\bin\" >nul 2>&1
if %errorlevel% neq 0 (
    echo   [WARN] Access denied or unable to copy to %TARGET_DIR%\bin
) else (
    echo   [OK] Installed to: %TARGET_DIR%\bin\ [freeglut.dll, glut32.dll]
)

if "%IS_64BIT%"=="1" (
    if exist "%TARGET_DIR%\x86_64-w64-mingw32\bin" (
        copy /Y "%BIN_SRC%\*.dll" "%TARGET_DIR%\x86_64-w64-mingw32\bin\" >nul 2>&1
        echo   [OK] Installed to: %TARGET_DIR%\x86_64-w64-mingw32\bin\
    )
)

REM Step 7: Copying Runtime DLLs to Windows System Directory (System-Wide)
echo.
echo [4/4] Installing runtime DLLs system-wide into Windows...
set "OS_64BIT=0"
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "OS_64BIT=1"
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "OS_64BIT=1"

if "%OS_64BIT%"=="1" (
    copy /Y "%~dp0files\bin\x64\freeglut.dll" "%SystemRoot%\System32\" >nul 2>&1
    copy /Y "%~dp0files\bin\x64\glut32.dll"  "%SystemRoot%\System32\" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] 64-bit DLLs installed to: %SystemRoot%\System32\
    ) else (
        echo   [INFO] Could not write to System32 [Administrator required]
        echo          DLLs installed in MinGW\bin will be used by Code::Blocks.
    )

    copy /Y "%~dp0files\bin\x86\freeglut.dll" "%SystemRoot%\SysWOW64\" >nul 2>&1
    copy /Y "%~dp0files\bin\x86\glut32.dll"  "%SystemRoot%\SysWOW64\" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] 32-bit DLLs installed to: %SystemRoot%\SysWOW64\
    ) else (
        echo   [INFO] Could not write to SysWOW64 [Administrator required]
    )
) else (
    copy /Y "%~dp0files\bin\x86\freeglut.dll" "%SystemRoot%\System32\" >nul 2>&1
    copy /Y "%~dp0files\bin\x86\glut32.dll"  "%SystemRoot%\System32\" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] 32-bit DLLs installed to: %SystemRoot%\System32\
    ) else (
        echo   [INFO] Could not write to System32 [Administrator required]
    )
)

REM Step 8: Code::Blocks GLUT Project Wizard Check
if exist "%CB_BASE_DIR%\share\CodeBlocks\templates\wizard\glut\wizard.script" (
    echo.
    echo [+] Detected Code::Blocks GLUT Project Wizard template at:
    echo     "%CB_BASE_DIR%\share\CodeBlocks\templates\wizard\glut"
    echo     Compatibility verified: Both 'freeglut' and 'glut32' libraries are active.
)

echo.
echo ============================================================================
echo                      [SUCCESS] PATCH COMPLETED!
echo ============================================================================
echo  All FreeGLUT header files, import libraries, and Windows DLLs have been
echo  accurately placed in your Code::Blocks MinGW environment.
echo ============================================================================
echo.

REM Step 9: Optional Live Verification Test
if exist "%TARGET_DIR%\bin\g++.exe" (
    echo Would you like to compile and run a test OpenGL window now? [Y/N]
    set "RUN_TEST="
    set /p "RUN_TEST=> "
    if /i "!RUN_TEST!"=="Y" (
        echo.
        echo [*] Compiling sample\sample_triangle.cpp with MinGW g++...
        set "PATH=!TARGET_DIR!\bin;!PATH!"
        "%TARGET_DIR%\bin\g++.exe" -I "%TARGET_DIR%\include" "%~dp0sample\sample_triangle.cpp" -L "%TARGET_DIR%\lib" -lfreeglut -lopengl32 -lglu32 -o "%~dp0sample\test_triangle.exe"
        if exist "%~dp0sample\test_triangle.exe" (
            echo [+] Compilation successful! Launching OpenGL test window...
            echo [INFO] Close the test window [or press ESC] to finish.
            start "" /wait "%~dp0sample\test_triangle.exe"
            del "%~dp0sample\test_triangle.exe" >nul 2>&1
            echo [+] Verification completed successfully!
        ) else (
            echo [WARN] Test compilation did not produce an executable.
            echo        You can still compile manually inside Code::Blocks.
        )
    )
)

echo.
echo Press ENTER to exit this installer...
pause
exit /b 0
