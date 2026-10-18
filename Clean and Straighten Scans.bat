@echo off

REM Clean and Straighten Scans.bat
REM (c) 2026 Fred Thompson
REM
REM PURPOSE:      Cleans and un-tilts PNG scans of documents, then crops them closely to the real
REM               content. Near-white pixels become white. Small stray specks, including the pale
REM               yellow ones left by dirty scanner glass, become white. Only pale pixels can be
REM               removed as specks, so colored and dark content is never touched. The tilt is
REM               measured from the dominant near-horizontal lines in the image and corrected by
REM               rotating. Page edges are not used. The result is cropped with a few pixels of
REM               white border on all four sides.
REM DATE:         2026-10-17
REM USAGE:        Drop .png files and/or folders onto this file, or run it with no argument and
REM               type a path at the prompt. A folder means the .png files directly inside it,
REM               with no subfolders. The window stays open for repeated input until you enter
REM               Q, EXIT or QUIT.
REM DEPENDENCIES: ImageMagick 7, portable Q16 x64 build. Home page: http://www.imagemagick.org/
REM               The folder that holds magick.exe is set in IM_DIR in the Data section below.
REM               No other tool is used. No elevation is needed.
REM ASSUMPTIONS:  A source is skipped when its name-clean.png already exists, so a re-run only fills
REM               gaps. Files whose names already end in -clean are ignored. The settings in the
REM               Data section tune the near-white level, speck size, tilt search, and border.
REM               Each result is built in the temp folder and moved beside its source only on
REM               success.
REM RISK:         LOW. A source is never changed or deleted. Nothing this script writes replaces an
REM               existing file. The only files it removes are its own temp result and roots file.
REM LIMIT:        A pale mark narrower than twice SPECK_RADIUS plus one pixels (9 by default) is
REM               removed as a speck when it sits away from darker content. That can include a
REM               thin pale line or a small pale detail you want. See Known limits in the README.
REM               Check the first results from a new kind of scan before running a large batch.
REM RESET PATH:   Delete the generated -clean.png files.
REM
REM NAMING:       "<base>-clean.png", saved beside the source.

REM -- Prologue

        set "STARTDIR=%CD%"
        cd /d "%~dp0"
        setlocal DisableDelayedExpansion
        set "EXITCODE=0"

REM -- Data section

    REM Folder that holds magick.exe.

        set "IM_DIR=C:\Portable\- Linked\Graphics\ImageMagick\Q16 x64"
        set "MAGICK=%IM_DIR%\magick.exe"

    REM Darkest-channel level, in percent of 255, at or above which a pixel counts as near-white. 90 is 230.

        set "LIGHT_PCT=90"

    REM A pixel whose red and green are both at least this percent of 255 is pale enough to be a speck. 67 is 171.

        set "PALE_PCT=67"

    REM A pixel whose darkest channel is below this percent of 255 is content and is never a speck. 55 is 140.

        set "FLOOR_PCT=55"

    REM Pale pixels within this many pixels of content are protected from speck removal.

        set "PROTECT_RADIUS=3"

    REM Light specks narrower than twice this radius, plus one, are made white.

        set "SPECK_RADIUS=4"

    REM Share of the image the tilt search looks at, in percent.

        set "DESKEW_PCT=40"

    REM White border left around the cropped result, in pixels.

        set "MARGIN=8"

    REM Working values. ROOTSFILE lists the dropped or typed paths. TMPFILE is the result being built.

        set "ROOTSFILE="
        set "TMPFILE="

REM -- ImageMagick check

        if not exist "%MAGICK%" goto :NO_MAGICK
        pushd "%STARTDIR%"

