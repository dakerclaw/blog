# Blog 博客系统

一个基于 Flask + SQLite 的轻量级个人博客系统，支持 Markdown 写作。

## 功能特性

- ✅ 文章管理：创建、编辑、删除文章
- ✅ Markdown 支持：使用 marked.js 实时渲染
- ✅ 标签分类：灵活的标签系统
- ✅ 精选文章：支持设置精选文章
- ✅ 访问统计：自动记录文章阅读量
- ✅ 响应式设计：适配手机和电脑端
- ✅ 后台管理：简洁的管理界面
- ✅ 文档导入：支持导入word文档（支持图片）

## 技术栈

- **后端**：Flask (Python)
- **数据库**：SQLite
- **前端**：原生 HTML/CSS/JavaScript
- **Markdown**：marked.js

---

## 一键安装（Linux 服务器）

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dakerclaw/blog/main/install_server.sh)"
```

安装完成后访问：`http://服务器IP:5000`

## 默认账号

- 用户名：`admin`
- 密码：`admin123`

> ⚠️ 请及时修改默认密码！

---

## 常用命令

| 操作 | 命令 |
|------|------|
| 启动 | `systemctl start blog` |
| 停止 | `systemctl stop blog` |
| 重启 | `systemctl restart blog` |
| 状态 | `systemctl status blog` |
| 日志 | `journalctl -u blog -f` |

---

## 更新博客

```bash
# 进入安装目录
cd /var/www/blog

# 停止服务
systemctl stop blog

# 备份数据库
cp blog.db blog.db.backup.$(date +%Y%m%d)

# 拉取更新
git pull origin main

# 安装新依赖（如有）
./venv/bin/pip install -r requirements.txt

# 重启服务
systemctl start blog
```

---

## 卸载博客

```bash
# 停止服务
systemctl stop blog
systemctl disable blog

# 删除服务文件
rm /etc/systemd/system/blog.service
systemctl daemon-reload

# 删除项目文件
rm -rf /var/www/blog
```

---

## 备份与恢复

### 备份

```bash
cd /var/www/blog
tar -czf /backup/blog-$(date +%Y%m%d).tar.gz blog.db
```

### 恢复

```bash
cd /var/www/blog
# 停止服务
systemctl stop blog

# 恢复数据库
tar -xzf /backup/blog-20240101.tar.gz

# 重启服务
systemctl start blog
```

---

## 项目结构

```
blog/
├── app.py              # Flask 主程序
├── requirements.txt    # Python 依赖
├── install_server.sh   # 服务器一键安装脚本
├── blog.service        # Systemd 服务配置
├── blog.db             # SQLite 数据库（自动生成）
├── templates/          # HTML 模板
└── uploads/            # 上传目录
```

---

## 上传问题处理
如果导入word大于1Mb，需要调整nginx的配置。

```
echo "client_max_body_size 100M;" >> /etc/nginx/conf.d/blog.conf
nginx -t
systemctl reload nginx

```


## License

MIT License
