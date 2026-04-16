#!/bin/bash

echo "============================================"
echo "  博客系统一键安装"
echo "============================================"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "错误：未找到 Python 3，请先安装"
    exit 1
fi

# 创建虚拟环境
echo "[1/3] 创建虚拟环境..."
python3 -m venv venv
if [ $? -ne 0 ]; then
    echo "错误：虚拟环境创建失败"
    exit 1
fi

# 激活虚拟环境并安装依赖
echo "[2/3] 安装依赖..."
source venv/bin/activate
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "错误：依赖安装失败"
    exit 1
fi

# 启动服务
echo "[3/3] 启动服务..."
echo ""
echo "============================================"
echo "  博客已启动！"
echo "  访问地址: http://localhost:5000"
echo "  按 Ctrl+C 停止服务"
echo "============================================"
echo ""
python app.py
