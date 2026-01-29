# Vulkan 學習專案開發紀錄

## 專案概述

這是一個跟隨 [Vulkan Tutorial](https://vulkan-tutorial.com/) 學習 Vulkan 圖形程式設計的專案，目標是在 macOS 上顯示第一個三角形。

## 環境配置

### 系統資訊
- macOS 15.7.3 (Sequoia)
- Apple Silicon (arm64)
- Xcode Command Line Tools
- VS Code

### 安裝的套件

| 套件 | 版本 | 用途 |
|------|------|------|
| Vulkan SDK | 1.4.335.1 | Vulkan API + MoltenVK |
| GLFW | 3.4 | 視窗管理與輸入處理 |
| GLM | 1.0.3 | 數學函式庫 |

### 安裝指令
```bash
# GLFW 和 GLM
brew install glfw glm

# Vulkan SDK 需從 LunarG 官網下載
# https://vulkan.lunarg.com/sdk/home#mac
```

## macOS 特有的挑戰與解決方案

### 1. macOS 沒有原生 Vulkan 支援

**問題**: Apple 只支援自家的 Metal API，不原生支援 Vulkan。

**解決方案**: 使用 **MoltenVK**，這是 Vulkan SDK 內含的轉譯層，將 Vulkan API 呼叫轉換為 Metal 呼叫。

### 2. Portability Subset 擴展

**問題**: MoltenVK 不完全支援所有 Vulkan 功能，需要啟用特殊擴展。

**解決方案**: 在程式碼中加入：
```cpp
// Instance 建立時
createInfo.flags |= VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;

// 必要的擴展
extensions.push_back(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME);
extensions.push_back("VK_KHR_get_physical_device_properties2");

// Device 擴展
const std::vector<const char*> deviceExtensions = {
    VK_KHR_SWAPCHAIN_EXTENSION_NAME,
    "VK_KHR_portability_subset"  // macOS 必須
};
```

### 3. 環境變數設定

**問題**: 執行時找不到 MoltenVK ICD (Installable Client Driver)。

**錯誤訊息**:
```
ERROR: vkCreateInstance: Found no drivers!
```

**解決方案**: 執行前必須設定環境變數：
```bash
export VK_ICD_FILENAMES=/Users/<username>/VulkanSDK/1.4.335.1/macOS/share/vulkan/icd.d/MoltenVK_icd.json
export VK_LAYER_PATH=/Users/<username>/VulkanSDK/1.4.335.1/macOS/share/vulkan/explicit_layer.d
```

**注意**: 路徑不能使用 `~`，必須使用完整絕對路徑或 `$HOME`。

### 4. Apple Silicon 路徑差異

**問題**: Homebrew 在 Intel Mac 和 Apple Silicon 上的安裝路徑不同。

| 架構 | Homebrew 路徑 |
|------|---------------|
| Intel (x86_64) | `/usr/local` |
| Apple Silicon (arm64) | `/opt/homebrew` |

**解決方案**: 編譯時使用 `/opt/homebrew/include` 和 `/opt/homebrew/lib`。

### 5. Framework 連結

**問題**: macOS 需要連結 Cocoa 和 IOKit framework。

**解決方案**: 編譯指令加入：
```bash
-framework Cocoa -framework IOKit
```

## 專案結構

```
vk-learn/
├── src/
│   ├── Application.hpp    # HelloTriangleApplication 類別定義
│   ├── Application.cpp    # 完整 Vulkan 初始化與渲染實作
│   └── main.cpp           # 程式入口點
├── shaders/
│   ├── shader.vert        # GLSL 頂點著色器原始碼
│   ├── shader.frag        # GLSL 片段著色器原始碼
│   ├── vert.spv           # 編譯後的 SPIR-V (gitignore)
│   └── frag.spv           # 編譯後的 SPIR-V (gitignore)
├── .vscode/
│   ├── c_cpp_properties.json  # IntelliSense 設定
│   ├── tasks.json             # 編譯任務
│   └── settings.json          # 終端機環境變數
├── build.sh               # 編譯腳本
├── run.sh                 # 執行腳本（含環境變數）
├── .gitignore
└── DEVLOG.md              # 本文件
```

## 實作的功能

依照 Vulkan Tutorial 章節順序：

1. **Base code** - 應用程式框架與 GLFW 視窗
2. **Instance** - Vulkan instance 建立
3. **Validation layers** - 除錯用驗證層
4. **Physical devices** - GPU 選擇
5. **Logical device** - 邏輯裝置與佇列
6. **Window surface** - 視窗表面
7. **Swap chain** - 交換鏈
8. **Image views** - 影像視圖
9. **Render pass** - 渲染通道
10. **Graphics pipeline** - 圖形管線（含著色器）
11. **Framebuffers** - 幀緩衝區
12. **Command buffers** - 命令緩衝區
13. **Rendering and presentation** - 渲染與呈現
14. **Frames in flight** - 多幀同時處理

## 編譯與執行

```bash
# 編譯（包含 shader 編譯）
./build.sh

# 執行
./run.sh
```

## 預期結果

執行後會開啟一個 800x600 的視窗，顯示一個三角形：
- 頂點位於上方（紅色）
- 左下角（綠色）
- 右下角（藍色）
- 三個頂點之間有平滑的顏色漸層

## 後續學習方向

- Vertex buffers（頂點緩衝區）
- Uniform buffers（統一緩衝區）
- Texture mapping（紋理貼圖）
- Depth buffering（深度緩衝）
- Loading models（載入模型）

## 參考資源

- [Vulkan Tutorial](https://vulkan-tutorial.com/)
- [LunarG Vulkan SDK](https://vulkan.lunarg.com/)
- [MoltenVK](https://github.com/KhronosGroup/MoltenVK)
