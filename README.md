# OpenClaw Research Toolkit

**赋予 AI Agent 真正的研究能力：搜索、读取、深度研究，一行命令完成。**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-green.svg)](https://github.com/openclaw/openclaw)
[![Python 3.12+](https://img.shields.io/badge/Python-3.12+-yellow.svg)](https://www.python.org/)

[快速开始](#-快速开始) · [功能特性](#-功能特性) · [安装](#-安装) · [使用方法](#-使用方法) · [文档](#-文档)

---

## 为什么需要这个工具？

你的 AI 很擅长写作和思考，但让它去查资料，就会遇到这些问题：

- 🔍 "帮我查一下这个产品评价" → 免费搜索不好用，有用的都收费
- 🌐 "读取这个网页内容" → 返回的是 HTML 源码，完全看不懂
- 📺 "这个视频讲了什么" → 提取不了字幕，手动太麻烦
- 🔬 "深度研究这个话题" → 只能一个一个搜索，没有系统化的方法

**OpenClaw Research Toolkit 把这些变成一个命令：**

```bash
# 搜索
research search "AI 最新进展"

# 网页读取（支持 1700+ 视频站点）
research read "https://youtube.com/watch?v=xxx"

# 深度研究（L1/L2/L3 分级）
research research "市场调研" 3
```

---

## ✨ 功能特性

### 🔍 四大核心工具

| 工具 | 功能 | 说明 |
|------|------|------|
| **搜索 Fallback** | 多源搜索 | SearXNG → Exa AI → MiniMax MCP → DuckDuckGo → 36Kr |
| **DeepReader** | 网页读取 | 双引擎（Trafilatura + Jina Reader），支持 1700+ 视频站点 |
| **Research Workflow** | 深度研究 | L1 快速查询 / L2 专题研究 / L3 深度调查 |
| **性能监控** | 统计分析 | 缓存命中率、性能统计、日志管理 |

### 🚀 核心亮点

- ✅ **完全免费** - 所有工具免费，无需 API Key
- ✅ **智能缓存** - 10 分钟缓存，100 倍性能提升
- ✅ **双引擎保障** - 一个失败自动切换备用引擎
- ✅ **并发处理** - 批量 URL 并发处理，速度快
- ✅ **中断恢复** - 支持断点续传，不丢失进度
- ✅ **自动报告** - L3 研究自动生成 Markdown 报告

---

## 📦 安装

### 方式一：一键安装（推荐）

```bash
curl -LsSf https://raw.githubusercontent.com/SonicBotMan/openclaw-research-toolkit/main/install.sh | bash
```

自动检测环境，创建隔离虚拟环境，安装所有依赖。零污染系统，无需 sudo，可完全卸载。

### 方式二：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/SonicBotMan/openclaw-research-toolkit.git
cd openclaw-research-toolkit

# 2. 安装依赖
./scripts/install-deps.sh

# 3. 配置环境
./scripts/setup.sh

# 4. 验证安装
./scripts/test.sh
```

### 依赖安装

<details>
<summary>点击查看依赖列表和安装方法</summary>

#### 必需依赖

```bash
# jq（JSON 处理）
sudo apt install jq      # Ubuntu/Debian
brew install jq          # macOS

# curl（网络请求）
sudo apt install curl    # Ubuntu/Debian
brew install curl        # macOS

# Python 3.12+
sudo apt install python3 python3-venv  # Ubuntu/Debian
brew install python@3.12               # macOS
```

#### 可选依赖（推荐）

```bash
# SearXNG（本地搜索，更快更稳定）
# Docker 方式部署
docker run -d -p 8888:8080 searxng/searxng:latest

# yt-dlp（视频字幕提取）
pip install yt-dlp

# FFmpeg（媒体转换）
sudo apt install ffmpeg  # Ubuntu/Debian
brew install ffmpeg      # macOS
```

#### Skilless 集成（Exa AI 搜索 + Jina Reader）

```bash
# 安装 skilless
curl -LsSf https://skilless.ai/install | bash
```

</details>

---

## 🎮 使用方法

### 统一命令入口

```bash
# 搜索（自动 Fallback）
research search "AI 最新进展"
research s "关键词"              # 简写

# 网页读取（双引擎）
research read "https://example.com"
research r "URL"                 # 简写

# 深度研究（L1/L2/L3）
research research "主题"         # 自动分级
research research "主题" 1       # L1 快速查询
research research "主题" 2       # L2 专题研究
research research "主题" 3       # L3 深度调查
research rs "主题" 3             # 简写

# 维护命令
research stats                   # 查看统计
research logs                    # 日志管理
research clean                   # 清空缓存
research test                    # 功能测试
```

### 搜索功能

```bash
# 基础搜索
research search "OpenAI GPT-5"

# JSON 输出（便于程序处理）
research search "关键词" json

# 自动 Fallback（5 个搜索引擎）
# 1. SearXNG（本地最快）
# 2. Exa AI（语义搜索）
# 3. MiniMax MCP
# 4. DuckDuckGo
# 5. 36Kr（中文科技资讯）
```

### 网页读取

```bash
# 单个 URL
research read "https://example.com"

# 批量 URL（自动并发）
research read "
https://example.com
https://httpbin.org
"

# 视频字幕（1700+ 站点）
research read "https://www.youtube.com/watch?v=xxx"
research read "https://www.bilibili.com/video/BV1xx411c7mD"
research read "https://www.tiktok.com/@user/video/123"
```

### 深度研究

```bash
# L1：快速查询（1 轮搜索）
research research "Python 教程" 1

# L2：专题研究（2-3 轮，多维度）
research research "AI 芯片对比" 2

# L3：深度调查（5+ 轮，12 个维度）
research research "市场调研" 3
# 自动生成报告：~/.openclaw/workspace/reports/research-*.md
```

---

## 📊 研究深度分级

| 级别 | 触发条件 | 最低要求 | 输出 |
|------|----------|----------|------|
| **L1** | 单一事实、定义 | 1 轮搜索 | 摘要结果 |
| **L2** | 对比、教程 | 2-3 轮，2+ 页面阅读 | 多维度报告 |
| **L3** | 深度分析 | **5+ 轮**，12 个维度，任务列表 | 完整研究报告 |

### L3 多维度检索框架

| 维度 | 搜索模板 | 分析目标 |
|------|----------|----------|
| 时间 | 最新/近期/历史 | 时间线分析 |
| 来源 | 官方/媒体/社区 | 可信度评估 |
| 角度 | 商业/技术/竞争 | 多角度分析 |
| 深度 | 原因/未来/风险 | 深度洞察 |

---

## ⚡ 性能优化

### 缓存机制

```bash
# 缓存 TTL: 10 分钟
# 命中效果: 1.7s → 0.008s（200x 提升）

research stats
# 📊 今日统计:
#    - 总搜索次数: 14
#    - 缓存命中: 5 (35.7%)
#    - SearXNG 成功: 9
```

### 重试机制

- **最大重试**: 3 次
- **退避策略**: 指数退避（2s → 4s → 8s）
- **自动切换**: 一个引擎失败自动切换下一个

### 并发处理

- **DeepReader**: 最多 3 个并发
- **Research**: 12 个维度并行搜索

---

## 📁 文件结构

```
~/.openclaw/workspace/
├── skills/
│   ├── search-fallback/      # 搜索 Fallback
│   │   ├── search.sh
│   │   ├── stats.sh
│   │   └── log-manager.sh
│   ├── deepreader/           # 网页读取
│   │   └── deepreader.sh
│   └── research-workflow/    # 深度研究
│       ├── research.sh
│       └── research          # 统一入口
├── cache/
│   └── search/               # 搜索缓存
├── logs/
│   └── search-fallback.log   # 日志
└── reports/
    └── research-*.md         # 研究报告
```

---

## 🔧 配置

### Cron 自动维护

```bash
# 添加自动维护任务
(crontab -l 2>/dev/null; echo "0 3 * * * ~/.openclaw/workspace/skills/search-fallback/log-manager.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 * * * * ~/.openclaw/workspace/skills/search-fallback/stats.sh") | crontab -
```

### 环境变量

```bash
# SearXNG 地址（默认：localhost:8888）
export SEARXNG_URL="http://192.168.11.147:8515"

# 缓存 TTL（默认：600 秒）
export CACHE_TTL=600

# 最大并发数（默认：3）
export MAX_CONCURRENT=3
```

---

## 🛠️ 故障排查

### 问题 1：搜索失败

```bash
# 检查 SearXNG
curl http://192.168.11.147:8515/healthz

# 查看日志
tail ~/.openclaw/workspace/logs/search-fallback.log
```

### 问题 2：网页读取失败

```bash
# 测试 Jina Reader
cd ~/.agents/skills/skilless && source .venv/bin/activate
python scripts/web.py "https://example.com"
```

### 问题 3：缓存问题

```bash
# 清空缓存
research clean
```

---

## 📚 相关资源

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Skilless.ai](https://github.com/brikerman/skilless.ai) - AI 搜索和读取
- [SearXNG](https://github.com/searxng/searxng) - 元搜索引擎
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - 视频下载工具

---

## 📝 更新日志

### v1.0.0 (2026-03-04)

- 🎉 初始发布
- ✨ 搜索 Fallback（5 个搜索引擎）
- ✨ DeepReader（双引擎 + 1700+ 视频站点）
- ✨ Research Workflow（L1/L2/L3 分级）
- ✨ 统一命令入口
- ✨ 缓存机制（100x 提升）
- ✨ 自动化维护

---

## 📄 License

MIT License - 详见 [LICENSE](LICENSE)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Made with ❤️ by OpenClaw Community**
