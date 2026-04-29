@echo off
setlocal enabledelayedexpansion

REM --- Configuration ---
set SDK_ROOT=..\GONTI-SDK\GONTI\GONTI-ENGINE
set SDK_ROOT_BIN=..\GONTI-SDK\Build\bin\linux\GONTI\GONTI-ENGINE
set MAK_SRC_DIR=Build\Scripts\linux
set OUT_TESTBED=Build\bin\Testbed
set OUT_TESTS=Build\bin\Tests
set MAK_FNAME_S=Makefile
set MAK_FNAME_E=linux.mak
set LIB_DIR=Lib\GONTI\GONTI-ENGINE
set INCLUDE_DEST=Include\GONTI\GONTI-ENGINE

REM "Tablica"
set MODULES=GONTI.CORE GONTI.RENDER GONTI.RENDER.VK GONTI.RUNTIME

REM --- Pre-run Validation ---
if not exist "%SDK_ROOT_BIN%" (
    echo Error: SDK Binary directory (%SDK_ROOT_BIN%) missing. Aborting.
    exit /b 1
)

REM --- Execution ---

call :collect_headers
call :copy_engine_libs "%LIB_DIR%"

echo Building GONTI-SDK-LAB components...

make -f "%MAK_SRC_DIR%\%MAK_FNAME_S%.Testbed.%MAK_FNAME_E%" all
if errorlevel 1 exit /b 1

make -f "%MAK_SRC_DIR%\%MAK_FNAME_S%.Tests.%MAK_FNAME_E%" all
if errorlevel 1 exit /b 1

echo ---------------------------------------
echo All assemblies built successfully.

REM --- Launching ---
if exist "%OUT_TESTBED%" (
    echo Launching Testbed...
    pushd "%OUT_TESTBED%"
    Testbed.exe
    popd
) else (
    echo [ERROR] Testbed target directory missing: %OUT_TESTBED%
)

exit /b 0

REM ================================
REM Functions
REM ================================

:prepare_dir
set DIR=%~1
if not exist "%DIR%" (
    mkdir "%DIR%"
)
exit /b 0

:copy_engine_libs
set DEST=%~1
call :prepare_dir "%DEST%"

echo Copying engine libraries to %DEST%...

for %%M in (%MODULES%) do (
    set LIB_PATH=%SDK_ROOT_BIN%\%%M.dll
    if exist "!LIB_PATH!" (
        copy /Y "!LIB_PATH!" "%DEST%\" >nul
    ) else (
        echo [WARN] Library !LIB_PATH! not found!
    )
)
exit /b 0

:collect_headers
echo Collecting headers into %INCLUDE_DEST%...
call :prepare_dir "%INCLUDE_DEST%"

for %%M in (%MODULES%) do (
    set SRC_PATH=%SDK_ROOT%\%%M\Source
    set DEST_PATH=%INCLUDE_DEST%\%%M\Source

    if exist "!SRC_PATH!" (
        echo   -^> Processing module: %%M
        call :prepare_dir "!DEST_PATH!"

        for /r "!SRC_PATH!" %%F in (*.h *.inl) do (
            set FILE=%%F
            set REL=!FILE:%SRC_PATH%\=!
            set TARGET=!DEST_PATH!\!REL!

            call :make_parent_dir "!TARGET!"
            copy /Y "%%F" "!TARGET!" >nul
        )
    ) else (
        echo   [WARN] Missing source headers at !SRC_PATH!
    )
)

exit /b 0

:make_parent_dir
set FILEPATH=%~1
for %%D in ("%FILEPATH%") do (
    if not exist "%%~dpD" mkdir "%%~dpD"
)
exit /b 0