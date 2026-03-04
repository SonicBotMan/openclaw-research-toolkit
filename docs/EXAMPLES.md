# Skills 整合 - 使用示例

## 快速开始

### 1. 搜索

```bash
# 基础搜索（自动 Fallback）
bash ~/.openclaw/workspace/skills/search-fallback/search.sh "AI 最新进展"

# JSON 输出
bash ~/.openclaw/workspace/skills/search-fallback/search.sh "关键词" json

# 查看统计
bash ~/.openclaw/workspace/skills/search-fallback/stats.sh
```

### 2. 网页读取

```bash
# 单个 URL
bash ~/.openclaw/workspace/skills/deepreader/deepreader.sh "https://example.com"

# 批量 URL（自动并发）
bash ~/.openclaw/workspace/skills/deepreader/deepreader.sh "
https://example.com
https://httpbin.org
"

# 视频字幕（YouTube/B站/抖音）
bash ~/.openclaw/workspace/skills/deepreader/deepreader.sh "https://www.youtube.com/watch?v=xxx"
```

### 3. 深度研究

```bash
# 自动分级（根据关键词自动判断 L1/L2/L3）
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "OpenAI GPT-5"

# L1 快速查询
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "Python 教程" 1

# L2 专题研究
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "AI 芯片对比" 2

# L3 深度调查（自动保存报告）
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "市场调研" 3
```

---

## 性能优化

### 缓存机制

- **TTL**: 10 分钟
- **命中效果**: 1.7s → 0.017s（100x 提升）
- **缓存位置**: `~/.openclaw/workspace/cache/search/`

### 重试机制

- **最大重试**: 3 次
- **退避策略**: 指数退避（2s → 4s → 8s）

### 并发处理

- **DeepReader**: 最多 3 个并发
- **Research**: 12 个维度并行搜索

---

## 报告位置

- **研究报告**: `~/.openclaw/workspace/reports/research-*.md`
- **搜索日志**: `~/.openclaw/workspace/logs/search-fallback.log`
- **统计报告**: `bash stats.sh` 查看

---

## 故障排查

### 问题 1: 搜索失败

**症状**: 所有搜索源都失败

**排查**:
```bash
# 检查 SearXNG
curl http://192.168.11.147:8515/healthz

# 检查网络
ping 8.8.8.8

# 查看日志
tail ~/.openclaw/workspace/logs/search-fallback.log
```

### 问题 2: 网页读取失败

**症状**: DeepReader 和 Jina Reader 都失败

**排查**:
```bash
# 检查 URL 是否有效
curl -I "https://example.com"

# 检查 SSL 证书
openssl s_client -connect example.com:443

# 尝试直接访问
wget "https://example.com"
```

### 问题 3: 缓存问题

**症状**: 搜索结果过时或不一致

**解决**:
```bash
# 清空缓存
rm -rf ~/.openclaw/workspace/cache/search/*

# 重新搜索
bash ~/.openclaw/workspace/skills/search-fallback/search.sh "关键词"
```

---

## 维护命令

```bash
# 查看统计
bash ~/.openclaw/workspace/skills/search-fallback/stats.sh

# 清理日志
bash ~/.openclaw/workspace/skills/search-fallback/log-manager.sh

# 查看缓存
ls -lh ~/.openclaw/workspace/cache/search/

# 清空缓存
rm -rf ~/.openclaw/workspace/cache/search/*
```

---

**更新时间**: 2026-03-04 19:16 UTC+8
