#!/bin/bash

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

# Run the app
./app
