# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-04

### Added

#### 核心功能

- **搜索 Fallback 系统**
  - 5 个搜索引擎自动切换（SearXNG → Exa AI → MiniMax MCP → DuckDuckGo → 36Kr）
  - 智能缓存机制（10 分钟 TTL，100x 性能提升）
  - 重试机制（最多 3 次，指数退避）
  - JSON 输出支持

- **DeepReader 网页读取**
  - 双引擎保障（Trafilatura + Jina Reader）
  - 支持 1700+ 视频站点（YouTube、B站、抖音、TikTok 等）
  - 批量 URL 并发处理（最多 3 个并发）
  - 自动字幕提取和翻译

- **Research Workflow 深度研究**
  - L1/L2/L3 三级研究深度
  - 多维度检索框架（时间/来源/角度/深度）
  - 任务列表强制机制（L3 必须创建任务）
  - 自动生成研究报告（Markdown 格式）
  - 中断恢复支持（断点续传）

- **统一命令入口**
  - `research search` - 搜索
  - `research read` - 读取
  - `research research` - 研究
  - `research stats` - 统计
  - `research clean` - 清缓存
  - `research test` - 测试

#### 性能优化

- 智能缓存（10 分钟 TTL）
  - 命中率：30-40%
  - 性能提升：100x（1.7s → 0.008s）
- 并发处理
  - DeepReader: 最多 3 个并发
  - Research: 12 个维度并行
- 错误重试
  - 最多 3 次重试
  - 指数退避（2s → 4s → 8s）

#### 维护工具

- **stats.sh** - 性能统计脚本
  - 缓存命中率统计
  - 搜索引擎使用分布
  - 错误追踪
- **log-manager.sh** - 日志管理脚本
  - 日志分级（INFO/WARN/ERROR）
  - 日志轮转（保留 7 天）
  - 自动压缩归档
- **Cron 自动化**
  - 每小时统计
  - 每天凌晨 3 点维护

#### 文档

- README.md（参考 skilless.ai 风格）
- EXAMPLES.md（使用示例）
- INTEGRATION.md（整合报告）
- 故障排查指南
- API 文档

#### 安装

- 一键安装脚本（install.sh）
  - 自动检测系统（Linux/macOS）
  - 自动安装依赖
  - 创建隔离环境
  - 零污染系统
  - 支持完全卸载
- 依赖安装脚本
- 环境配置脚本
- 功能测试脚本

### Performance

- 搜索延迟（缓存命中）: 8ms
- 搜索延迟（无缓存）: 1.7s
- 缓存命中率: 30-40%
- 并发搜索: 5 个/秒
- 视频站点支持: 1700+

### Dependencies

- curl（网络请求）
- jq（JSON 处理）
- Python 3.12+（脚本运行）
- trafilatura（网页提取）
- youtube-transcript-api（字幕提取）
- yt-dlp（视频下载，可选）
- FFmpeg（媒体转换，可选）

### Supported Platforms

- Ubuntu 20.04+
- Debian 11+
- macOS 12+
- OpenClaw 2026.2+

---

## Future Plans

### [1.1.0] - Planned

- Web UI 界面
- 浏览器插件
- API 服务
- 更多搜索引擎（Google Custom Search、Bing）
- AI 摘要生成（集成 OpenAI/Anthropic）
- 多语言支持（英文、日文）

### [1.2.0] - Planned

- 分布式搜索（多节点）
- 知识图谱集成
- 自动报告生成（PDF/HTML）
- 协作研究（多人共享）
- 版本控制（Git 集成）

---

[1.0.0]: https://github.com/SonicBotMan/openclaw-research-toolkit/releases/tag/v1.0.0
