#pragma once

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

#include <stdexcept>
#include <cstdlib>

const uint32_t WIDTH = 800;
const uint32_t HEIGHT = 600;

class HelloTriangleApplication
{
public:
    void run();

private:
    GLFWwindow *window;

    void initWindow();
    void initVulkan();
    void mainLoop();
    void cleanup();
};
