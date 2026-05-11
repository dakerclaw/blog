#!/bin/bash

# =============================================
#   博客系统 - Linux 服务器一键安装脚本
#   适用于 Debian/Ubuntu 服务器
#
#   使用方式:
#   方式1 (推荐): git clone 后运行
#     git clone https://github.com/dakerclaw/blog.git
#     cd blog && bash install_server.sh
#
#   方式2: 直接从 URL 运行
#     bash <(curl -fsSL https://raw.githubusercontent.com/dakerclaw/blog/main/install_server.sh)
# =============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 安装配置
INSTALL_DIR="/var/www/blog"
SERVICE_NAME="blog"
REPO_URL="https://github.com/dakerclaw/blog.git"

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
    apt install -y python3 python3-venv python3-pip git rsync curl
elif [ "$OS" = "centos" ]; then
    yum update -y
    yum install -y python3 python3-pip git rsync curl
fi
echo -e "  ${GREEN}✓${NC} 系统依赖安装完成"

# ============================================
# 第二步：准备项目文件
# ============================================
echo ""
echo -e "${YELLOW}[2/5]${NC} 准备项目文件..."

# 检查脚本所在目录是否有完整项目文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$INSTALL_DIR"

# 检查当前目录是否有 app.py（表示在克隆的仓库中运行）
if [ -f "$SCRIPT_DIR/app.py" ]; then
    # 在克隆的仓库中运行
    WORK_DIR="$SCRIPT_DIR"
    echo "  检测到项目文件，使用当前目录: $WORK_DIR"
else
    # 需要克隆仓库
    echo "  未检测到项目文件，将从 GitHub 克隆..."

    # 检查 /var/www 是否存在
    if [ ! -d "/var/www" ]; then
        mkdir -p /var/www
    fi

    # 如果目标目录已存在，询问是否覆盖
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "  ${YELLOW}警告：$INSTALL_DIR 已存在${NC}"
        read -p "  是否删除并重新克隆? (y/N): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            rm -rf "$INSTALL_DIR"
        else
            echo "  安装取消"
            exit 0
        fi
    fi

    # 克隆仓库
    echo "  正在克隆仓库..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    WORK_DIR="$INSTALL_DIR"
    echo -e "  ${GREEN}✓${NC} 仓库克隆完成"
fi

# 检查文件完整性
echo "  检查文件完整性..."
for file in app.py requirements.txt templates/index.html; do
    if [ ! -f "$WORK_DIR/$file" ]; then
        echo -e "${RED}错误：缺少文件 $file${NC}"
        echo "  请重新克隆仓库："
        echo "    rm -rf $INSTALL_DIR"
        echo "    git clone $REPO_URL"
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
