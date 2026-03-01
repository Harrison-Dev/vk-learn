#!/bin/bash

# Vulkan SDK path (override with env: VULKAN_SDK=/path/to/.../macOS)
if [ -z "$VULKAN_SDK" ]; then
    VULKAN_SDK="$(ls -d "$HOME"/VulkanSDK/*/macOS 2>/dev/null | sort -V | tail -n 1)"
fi

if [ -z "$VULKAN_SDK" ] || [ ! -d "$VULKAN_SDK" ]; then
    echo "VULKAN_SDK not found. Please install LunarG Vulkan SDK."
    exit 1
fi

# Compile shaders
if [ -x "shaders/compile.sh" ]; then
    ./shaders/compile.sh
else
    echo "shaders/compile.sh not found or not executable"
    exit 1
fi

# Check for debug flag
if [ "$1" = "debug" ]; then
    echo "Compiling in DEBUG mode..."
    CFLAGS="-std=c++17 -g -O0"
else
    echo "Compiling in RELEASE mode..."
    CFLAGS="-std=c++17 -O2 -DNDEBUG"
fi

# Compile C++ source files
echo "Compiling source files..."
clang++ $CFLAGS \
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
