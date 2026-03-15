param(
    [Parameter(Position = 0)]
    [string]$Arg1,
    [Parameter(Position = 1)]
    [string]$Arg2
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$config = "release"
$runApp = $true

foreach ($arg in @($Arg1, $Arg2)) {
    if (-not $arg) { continue }
    if ($arg.ToLowerInvariant() -eq "debug") { $config = "debug" }
    if ($arg.ToLowerInvariant() -eq "norun") { $runApp = $false }
}

if (-not $env:VULKAN_SDK) {
    $sdkDir = Get-ChildItem "C:\VulkanSDK" -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        Select-Object -First 1
    if ($sdkDir) {
        $env:VULKAN_SDK = $sdkDir.FullName
    }
}

if (-not $env:VULKAN_SDK) {
    throw "VULKAN_SDK is not set and no SDK found under C:\VulkanSDK"
}

$dxc = Join-Path $env:VULKAN_SDK "Bin\dxc.exe"
if (-not (Test-Path $dxc)) {
    throw "dxc.exe not found at $dxc"
}

$clang = "C:\Program Files\LLVM\bin\clang++.exe"
if (-not (Test-Path $clang)) {
    $clangCmd = Get-Command clang++.exe -ErrorAction SilentlyContinue
    if (-not $clangCmd) {
        throw "clang++ not found. Install LLVM clang and ensure it is in PATH."
    }
    $clang = $clangCmd.Source
}

$vcpkgRoot = "C:\vcpkg"
$glfwInclude = Join-Path $vcpkgRoot "installed\x64-windows\include\GLFW\glfw3.h"
$glfwLibDir = Join-Path $vcpkgRoot "installed\x64-windows\lib"
$glfwLib = Join-Path $glfwLibDir "glfw3dll.lib"
$glfwDll = Join-Path $vcpkgRoot "installed\x64-windows\bin\glfw3.dll"

if (-not (Test-Path $glfwInclude) -or -not (Test-Path $glfwLib)) {
    throw "GLFW not found in vcpkg. Run: C:\vcpkg\vcpkg.exe install glfw3:x64-windows"
}

Write-Host "[STEP] Compile shaders..."
Push-Location (Join-Path $root "shaders")
& $dxc -spirv -T vs_6_0 -E main shader.vert.hlsl -Fo vert.spv
& $dxc -spirv -T ps_6_0 -E main shader.frag.hlsl -Fo frag.spv
Pop-Location

Write-Host "[STEP] Build app.exe with clang++..."
$cxxFlags = @("-std=c++17")
if ($config -eq "debug") {
    $cxxFlags += @("-g", "-O0", "-D_DEBUG")
} else {
    $cxxFlags += @("-O2", "-DNDEBUG")
}

$srcDir = Join-Path $root "src"
$mainCpp = Join-Path $srcDir "main.cpp"
$appCpp = Join-Path $srcDir "Application.cpp"
$outExe = Join-Path $root "app.exe"

$clangArgs = @()
$clangArgs += $cxxFlags
$clangArgs += @(
    "-I$($env:VULKAN_SDK)\Include",
    "-I$($vcpkgRoot)\installed\x64-windows\include",
    "-I$srcDir",
    $mainCpp,
    $appCpp,
    "-L$($env:VULKAN_SDK)\Lib",
    "-L$glfwLibDir",
    "-lvulkan-1",
    "-lglfw3dll",
    "-luser32",
    "-lgdi32",
    "-lshell32",
    "-o",
    $outExe
)

& $clang @clangArgs

if (Test-Path $glfwDll) {
    Copy-Item -Force $glfwDll (Join-Path $root "glfw3.dll")
}

if (-not $runApp) {
    Write-Host "[OK] Build complete. Skipped launch (norun)."
    exit 0
}

Write-Host "[STEP] Run app.exe..."
& $outExe
exit $LASTEXITCODE
