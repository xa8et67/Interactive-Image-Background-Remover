@echo off
chcp 65001 >nul
echo ========================================
echo  启动 Interactive Image Background Remover
echo ========================================
echo.

REM 检查虚拟环境是否存在
if not exist "venv\Scripts\activate.bat" (
    echo [错误] 虚拟环境不存在，请先运行 setup_env.bat
    pause
    exit /b 1
)

REM 检查主程序是否存在
if not exist "backgroundremoval.py" (
    echo [错误] 未找到 backgroundremoval.py
    pause
    exit /b 1
)

REM 激活虚拟环境并运行应用
echo [启动] 激活虚拟环境...
call venv\Scripts\activate.bat

echo [启动] 运行应用...
echo.
python backgroundremoval.py

REM 如果应用异常退出，暂停以查看错误信息
if %errorlevel% neq 0 (
    echo.
    echo [错误] 应用异常退出，错误代码: %errorlevel%
    pause
)