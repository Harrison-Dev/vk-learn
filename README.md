# vk-learn

跟著 [Vulkan Tutorial](https://vulkan-tutorial.com/) 學習 Vulkan 的練習專案，在 macOS 上透過 MoltenVK 運行，使用 HLSL 作為 shader 語言。

## 環境

- **主要開發平台：** macOS (Apple Silicon)
- **Vulkan 實作：** MoltenVK（Vulkan-to-Metal 轉譯層）
- **Vulkan SDK：** LunarG Vulkan SDK（建議最新版本）
- **Shader 語言：** HLSL（透過 DXC 編譯為 SPIR-V）
- **編譯器：** clang++ (C++17)
- **視窗管理：** GLFW 3.4
- **數學庫：** GLM

## macOS / MoltenVK 特化處理

由於 macOS 不原生支援 Vulkan，需要透過 MoltenVK 轉譯至 Metal，因此有以下額外處理：

- 若系統支援 `VK_KHR_PORTABILITY_ENUMERATION`，程式會自動啟用 portability extension 與對應 flag
- 執行時需設定 `VK_ICD_FILENAMES`、`VK_LAYER_PATH`、`DYLD_LIBRARY_PATH` 等環境變數（見 `run.sh`）
- Swap extent 處理 Retina 螢幕的 DPI 縮放

## 使用 HLSL 而非 GLSL

本專案使用 HLSL 撰寫 shader，透過 DXC (DirectX Shader Compiler) 搭配 `-spirv` flag 編譯為 SPIR-V：

```bash
# 編譯 vertex shader
dxc -spirv -T vs_6_0 -E main shader.vert.hlsl -Fo vert.spv

# 編譯 fragment shader
dxc -spirv -T ps_6_0 -E main shader.frag.hlsl -Fo frag.spv
```

或直接執行：

```bash
cd shaders && ./compile.sh
```

## 建置與執行（跨平台一致）

兩個平台都用 clang++，而且都提供同名入口：

- macOS: `./run.sh`
- Windows: `.\run.bat`

兩個入口都會做同一件事：

1. 編譯 HLSL shader（DXC -> SPIR-V）
2. 編譯 C++ 程式（clang++）
3. 啟動程式

支援參數（兩平台一致）：

- `debug`: Debug build
- `norun`: 只建置不啟動

範例：

```bash
./run.sh debug
./run.sh norun
```

```powershell
.\run.bat debug
.\run.bat norun
```

### macOS 依賴

- [LunarG Vulkan SDK](https://vulkan.lunarg.com/)（MoltenVK）
- [GLFW](https://www.glfw.org/)：`brew install glfw`
- [GLM](https://github.com/g-truc/glm)：`brew install glm`
- clang++（Xcode Command Line Tools）
- dxc（隨 Vulkan SDK）

### Windows 依賴

- [LunarG Vulkan SDK for Windows](https://vulkan.lunarg.com/)
- LLVM clang++（建議安裝 LLVM）
- vcpkg 安裝 GLFW：`C:\vcpkg\vcpkg.exe install glfw3:x64-windows`
- dxc（隨 Vulkan SDK）

Windows 的 `run.bat` 會呼叫 `run.ps1` 執行主要流程，並使用 `-ExecutionPolicy Bypass`，因此不受你本機 PowerShell profile 的執行政策影響。請注意，`-ExecutionPolicy Bypass` 可能違反部分組織或系統的安全政策，如有疑慮請先確認你的環境規範。

若你的環境不允許使用 `-ExecutionPolicy Bypass`，可以改用下列方式，在目前 PowerShell 工作階段暫時放寬執行原則後直接執行 `run.ps1`：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\run.ps1
```

### 手動指定 SDK（可選）

macOS：

```bash
export VULKAN_SDK="$HOME/VulkanSDK/<version>/macOS"
```

Windows：

```powershell
$env:VULKAN_SDK="C:\VulkanSDK\<version>"
```

## 專案結構

```
├── src/
│   ├── main.cpp              # 程式進入點
│   ├── Application.hpp       # Application 類別宣告
│   └── Application.cpp       # Vulkan 初始化與主要邏輯
├── shaders/
│   ├── shader.vert.hlsl      # Vertex shader (HLSL)
│   ├── shader.frag.hlsl      # Fragment shader (HLSL)
│   └── compile.sh            # Shader 編譯腳本
├── build.sh                  # 建置腳本
├── run.sh                    # macOS 一鍵建置+執行入口
├── run.bat                   # Windows 一鍵建置+執行入口
├── run.ps1                   # Windows 主要執行邏輯（clang-only）
└── DEVLOG.md                 # 開發筆記
```

## 目前進度

- [x] Instance 建立
- [x] Validation layers & debug messenger
- [x] Window surface
- [x] Physical device 選擇
- [x] Logical device & queues
- [x] Swap chain
- [x] Image views
- [x] Render pass
- [ ] Graphics pipeline
- [ ] Framebuffers
- [ ] Command buffers
- [ ] 繪製三角形

## License

MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
