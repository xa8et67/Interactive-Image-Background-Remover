@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  交互式图像背景去除工具 = 环境初始化脚本
echo ========================================
echo.

REM 检查 Python 是否安装
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未检测到 Python，请先安装 Python 3.x
    echo 下载地址：https://www.python.org/downloads/
    pause
    exit /b 1
)

echo 第1步共6步：检测到 Python
python --version
echo.

REM 检查是否存在虚拟环境
set "recreate_venv=0"
if exist "venv" (
    echo 警告：检测到已存在的虚拟环境
    echo.
    echo 请选择操作：
    echo.
    echo   1. 使用现有虚拟环境
    echo      只安装或更新依赖包
    echo.
    echo   2. 重新创建虚拟环境
    echo      删除旧环境并创建全新环境
    echo.
    echo   3. 退出脚本
    echo.
    
    :ask_venv_option
    set /p "venv_choice=请输入选项 1-3，默认为1："
    
    if not defined venv_choice set venv_choice=1
    if "!venv_choice!"=="" set venv_choice=1
    
    if "!venv_choice!"=="1" (
        echo 已选择：使用现有虚拟环境
        set recreate_venv=0
    ) else if "!venv_choice!"=="2" (
        echo 已选择：重新创建虚拟环境
        set recreate_venv=1
        
        REM 二次确认
        echo.
        set /p "confirm_del=确定要删除现有虚拟环境吗？输入 y 确认，其他键取消："
        if /i not "!confirm_del!"=="y" (
            echo 已取消删除操作，返回选项菜单...
            echo.
            goto ask_venv_option
        )
    ) else if "!venv_choice!"=="3" (
        echo 用户取消操作
        pause
        exit /b 0
    ) else (
        echo 错误：无效选择，请重新输入
        echo.
        goto ask_venv_option
    )
    echo.
) else (
    echo 信息：未找到现有虚拟环境，将创建新环境
    set recreate_venv=1
)

REM 删除并重新创建虚拟环境（如果需要）
if !recreate_venv! equ 1 (
    echo 第2步共6步：设置虚拟环境...
    
    if exist "venv" (
        echo 正在删除现有虚拟环境...
        rmdir /s /q venv >nul 2>nul
        
        REM 检查是否删除成功
        timeout /t 1 /nobreak >nul
        if exist "venv" (
            echo 错误：无法删除虚拟环境，可能是文件正在被使用
            echo 请关闭所有使用此虚拟环境的程序后重试
            pause
            exit /b 1
        )
        echo 完成：虚拟环境已删除
    )
    
    echo 正在创建新的 Python 虚拟环境...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo 错误：创建虚拟环境失败
        pause
        exit /b 1
    )
    echo 完成：虚拟环境创建成功
    echo.
) else (
    echo 第2步共6步：使用现有虚拟环境
    echo.
)

REM 激活虚拟环境并升级 pip
echo 第3步共6步：激活虚拟环境并升级 pip...
call "venv\Scripts\activate.bat"
if %errorlevel% neq 0 (
    echo 错误：无法激活虚拟环境
    pause
    exit /b 1
)

REM 检查虚拟环境是否激活成功
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：虚拟环境激活失败
    pause
    exit /b 1
)

echo 正在升级 pip...
python -m pip install --upgrade pip
if %errorlevel% neq 0 (
    echo 警告：pip 升级失败，继续安装...
)
echo.

echo 第4步共6步：选择 pip 镜像源
echo.
echo   1. 官方源
echo      https://pypi.org/simple
echo      最稳定，速度可能较慢
echo.
echo   2. 清华源
echo      https://pypi.tuna.tsinghua.edu.cn/simple
echo      国内推荐
echo.
echo   3. 阿里云源
echo      https://mirrors.aliyun.com/pypi/simple
echo      国内推荐
echo.
echo   4. 豆瓣源
echo      https://pypi.douban.com/simple
echo      国内推荐
echo.
echo   5. 中科大源
echo      https://pypi.mirrors.ustc.edu.cn/simple
echo      国内推荐
echo.
set /p "mirror_choice=请输入选项 1-5，默认为2："

if not defined mirror_choice set mirror_choice=2
if "!mirror_choice!"=="" set mirror_choice=2

