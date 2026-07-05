@echo off
setlocal enabledelayedexpansion

rem --- Configuration ---
set "SDK_ROOT=..\GONTI-SDK\GONTI-SDK"
set "SDK_ROOT_BIN=..\GONTI-SDK\Build\bin\win32\GONTI-SDK"
set "MAK_SRC_DIR=Build\Scripts\win32"
set "OUT_TESTBED=Build\bin\Testbed"
set "OUT_TESTS=Build\bin\Tests"
set "MAK_FNAME_S=Makefile"
set "MAK_FNAME_E=win32.mak"
set "LIB_DIR=Lib\GONTI-SDK"
set "INCLUDE_DEST=.\Include\GONTI-SDK"

rem On win32 a module produces both an import library (.lib, needed at link time)
rem and a runtime DLL (.dll, needed next to the executable) - both are copied together.
set "LIB_EXTENSIONS=.lib .dll"

rem Modules that produce a compiled library - used for lib/dll copying.
rem Format: "ModuleName|RelativeGroupPath" (path relative to SDK_ROOT / SDK_ROOT_BIN)
set "LIB_MODULES=GONTI.CORE|GONTI-CORE GONTI.CONTAINERS|GONTI-CORE GONTI.MATH|GONTI-CORE GONTI.STRING|GONTI-CORE GONTI.FILESYSTEM|GONTI-CORE GONTI.RENDER|GONTI-RENDER GONTI.RENDER.CORE.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.DEBUGGER.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.SHADERS.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.UTILITIES.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RUNTIME|GONTI-RUNTIME"

rem All modules that expose headers, including header-only ones (GONTI.RENDER.COMMON,
rem GONTI.RENDER.COMMON.VK) which have no compiled library but must still be collected.
rem Format: "ModuleName|RelativeGroupPath"
set "HEADER_MODULES=GONTI.CORE|GONTI-CORE GONTI.CONTAINERS|GONTI-CORE GONTI.MATH|GONTI-CORE GONTI.STRING|GONTI-CORE GONTI.FILESYSTEM|GONTI-CORE GONTI.RENDER|GONTI-RENDER GONTI.RENDER.COMMON|GONTI-RENDER GONTI.RENDER.COMMON.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.CORE.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.DEBUGGER.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.SHADERS.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.UTILITIES.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RENDER.VK|GONTI-RENDER\GONTI-RENDER-VK GONTI.RUNTIME|GONTI-RUNTIME"

rem --- Pre-run Validation ---
if not exist "%SDK_ROOT_BIN%" (
    echo Error: SDK Binary directory ^(%SDK_ROOT_BIN%^) missing. Aborting.
    exit /b 1
)

rem --- Execution ---

rem 1. Prepare Environment
call :collect_headers
call :copy_engine_libs "%LIB_DIR%"

rem 2. Build Process
echo Building GONTI-SDK-LAB components...

make -f "%MAK_SRC_DIR%\%MAK_FNAME_S%.Testbed.%MAK_FNAME_E%" all
if %ERRORLEVEL% NEQ 0 (echo ERROR:%ERRORLEVEL% && goto errEnd)

make -f "%MAK_SRC_DIR%\%MAK_FNAME_S%.Tests.%MAK_FNAME_E%" all
if %ERRORLEVEL% NEQ 0 (echo ERROR:%ERRORLEVEL% && goto errEnd)

echo ---------------------------------------
echo All assemblies built successfully.

rem --- Launching ---
if exist "%OUT_TESTBED%" (
    echo Launching Testbed...
    pushd "%OUT_TESTBED%"
    call Testbed.exe
    popd
) else (
    echo [ERROR] Testbed target directory missing: %OUT_TESTBED%
)

goto end

rem --- Functions ---

:copy_engine_libs
set "dest=%~1"
if not exist "%dest%" mkdir "%dest%"
echo Copying engine libraries to %dest%...
for %%M in (%LIB_MODULES%) do (
    for /f "tokens=1,2 delims=|" %%A in ("%%M") do (
        set "module=%%A"
        set "group=%%B"
        for %%E in (%LIB_EXTENSIONS%) do (
            set "lib_path=%SDK_ROOT_BIN%\!group!\!module!%%E"
            if exist "!lib_path!" (
                copy /y "!lib_path!" "%dest%\" >NUL
            ) else (
                echo [WARN] Library !lib_path! not found!
            )
        )
    )
)
exit /b 0

:collect_headers
echo Collecting headers into %INCLUDE_DEST%...
if not exist "%INCLUDE_DEST%" mkdir "%INCLUDE_DEST%"
for %%M in (%HEADER_MODULES%) do (
    for /f "tokens=1,2 delims=|" %%A in ("%%M") do (
        set "module=%%A"
        set "group=%%B"
        set "src_path=%SDK_ROOT%\!group!\!module!\Source"
        set "dest_path=%INCLUDE_DEST%\!group!\!module!\Source"
        if exist "!src_path!" (
            echo   -^> Processing module: !module!
            if not exist "!dest_path!" mkdir "!dest_path!"
            xcopy "!src_path!\*.h" "!dest_path!\" /S /I /Y /Q >NUL 2>NUL
            xcopy "!src_path!\*.inl" "!dest_path!\" /S /I /Y /Q >NUL 2>NUL
        ) else (
            echo   [WARN] Missing source headers at !src_path!
        )
    )
)
exit /b 0

:errEnd
pause
exit /b 1

:end
endlocal