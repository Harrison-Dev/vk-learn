#!/bin/bash

# Vulkan SDK path
VULKAN_SDK="$HOME/VulkanSDK/1.4.335.1/macOS"

# Set environment variables for MoltenVK
export VK_ICD_FILENAMES="$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json"
export VK_LAYER_PATH="$VULKAN_SDK/share/vulkan/explicit_layer.d"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"

# Run the app
./app
