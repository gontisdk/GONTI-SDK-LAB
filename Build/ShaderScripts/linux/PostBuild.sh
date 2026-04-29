#!/bin/bash

source /opt/Vulkan/1.4.335.0/setup-env.sh

mkdir -p GONTI-SDK-LAB/Build/bin/Testbed/assets/shaders

echo "Compiling shaders..."

# Compile VERT shaders
echo "GONTI-SDK-LAB/Assets/shaders/Builtin.ObjectShader.vert.glsl -> GONTI-SDK-LAB/Build/bin/Testbed/assets/shaders/Builtin.ObjectShader.vert.spv"
$VULKAN_SDK/bin/glslc -fshader-stage=vert GONTI-SDK-LAB/Assets/shaders/Builtin.ObjectShader.vert.glsl -o GONTI-SDK-LAB/Build/bin/Testbed/assets/shaders/Builtin.ObjectShader.vert.spv
if [ $? -ne 0 ]; then
    echo "Error compiling VERT shader"
    exit 1
fi

# Compile FRAG shaders
echo "GONTI-SDK-LAB/Assets/shaders/Builtin.ObjectShader.frag.glsl -> GONTI-SDK-LAB/Build/bin/Testbed/assets/shaders/Builtin.ObjectShader.frag.spv"
$VULKAN_SDK/bin/glslc -fshader-stage=frag GONTI-SDK-LAB/Assets/shaders/Builtin.ObjectShader.frag.glsl -o GONTI-SDK-LAB/Build/bin/Testbed/assets/shaders/Builtin.ObjectShader.frag.spv
if [ $? -ne 0 ]; then
    echo "Error compiling FRAG shader"
    exit 1
fi

echo "Copying assets..."
cp -R "GONTI-SDK-LAB/Assets/shaders" "GONTI-SDK-LAB/Build/bin/Testbed/assets/"

echo "Done."
