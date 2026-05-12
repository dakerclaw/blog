import sqlite3
conn = sqlite3.connect('blog.db')
c = conn.cursor()

# 列出所有表
c.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = c.fetchall()
print('数据库中的表:')
for t in tables:
    print(f'  - {t[0]}')

# 检查 site_settings 表
print()
try:
    c.execute('SELECT * FROM site_settings')
    rows = c.fetchall()
    print(f'site_settings 表数据 ({len(rows)} 条):')
    for r in rows:
        val = r[1][:40] + '...' if len(r[1]) > 40 else r[1]
        print(f'  {r[0]}: {val}')
except sqlite3.OperationalError as e:
    print(f'错误: {e}')

conn.close()