if "!mirror_choice!"=="1" (
    set pip_index=https://pypi.org/simple
    echo 已选择：官方源
) else if "!mirror_choice!"=="2" (
    set pip_index=https://pypi.tuna.tsinghua.edu.cn/simple
    echo 已选择：清华源
) else if "!mirror_choice!"=="3" (
    set pip_index=https://mirrors.aliyun.com/pypi/simple
    echo 已选择：阿里云源
) else if "!mirror_choice!"=="4" (
    set pip_index=https://pypi.douban.com/simple
    echo 已选择：豆瓣源
) else if "!mirror_choice!"=="5" (
    set pip_index=https://pypi.mirrors.ustc.edu.cn/simple
    echo 已选择：中科大源
) else (
    echo 错误：无效选择，使用默认清华源
    set pip_index=https://pypi.tuna.tsinghua.edu.cn/simple
    set mirror_choice=2
)
echo.

REM 选择 onnxruntime 版本
echo 第5步共6步：选择 onnxruntime 版本
echo.
echo   1. onnxruntime
echo      CPU 版本，兼容所有硬件
echo.
echo   2. onnxruntime-gpu
echo      NVIDIA 显卡，需要 CUDA
echo.
echo   3. onnxruntime-openvino
echo      Intel 显卡
echo.
echo   4. onnxruntime-directml
echo      Windows 通用，支持 NVIDIA AMD Intel
echo.
set /p "onnx_choice=请输入选项 1-4，默认为1："

if not defined onnx_choice set onnx_choice=1
if "!onnx_choice!"=="" set onnx_choice=1

if "!onnx_choice!"=="1" (
    set onnx_package=onnxruntime
    echo 已选择：CPU 版本
) else if "!onnx_choice!"=="2" (
    set onnx_package=onnxruntime-gpu
    echo 已选择：NVIDIA GPU 版本
) else if "!onnx_choice!"=="3" (
    set onnx_package=onnxruntime-openvino
    echo 已选择：Intel GPU 版本
) else if "!onnx_choice!"=="4" (
    set onnx_package=onnxruntime-directml
    echo 已选择：Windows DirectML 版本
) else (
    echo 错误：无效选择，使用默认 CPU 版本
    set onnx_package=onnxruntime
    set onnx_choice=1
)
echo.

REM 安装依赖
echo 第6步共6步：安装项目依赖
echo 镜像源：!pip_index!
echo.

echo 将安装以下软件包：
echo.
echo   Pillow
echo   scipy
echo   numpy
echo   opencv-python
echo   pyqt6
echo   requests
echo   pymatting
echo   !onnx_package!
echo.
set /p "confirm_install=确定要安装这些依赖吗？输入 Y 确认，N 取消："

if not defined confirm_install set confirm_install=Y
if /i "!confirm_install!"=="n" (
    echo 用户取消安装
    pause
    exit /b 0
)

REM 安装基础依赖
echo 正在安装基础依赖...
pip install -i !pip_index! Pillow scipy numpy opencv-python pyqt6 requests pymatting

if !errorlevel! neq 0 (
    echo 警告：部分基础依赖安装失败，请检查网络连接
)

REM 安装选择的 onnxruntime 版本
echo.
echo 正在安装 !onnx_package!...
pip install -i !pip_index! !onnx_package!

if !errorlevel! neq 0 (
    echo 警告：!onnx_package! 安装失败，请检查网络连接或尝试其他镜像源
    echo 您可以稍后手动安装：pip install !onnx_package!
)

REM 验证安装
echo.
echo 正在验证安装...
python -c "import PIL, numpy, cv2, PyQt6, requests, pymatting" >nul 2>&1
if !errorlevel! equ 0 (
    echo 成功：基础依赖验证成功
) else (
    echo 失败：基础依赖验证失败，某些模块可能未正确安装
)

python -c "import onnxruntime" >nul 2>&1
if !errorlevel! equ 0 (
    echo 成功：onnxruntime 验证成功
) else (
    echo 失败：onnxruntime 验证失败，可能需要重新安装
)

echo.

echo 完成：环境初始化完成！
echo.
echo ========================================
echo  环境初始化完成！
echo ========================================
echo.
echo 启动命令：
echo   venv\Scripts\activate.bat
echo   python backgroundremoval.py
echo.
echo 注意：请确保每次使用前激活虚拟环境
echo.

pause