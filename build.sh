#!/bin/bash

# Vulkan SDK path
VULKAN_SDK="$HOME/VulkanSDK/1.4.335.1/macOS"

# Compile shaders if they exist
if [ -f "shaders/shader.vert" ] && [ -f "shaders/shader.frag" ]; then
    echo "Compiling shaders..."
    "$VULKAN_SDK/bin/glslc" shaders/shader.vert -o shaders/vert.spv
    "$VULKAN_SDK/bin/glslc" shaders/shader.frag -o shaders/frag.spv
fi

# Compile C++ source files
echo "Compiling source files..."
clang++ -std=c++17 -O2 \
    -I"$VULKAN_SDK/include" \
    -I/opt/homebrew/include \
    -Isrc \
    -L"$VULKAN_SDK/lib" \
    -L/opt/homebrew/lib \
    -lvulkan -lglfw \
    -framework Cocoa -framework IOKit \
    -o app \
    src/main.cpp src/Application.cpp

if [ $? -eq 0 ]; then
    echo "Build successful!"
else
    echo "Build failed!"
    exit 1
fi
