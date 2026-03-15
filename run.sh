#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

MODE="${1:-release}"
SKIP_RUN=0
if [ "$1" = "norun" ] || [ "$2" = "norun" ]; then
    SKIP_RUN=1
fi

# Vulkan SDK path (override with env: VULKAN_SDK=/path/to/.../macOS)
if [ -z "$VULKAN_SDK" ]; then
    VULKAN_SDK="$(ls -d "$HOME"/VulkanSDK/*/macOS 2>/dev/null | sort -V | tail -n 1)"
fi

if [ -z "$VULKAN_SDK" ] || [ ! -f "$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json" ]; then
    echo "VULKAN_SDK not found or invalid. Please install LunarG Vulkan SDK."
    exit 1
fi

# Set environment variables for MoltenVK
export VK_ICD_FILENAMES="$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json"
export VK_LAYER_PATH="$VULKAN_SDK/share/vulkan/explicit_layer.d"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"

echo "Building app..."
if [ "$MODE" = "debug" ]; then
    ./build.sh debug
else
    ./build.sh
fi

if [ "$SKIP_RUN" -eq 1 ]; then
    echo "Build complete (norun)."
    exit 0
fi

echo "Running app..."
./app
