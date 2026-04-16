# Blog 博客系统

一个基于 Flask + SQLite 的轻量级个人博客系统，支持 Markdown 写作。

## 功能特性

- ✅ **文章管理**：创建、编辑、删除文章
- ✅ **Markdown 支持**：使用 marked.js 实时渲染
- ✅ **标签分类**：灵活的标签系统
- ✅ **精选文章**：支持设置精选文章
- ✅ **访问统计**：自动记录文章阅读量
- ✅ **响应式设计**：适配手机和电脑端
- ✅ **后台管理**：简洁的管理界面

## 技术栈

- **后端**：Flask (Python)
- **数据库**：SQLite (轻量级，无需安装)
- **前端**：原生 HTML/CSS/JavaScript
- **Markdown**：marked.js + highlight.js

---

## 快速开始

### 一键启动（Windows / macOS / Linux）

```bash
cd blog
# Windows
install.bat

# macOS / Linux
chmod +x install.sh && ./install.sh
```

### 手动安装

```bash
cd blog

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows:
.\venv\Scripts\Activate.pshell
# macOS / Linux:
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 启动
python app.py
```

访问 http://localhost:5000

### 访问地址

| 页面 | 地址 |
|------|------|
| 📖 博客前台 | http://localhost:5000 |
| 🏷️ 标签页面 | http://localhost:5000/tags |
| 👤 关于页面 | http://localhost:5000/about |
| ⚙️ 管理后台 | http://localhost:5000/admin |
| 🔐 登录页 | http://localhost:5000/admin/login |

### 默认账号

- 用户名：`admin`
- 密　码：`admin123`

> ⚠️ 首次运行会自动创建数据库并插入示例文章

---

## 项目结构

```
blog/
├── app.py              # Flask 主程序
├── requirements.txt   # Python 依赖
├── install.bat        # Windows 一键安装脚本
├── install.sh         # Linux/macOS 一键安装脚本
├── blog.db            # SQLite 数据库（自动生成）
├── templates/          # HTML 模板
│   ├── base.html      # 基础模板
│   ├── index.html     # 博客首页
│   ├── admin.html     # 管理后台
│   ├── login.html     # 登录页
│   ├── about.html     # 关于页面
│   └── css/
│       └── style.css  # 样式文件
└── uploads/           # 上传目录（预留）
```

---

## API 接口

### 公开接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/posts` | GET | 获取文章列表 |
| `/api/posts/<slug>` | GET | 获取单篇文章 |
| `/api/tags` | GET | 获取所有标签 |

### 管理接口（需登录）

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/admin/login` | POST | 管理员登录 |
| `/api/admin/logout` | POST | 管理员登出 |
| `/api/admin/posts` | GET | 获取所有文章 |
| `/api/admin/posts` | POST | 创建文章 |
| `/api/admin/posts/<id>` | PUT | 更新文章 |
| `/api/admin/posts/<id>` | DELETE | 删除文章 |

---

## 服务器部署

### 系统要求

- **操作系统**：Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **Python**：3.8+
- **内存**：512MB 以上
- **磁盘**：2GB 以上可用空间
- **域名**：（可选）用于绑定域名

### 安装部署

#### 第一步：安装系统依赖

```bash
# Ubuntu/Debian
apt update && apt install -y python3 python3-pip git nginx supervisor

# CentOS/RHEL
yum install -y python3 python3-pip git nginx supervisor
```

#### 第二步：克隆项目

```bash
cd /var/www
git clone https://github.com/dakerclaw/blog.git
cd blog
```

#### 第三步：安装 Python 依赖

```bash
# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 第四步：配置 Systemd 服务

```bash
cat > /etc/systemd/system/blog.service << 'EOF'
[Unit]
Description=Blog Flask Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/blog
ExecStart=/var/www/blog/venv/bin/python /var/www/blog/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

#### 第五步：启动服务

```bash
systemctl daemon-reload
systemctl start blog
systemctl enable blog
systemctl status blog
```

#### 第六步：配置 Nginx 反向代理

```bash
cat > /etc/nginx/sites-available/blog << 'EOF'
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

ln -s /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

#### 第七步：配置防火墙

```bash
ufw allow 80/tcp
ufw allow 443/tcp  # 如需 HTTPS
ufw enable
```

### 更新博客

```bash
cd /var/www/blog
systemctl stop blog
cp blog.db blog.db.backup.$(date +%Y%m%d)  # 备份数据库
git pull origin main
systemctl start blog
systemctl status blog
```

### 删除博客

```bash
# 停止服务
systemctl stop blog
systemctl disable blog

# 删除服务文件
rm /etc/systemd/system/blog.service
systemctl daemon-reload

# 删除 Nginx 配置
rm /etc/nginx/sites-enabled/blog
rm /etc/nginx/sites-available/blog
systemctl reload nginx

# 删除项目文件
rm -rf /var/www/blog
```

### 常用命令

| 操作 | 命令 |
|------|------|
| 启动服务 | `systemctl start blog` |
| 停止服务 | `systemctl stop blog` |
| 重启服务 | `systemctl restart blog` |
| 查看状态 | `systemctl status blog` |
| 查看日志 | `journalctl -u blog -f` |
| 最近日志 | `journalctl -u blog -n 100` |

### 故障排查

**服务启动失败**
```bash
systemctl status blog
journalctl -u blog -n 50
cd /var/www/blog && python3 app.py  # 手动测试
```

**端口被占用**
```bash
lsof -i :5000
```

**数据库损坏恢复**
```bash
systemctl stop blog
cp blog.db.backup blog.db
systemctl start blog
```

**Nginx 502 Bad Gateway**
```bash
systemctl restart blog
```

### 安全建议

1. **修改默认密码**：首次登录后立即修改 admin 密码
2. **配置 HTTPS**：使用 Let's Encrypt 免费证书
3. **定期备份**：备份 `blog.db` 数据库文件
4. **限制 IP**：如有固定 IP，在防火墙限制管理后台访问

```bash
# 配置 HTTPS
apt install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

### 备份与恢复

```bash
# 备份
cd /var/www/blog
tar -czf /backup/blog-$(date +%Y%m%d).tar.gz blog.db templates/

# 恢复
cd /var/www/blog
tar -xzf /backup/blog-20240101.tar.gz
systemctl restart blog
```

---

## License

MIT License
