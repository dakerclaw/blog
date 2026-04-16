@echo off
chcp 65001 >nul
echo ============================================
echo   博客系统一键安装
echo ============================================
echo.

:: 创建虚拟环境
echo [1/3] 创建虚拟环境...
python -m venv venv
if errorlevel 1 (
    echo 错误：虚拟环境创建失败
    echo 请确保已安装 Python 3.8+
    pause
    exit /b 1
)

:: 激活虚拟环境并安装依赖
echo [2/3] 安装依赖...
call venv\Scripts\activate.bat
pip install -r requirements.txt
if errorlevel 1 (
    echo 错误：依赖安装失败
    pause
    exit /b 1
)

:: 启动服务
echo [3/3] 启动服务...
echo.
echo ============================================
echo   博客已启动！
echo   访问地址: http://localhost:5000
echo   按 Ctrl+C 停止服务
echo ============================================
echo.
python app.py
