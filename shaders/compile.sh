#!/bin/bash

cd "$(dirname "$0")"

echo "Compiling shaders..."

dxc -spirv -T vs_6_0 -E main shader.vert.hlsl -Fo vert.spv
if [ $? -ne 0 ]; then
    echo "Failed to compile vertex shader!"
    exit 1
fi

dxc -spirv -T ps_6_0 -E main shader.frag.hlsl -Fo frag.spv
if [ $? -ne 0 ]; then
    echo "Failed to compile fragment shader!"
    exit 1
fi

echo "Done!"