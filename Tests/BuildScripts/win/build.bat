@echo off
SetLocal EnableDelayedExpansion

set workspace=%cd%

set cFilenames=
for /R "%cd%/Tests/Source" %%f in (*.c) do (
    set "cFilenames=!cFilenames! "%%f""
)

echo(
echo ===============================================
echo === START LIST OF: Files passed to compiler ===
echo ===============================================
echo(
echo !cFilenames!
echo(
echo =============================================
echo === END LIST OF: Files passed to compiler ===
echo =============================================
echo(
echo(

if not exist "%cd%/Tests/Build" (
    mkdir "%cd%/Tests/Build"
)

cd %cd%/Tests/Build


set workspaceFoldersInclude=%workspace%\GONTI-SDK
set GONTI-CORE-Libs-Dir=%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.CORE
set GONTI-RENDER-Libs-Dir=%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.RENDER
set GONTI-RENDER-VK-Libs-Dir=%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.RENDER.VK
set GONTI-RUNTIME-Libs-Dir=%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.RUNTIME

set assembly=tests
set compilerFlags=-g -Wno-missing-braces
rem -Wall -Werror
set includeFlags=-I../../Source -I"%workspaceFoldersInclude%"
set linkerFlags=-L"%GONTI-CORE-Libs-Dir%" -L"%GONTI-RENDER-Libs-Dir%" -L"%GONTI-RENDER-VK-Libs-Dir%" -L"%GONTI-RUNTIME-Libs-Dir%" -luser32 -lGONTI.CORE -lGONTI.RENDER -lGONTI.RENDER.VK -lGONTI.RUNTIME -L"%vcpkgLibDir%" -lvulkan-1
set defines=-D_DEBUG -DKIMPORT


copy "%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.CORE\GONTI.CORE.dll" ".\GONTI.CORE.dll" /Y > nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy GONTI.CORE.dll!
)

copy "%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.RENDER.VK\GONTI.RENDER.VK.dll" ".\GONTI.RENDER.VK.dll" /Y > nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy GONTI.RENDER.VK.dll!
)

copy "%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.RENDER\GONTI.RENDER.dll" ".\GONTI.RENDER.dll" /Y > nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy GONTI.RENDER.dll!
)

copy "%workspace%\GONTI-SDK\Build\bin\win32\GONTI\GONTI-ENGINE\GONTI.RUNTIME\GONTI.RUNTIME.dll" ".\GONTI.RUNTIME.dll" /Y > nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy GONTI.RUNTIME.dll!
)

clang !cFilenames! %compilerFlags% -o %assembly%.exe %defines% %includeFlags% %linkerFlags%

call "%~dp0run.bat" %assembly%