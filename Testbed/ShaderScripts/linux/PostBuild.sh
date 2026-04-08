#!/bin/bash

source /opt/Vulkan/1.4.335.0/setup-env.sh

mkdir -p Testbed/Build/assets
mkdir -p Testbed/Build/assets/shaders

echo "Compiling shaders..."

# Compile VERT shaders
echo "Testbed/Assets/shaders/Builtin.ObjectShader.vert.glsl -> Testbed/Build/assets/shaders/Builtin.ObjectShader.vert.spv"
$VULKAN_SDK/bin/glslc -fshader-stage=vert Testbed/Assets/shaders/Builtin.ObjectShader.vert.glsl -o Testbed/Build/assets/shaders/Builtin.ObjectShader.vert.spv
if [ $? -ne 0 ]; then
    echo "Error compiling VERT shader"
    exit 1
fi

# Compile FRAG shaders
echo "Testbed/Assets/shaders/Builtin.ObjectShader.frag.glsl -> Testbed/Build/assets/shaders/Builtin.ObjectShader.frag.spv"
$VULKAN_SDK/bin/glslc -fshader-stage=frag Testbed/Assets/shaders/Builtin.ObjectShader.frag.glsl -o Testbed/Build/assets/shaders/Builtin.ObjectShader.frag.spv
if [ $? -ne 0 ]; then
    echo "Error compiling FRAG shader"
    exit 1
fi

echo "Copying assets..."
cp -R "Testbed/Assets/shaders" "Testbed/Build/assets/"

echo "Done."
