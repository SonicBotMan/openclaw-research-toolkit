# 调研报告自动上传配置

## 配置说明

从 2026-03-04 起，所有调研报告自动上传到 WebDAV。

### WebDAV 配置

| 配置项 | 值 |
|--------|-----|
| **服务器** | http://192.168.11.147:5005 |
| **目录** | /openclaw/reports/ |
| **用户** | h523034406 |
| **密码** | 已配置 |

### 使用方法

#### 自动上传（推荐）

```bash
# L3 深度研究（自动上传）
research research "主题" 3

# 报告生成后自动上传到 WebDAV
```

#### 手动上传

```bash
# 上传单个报告
research upload ~/.openclaw/workspace/reports/报告.md

# 批量上传
for report in ~/.openclaw/workspace/reports/*.md; do
    research upload "$report"
done
```

### 上传记录

| 时间 | 报告 | 状态 |
|------|------|------|
| 2026-03-04 20:26 | openclaw-research-toolkit-release | ✅ |
| 2026-03-04 20:26 | research-57fded7a-20260304 | ✅ |
| 2026-03-04 20:26 | skills-iteration-20260304 | ✅ |
| 2026-03-04 20:26 | 度加剪辑APP深度调研报告 | ✅ |

### 访问报告

WebDAV 浏览器访问：
```
http://192.168.11.147:5005/openclaw/reports/
```

### 错误处理

| HTTP 状态码 | 说明 | 处理 |
|------------|------|------|
| 201 | 创建成功 | ✅ 正常 |
| 204 | 更新成功 | ✅ 正常 |
| 401 | 认证失败 | 检查用户名密码 |
| 403 | 权限不足 | 检查目录权限 |
| 507 | 空间不足 | 清理 WebDAV 空间 |

---

**配置时间**: 2026-03-04 20:26 UTC+8
**配置人**: 小茹