REM -- Drag-and-drop path

        if "%~1"=="" goto :SHOW_INSTRUCTIONS

        set "ROOTSFILE=%TEMP%\scan_clean_roots_%RANDOM%.txt"
        if exist "%ROOTSFILE%" del /F /Q "%ROOTSFILE%" >nul 2>&1

    :ARG_LOOP

        if "%~1"=="" goto :ARGS_DONE
        set "CURRENT_ARG=%~1"
        setlocal EnableDelayedExpansion
        >>"%ROOTSFILE%" echo(!CURRENT_ARG!
        endlocal
        shift
        goto :ARG_LOOP

    :ARGS_DONE

        echo.
        echo  +----------------------------------------------------------+
        echo  ^|  CLEAN AND STRAIGHTEN SCANS                              ^|
        echo  ^|                                                          ^|
        echo  ^|  Input received via drag-and-drop.                       ^|
        echo  ^|  Input: .png files, or folders of .png files             ^|
        echo  +----------------------------------------------------------+
        echo.
        echo   Processing dropped items...
        echo.

        call :PROCESS
        echo.
        pause

REM -- Interactive path

    :SHOW_INSTRUCTIONS

        echo.
        echo  +----------------------------------------------------------+
        echo  ^|  CLEAN AND STRAIGHTEN SCANS                              ^|
        echo  ^|                                                          ^|
        echo  ^|  HOW TO USE                                              ^|
        echo  ^|                                                          ^|
        echo  ^|  At the prompt below, enter ONE of the following:        ^|
        echo  ^|    - A single .png file path                             ^|
        echo  ^|    - A folder path, for the .png files directly inside   ^|
        echo  ^|    - Q, EXIT, or QUIT to quit                            ^|
        echo  ^|                                                          ^|
        echo  ^|  Tip: drag a file or folder from Explorer into this      ^|
        echo  ^|  window to paste its path automatically.                 ^|
        echo  ^|                                                          ^|
        echo  ^|  Each result is saved beside its source as               ^|
        echo  ^|  name-clean.png. The source is never changed.            ^|
        echo  ^|                                                          ^|
        echo  ^|  Input: .png files, or folders of .png files             ^|
        echo  +----------------------------------------------------------+

    :INPUT_LOOP

        echo.
        echo   Drop or type a file/folder path, or Q to quit:
        echo.
        set "INPUT_PATH="
        <nul set /p "=  > "
        set /p "INPUT_PATH="
        setlocal EnableDelayedExpansion

        if /i "!INPUT_PATH!"=="q"    ( endlocal & goto :CLEANUP )
        if /i "!INPUT_PATH!"=="exit" ( endlocal & goto :CLEANUP )
        if /i "!INPUT_PATH!"=="quit" ( endlocal & goto :CLEANUP )

        if not defined INPUT_PATH (
            endlocal
            echo.
            echo   ERROR: No path entered.
            goto :INPUT_LOOP
        )

        set "INPUT_PATH=!INPUT_PATH:"=!"

        if not exist "!INPUT_PATH!" (
            endlocal
            echo.
            echo   ERROR: Path not found.
            goto :INPUT_LOOP
        )

        endlocal & set "TYPED_PATH=%INPUT_PATH%"

        set "ROOTSFILE=%TEMP%\scan_clean_roots_%RANDOM%.txt"
        if exist "%ROOTSFILE%" del /F /Q "%ROOTSFILE%" >nul 2>&1
        setlocal EnableDelayedExpansion
        >>"%ROOTSFILE%" echo(!TYPED_PATH!
        endlocal

        echo.
        echo   Processing...
        echo.

        call :PROCESS
        goto :INPUT_LOOP

    :NO_MAGICK

        echo.
        echo   ImageMagick was not found at "%IM_DIR%"
        echo   You must point this file to ImageMagick before it can run.
        echo   Open this file in a text editor. In the Data section near the top,
        echo   set IM_DIR to the folder that holds magick.exe.
        echo   ImageMagick home page: http://www.imagemagick.org/
        echo.
        set "EXITCODE=2"
        pause
        goto :CLEANUP

    :CLEANUP

        if defined TMPFILE if exist "%TMPFILE%" del /F /Q "%TMPFILE%" >nul 2>&1
        if defined ROOTSFILE if exist "%ROOTSFILE%" del /F /Q "%ROOTSFILE%" >nul 2>&1
        popd
        endlocal & set "STARTDIR=" & exit /b %EXITCODE%

REM -- Subroutines

    REM Reads the roots file and hands each dropped or typed path on, then removes the roots file.

    :PROCESS

        if not exist "%ROOTSFILE%" exit /b 0
        for /f "usebackq delims=" %%R in ("%ROOTSFILE%") do call :HANDLE_ARG "%%R"
        del /F /Q "%ROOTSFILE%" >nul 2>&1
        exit /b 0

    REM Decides whether a path is a folder or a file and passes each .png on.

    :HANDLE_ARG

        set "ARG_ATTR="
        for %%I in ("%~1") do set "ARG_ATTR=%%~aI"
        if not defined ARG_ATTR goto :ARG_MISSING
        if /i "%ARG_ATTR:~0,1%"=="d" goto :ARG_FOLDER
        call :PROCESS_FILE "%~f1"
        exit /b 0

    :ARG_MISSING

        echo   Not found: "%~1"
        set "EXITCODE=1"
        exit /b 0

    :ARG_FOLDER

        for %%F in ("%~f1\*.png") do call :PROCESS_FILE "%%~fF"
        exit /b 0

    REM Cleans, un-tilts, and crops one .png. The result is built in the temp folder and moved into place on success.

    :PROCESS_FILE

        if /i not "%~x1"==".png" exit /b 0
        set "SRC_NAME=%~n1"
        if /i "%SRC_NAME:~-6%"=="-clean" exit /b 0
        if exist "%~dpn1-clean.png" goto :FILE_SKIPPED
        set "OUTFILE=%~dpn1-clean.png"
        set "TMPFILE=%TEMP%\_Clean_Scans_%RANDOM%.png"
        echo   Cleaning "%~nx1"

    REM Steps in order: darkest-channel image, near-white mask, pale and eligible masks, protected zone around content,
    REM pale candidates outside it, small candidates to remove, white fill, tilt correction, close crop with a border.

        "%MAGICK%" "%~1" ^
            "(" +clone -channel RGB -separate +channel -evaluate-sequence Min -write mpr:MIN +delete ")" ^
            "(" mpr:MIN -threshold %LIGHT_PCT%%% -write mpr:LIGHT +delete ")" ^
            "(" +clone -channel RG -separate +channel -evaluate-sequence Min -threshold %PALE_PCT%%% -write mpr:PALE +delete ")" ^
            "(" mpr:MIN -threshold %FLOOR_PCT%%% mpr:PALE -compose Multiply -composite -write mpr:ELIG +delete ")" ^
            "(" mpr:ELIG -negate -morphology Dilate Disk:%PROTECT_RADIUS% -negate -write mpr:UNPROT +delete ")" ^
            "(" mpr:LIGHT -negate mpr:ELIG -compose Multiply -composite mpr:UNPROT -compose Multiply -composite -write mpr:CAND +delete ")" ^
            "(" mpr:CAND -morphology Open Disk:%SPECK_RADIUS% -morphology Dilate Disk:%SPECK_RADIUS% mpr:CAND -compose Multiply -composite -negate mpr:CAND -compose Multiply -composite -write mpr:SPECK +delete ")" ^
            "(" mpr:LIGHT mpr:SPECK -compose Lighten -composite -write mpr:WHITEN +delete ")" ^
            "(" +clone -fill white -colorize 100 ")" mpr:WHITEN -compose Over -composite ^
            -background white -deskew %DESKEW_PCT%%% +repage ^
            -bordercolor white -border 10 -trim +repage -border %MARGIN% "%TMPFILE%"
        if errorlevel 1 goto :FILE_FAILED
        move /y "%TMPFILE%" "%OUTFILE%" >nul
        if errorlevel 1 goto :FILE_FAILED
        set "TMPFILE="
        echo   Saved "%~n1-clean.png"
        exit /b 0

    :FILE_SKIPPED

        echo   Skipped, already cleaned: "%~nx1"
        exit /b 0

    :FILE_FAILED

        echo   Failed: "%~nx1"
        set "EXITCODE=1"
        if exist "%TMPFILE%" del /F /Q "%TMPFILE%" >nul 2>&1
        set "TMPFILE="
        exit /b 0
 
