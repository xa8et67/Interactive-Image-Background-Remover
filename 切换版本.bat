@echo off
chcp 65001 >nul

echo ========================================
echo  onnxruntime 版本切换工具
echo ========================================
echo.

if not exist "venv\Scripts\activate.bat" (
    echo [错误] 虚拟环境不存在
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

echo 当前安装的 onnxruntime 版本:
pip list | findstr onnxruntime || echo 未安装
echo.

echo [1] 选择 pip 镜像源:
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

:select_mirror
set /p mirror_choice="请输入选项 1-5，默认为2: "

if "%mirror_choice%"=="" set mirror_choice=2

if "%mirror_choice%"=="1" (
    set pip_source=https://pypi.org/simple
    echo 已选择：官方源
) else if "%mirror_choice%"=="2" (
    set pip_source=https://pypi.tuna.tsinghua.edu.cn/simple
    echo 已选择：清华源
) else if "%mirror_choice%"=="3" (
    set pip_source=https://mirrors.aliyun.com/pypi/simple
    echo 已选择：阿里云源
) else if "%mirror_choice%"=="4" (
    set pip_source=https://pypi.douban.com/simple
    echo 已选择：豆瓣源
) else if "%mirror_choice%"=="5" (
    set pip_source=https://pypi.mirrors.ustc.edu.cn/simple
    echo 已选择：中科大源
) else (
    echo 错误：无效选择，使用默认清华源
    set pip_source=https://pypi.tuna.tsinghua.edu.cn/simple
    set mirror_choice=2
)

echo.
echo [2] 请选择 onnxruntime 版本:
echo.
echo 1. CPU 版本 (onnxruntime)
echo 2. GPU 版本 (onnxruntime-gpu)
echo 3. Intel GPU (onnxruntime-openvino)
echo 4. DirectML (onnxruntime-directml)
echo 0. 退出
echo.

:retry
set /p choice="选择 (0-4): "

if "%choice%"=="1" set package=onnxruntime && goto install
if "%choice%"=="2" set package=onnxruntime-gpu && goto install
if "%choice%"=="3" set package=onnxruntime-openvino && goto install
if "%choice%"=="4" set package=onnxruntime-directml && goto install
if "%choice%"=="0" goto exit
echo 无效选择
goto retry

:install
echo.
echo 准备安装: %package%
set /p confirm="继续? (y/n): "
if /i not "%confirm%"=="y" goto exit

echo.
echo 卸载旧版本...
pip uninstall onnxruntime onnxruntime-gpu onnxruntime-openvino onnxruntime-directml -y >nul 2>&1

echo 清理缓存...
pip cache purge >nul 2>&1

echo 安装 %package%...
echo 使用镜像源: %pip_source%
pip install -i %pip_source% %package%

if errorlevel 1 (
    echo 安装失败!
    pause
    exit /b 1
)

echo.
echo 安装成功!
pip list | findstr onnxruntime
echo.
pause
exit /b 0

:exit
echo 退出
pause