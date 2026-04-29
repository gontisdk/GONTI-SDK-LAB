@echo off

rem IS RUNING FROM WORKSPACE DIR
if not exist "%cd%/Testbed/Build/assets/shaders/" mkdir "%cd%/Testbed/Build/assets/shaders"

echo "Compiling shaders..."

rem Compile VERT shaders
echo "Testbed/Assets/shaders/Builtin.ObjectShader.vert.glsl -> Testbed/Build/assets/shaders/Builtin.ObjectShader.vert.spv"
"%VULKAN_SDK%/bin/glslc.exe" -fshader-stage=vert "%cd%/Testbed/Assets/shaders/Builtin.ObjectShader.vert.glsl" -o "%cd%/Testbed/Build/assets/shaders/Builtin.ObjectShader.vert.spv"
if %ERRORLEVEL% NEQ 0 (echo Error: %ERRORLEVEL% && exit)

rem Compile FRAG shaders
echo "Testbed/Assets/shaders/Builtin.ObjectShader.frag.glsl -> Testbed/Build/assets/shaders/Builtin.ObjectShader.frag.spv"
"%VULKAN_SDK%/bin/glslc.exe" -fshader-stage=frag "%cd%/Testbed/Assets/shaders/Builtin.ObjectShader.frag.glsl" -o "%cd%/Testbed/Build/assets/shaders/Builtin.ObjectShader.frag.spv"
if %ERRORLEVEL% NEQ 0 (echo Error: %ERRORLEVEL% && exit)

echo "Copying assets..."
echo xcopy "Testbed/Assets/shaders" "Testbed/Build/assets/shaders" /h /i /c /k /e /r /y
xcopy "Testbed/Assets/shaders" "Testbed/Build/assets/shaders" /h /i /c /k /e /r /y

echo "Done."
