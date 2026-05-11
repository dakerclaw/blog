#!/bin/bash

# =============================================
#   博客系统 - Linux 服务器一键安装脚本
#   适用于 Debian/Ubuntu 服务器
#   运行方式: bash install_server.sh
# =============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 安装目录（可修改）
INSTALL_DIR="/var/www/blog"
SERVICE_NAME="blog"

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  博客系统 - 服务器一键安装脚本${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误：请使用 root 用户运行此脚本${NC}"
    echo "请先执行: su - root"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测操作系统
echo -e "${YELLOW}[检测]${NC} 检测操作系统..."
if [ -f /etc/debian_version ]; then
    OS="debian"
    echo "  检测到: Debian/Ubuntu 系统"
elif [ -f /etc/redhat-release ]; then
    OS="centos"
    echo "  检测到: CentOS/RHEL 系统"
else
    echo -e "${RED}错误：不支持的操作系统${NC}"
    exit 1
fi

# ============================================
# 第一步：安装系统依赖
# ============================================
echo ""
echo -e "${YELLOW}[1/5]${NC} 安装系统依赖..."

if [ "$OS" = "debian" ]; then
    apt update
    apt install -y python3 python3-venv python3-pip git rsync
elif [ "$OS" = "centos" ]; then
    yum update -y
    yum install -y python3 python3-pip git rsync
fi
echo -e "  ${GREEN}✓${NC} 系统依赖安装完成"

# ============================================
# 第二步：准备项目文件
# ============================================
echo ""
echo -e "${YELLOW}[2/5]${NC} 准备项目文件..."

# 确定工作目录
if [ "$SCRIPT_DIR" = "$INSTALL_DIR" ]; then
    # 脚本在目标目录运行，使用当前目录
    WORK_DIR="$SCRIPT_DIR"
    echo "  使用当前目录文件: $WORK_DIR"
else
    # 脚本在其他位置，创建目标目录并复制文件
    WORK_DIR="$INSTALL_DIR"
    mkdir -p "$WORK_DIR"

    # 检查源文件是否完整
    if [ ! -f "$SCRIPT_DIR/app.py" ]; then
        echo -e "${RED}错误：源目录缺少 app.py，请检查仓库是否克隆完整${NC}"
        echo "  提示: 删除 $INSTALL_DIR 后重新克隆仓库"
        exit 1
    fi

    echo "  复制文件从 $SCRIPT_DIR 到 $INSTALL_DIR"
    rsync -av --exclude='venv' --exclude='*.db' --exclude='__pycache__' \
        --exclude='*.pyc' --exclude='.git' \
        "$SCRIPT_DIR/" "$INSTALL_DIR/"
fi

# 检查文件完整性
echo "  检查必需文件..."
for file in app.py requirements.txt templates/index.html; do
    if [ ! -f "$WORK_DIR/$file" ]; then
        echo -e "${RED}错误：缺少必需文件 $file${NC}"
        echo "  请确保仓库克隆完整，或重新克隆："
        echo "    rm -rf $INSTALL_DIR"
        echo "    cd /var/www"
        echo "    git clone https://github.com/dakerclaw/blog.git"
        exit 1
    fi
done
echo -e "  ${GREEN}✓${NC} 文件完整性检查通过"

# ============================================
# 第三步：安装 Python 依赖
# ============================================
echo ""
echo -e "${YELLOW}[3/5]${NC} 安装 Python 依赖..."

cd "$WORK_DIR"

# 创建虚拟环境
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# 安装依赖
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

echo -e "  ${GREEN}✓${NC} Python 依赖安装完成"

# ============================================
# 第四步：配置并启动服务
# ============================================
echo ""
echo -e "${YELLOW}[4/5]${NC} 配置并启动服务..."

# 创建 systemd 服务文件
cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=博客系统
After=network.target

[Service]
WorkingDirectory=${WORK_DIR}
ExecStart=${WORK_DIR}/venv/bin/python ${WORK_DIR}/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 重载 systemd 并启动服务
systemctl daemon-reload
systemctl start ${SERVICE_NAME}
systemctl enable ${SERVICE_NAME}

# 检查服务状态
sleep 2
if systemctl is-active --quiet ${SERVICE_NAME}; then
    echo -e "  ${GREEN}✓${NC} 服务启动成功"
else
    echo -e "  ${RED}✗${NC} 服务启动失败，请检查日志:"
    echo "       journalctl -u ${SERVICE_NAME} -n 20"
fi

# 获取服务器 IP
SERVER_IP=$(hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="你的服务器IP"
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  📖 博客前台: http://${SERVER_IP}:5000"
echo "  ⚙️  管理后台: http://${SERVER_IP}:5000/admin"
echo ""
echo "  默认账号: admin / admin123"
echo -e "  ${RED}⚠️  请及时修改默认密码！${NC}"
echo ""
echo "  常用命令:"
echo "    systemctl start ${SERVICE_NAME}    # 启动"
echo "    systemctl stop ${SERVICE_NAME}     # 停止"
echo "    systemctl restart ${SERVICE_NAME}  # 重启"
echo "    journalctl -u ${SERVICE_NAME} -f   # 查看日志"
echo ""
echo -e "${GREEN}============================================${NC}"
