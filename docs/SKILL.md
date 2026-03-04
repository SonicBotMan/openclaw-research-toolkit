---
name: research-workflow
description: "统一研究工作流 - 结合 deep-analysis 多维度框架 + skilless L1/L2/L3 分级 + Exa AI 语义搜索。支持快速查询、深度研究、多源交叉验证、结构化报告。"
version: "3.0.0"
tags: [research, analysis, 深度研究, 调研]
---

# 研究工作流 v3.0

整合 **deep-analysis** 多维度框架 + **skilless-research** L1/L2/L3 分级 + **Exa AI** 语义搜索。

## 🆕 v3.0 新特性

| 特性 | 来源 | 说明 |
|------|------|------|
| L1/L2/L3 深度分级 | skilless | 根据复杂度自动选择研究深度 |
| 多维度检索框架 | deep-analysis | 时间/来源/角度/深度四维 |
| Exa AI 语义搜索 | skilless | 免费无 Key，更智能的搜索 |
| 任务列表强制机制 | skilless | L3 必须创建任务列表 |
| 可信度自动评估 | deep-analysis | 高/中/低三级可信度 |
| 交叉验证要求 | skilless | L2+ 必须多源验证 |

---

## 研究深度分级

| 级别 | 触发条件 | 最低要求 |
|------|----------|----------|
| **L1 快速查询** | 单一事实、定义、简单问题 | 1 轮搜索，1-2 次查询 |
| **L2 专题研究** | 对比、教程、特定主题 | 2-3 轮，2+ 页面阅读，基础验证 |
| **L3 深度调查** | 多维度分析、市场研究、技术评估 | **5+ 轮**，5+ 页面，**任务列表强制** |

### 自动判断规则

```
单一搜索结果可回答 → L1
涉及对比/深度理解 → L2
需要多角度/用户说"研究"/"深度"/"调查" → L3
```

---

## 研究工作流

### L1：快速查询

```bash
# 一键搜索
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "OpenAI CEO" --level 1

# 自动选择引擎：SearXNG → Exa AI → DuckDuckGo
```

### L2：专题研究

```bash
# 自动多维度搜索
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "GPT-5 发布时间" --level 2

# 流程：
# 1. 定义范围 → 核心问题是什么
# 2. 多轮搜索 → 2-3 轮并行
# 3. 页面阅读 → 2+ 篇完整内容
# 4. 交叉验证 → 关键数据多源核实
# 5. 输出报告 → 结论优先
```

### L3：深度调查

```bash
# 完整深度研究
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "AI 芯片市场竞争格局" --level 3

# 流程：
# 1. 定义范围 → 创建任务列表（必须！）
# 2. 多维度分解 → 时间/来源/角度/深度
# 3. 5+ 轮搜索 → 每轮 3-5 并行查询
# 4. 5+ 页面阅读 → 完整内容提取
# 5. 交叉验证 → 每个关键数据 2-3 源
# 6. 综合报告 → 结论 + 引用 + 不确定性
```

---

## 多维度检索框架

### 1️⃣ 时间维度
| 类型 | 搜索模板 |
|------|----------|
| 最新 | `{topic} 最新 新闻 今日` |
| 近期 | `{topic} 近期 发展 动态` |
| 历史 | `{topic} 历史 背景 起源` |

### 2️⃣ 来源维度
| 类型 | 搜索模板 | 可信度 |
|------|----------|--------|
| 官方 | `{topic} 官方 公告` | 高 |
| 媒体 | `{topic} 媒体 报道` | 中 |
| 社区 | `{topic} 社区 讨论` | 待验证 |
| 数据 | `{topic} 数据 报告` | 高 |

### 3️⃣ 角度维度
| 类型 | 搜索模板 |
|------|----------|
| 商业 | `{topic} 商业 影响 市场` |
| 技术 | `{topic} 技术 原理 实现` |
| 政策 | `{topic} 政策 监管 法规` |
| 竞争 | `{topic} 竞争对手 对比` |

### 4️⃣ 深度维度
| 类型 | 搜索模板 | 分析目标 |
|------|----------|----------|
| 事实 | `{topic}` | 发生了什么 |
| 原因 | `{topic} 原因 为什么` | 为什么发生 |
| 未来 | `{topic} 未来 趋势 预测` | 会怎样发展 |
| 风险 | `{topic} 风险 问题 挑战` | 有什么风险 |

---

## 搜索引擎优先级

```
1. SearXNG（本地最快，多引擎聚合）
2. Exa AI（语义搜索，免费无 Key）
3. MiniMax MCP（备用）
4. DuckDuckGo（兜底）
5. 36Kr（中文科技资讯）
```

---

## 可信度评估规则

| 级别 | 域名特征 | 处理方式 |
|------|----------|----------|
| **高** | gov, edu, org, 官方, com.cn | 直接引用 |
| **中** | news, tech, 36kr, 财经 | 标注来源 |
| **低** | blog, forum, 知乎 | 需要验证 |

---

## 输出格式

### 报告结构（L2/L3）

```markdown
# [主题] 研究报告

## 核心结论
> 最重要发现放在最前面

## 一、核心事实
| 要素 | 内容 |
|------|------|
| 主题 | ... |
| 时间 | ... |
| 来源数 | ... |
| 关键组织 | ... |

## 二、多维信息矩阵
| 维度 | 核心内容 | 可信度 |
|------|----------|--------|
| ... | ... | 高/中/待验证 |

## 三、深度分析
- 原因分析
- 影响评估
- 关键争议

## 四、未来预测
| 时间范围 | 预测 | 依据 |
|------|------|------|
| 短期 | ... | [1] |
| 中期 | ... | [2] |

## 五、行动建议
| 角色 | 建议 |
|------|------|
| 开发者 | ... |
| 用户 | ... |

## 数据来源
[1] [标题](URL)
[2] [标题](URL)
```

---

## 质量检查清单

L3 研究必须满足：

- [ ] 至少 5 轮搜索
- [ ] 至少 3 个维度独立调查
- [ ] 至少 5 篇完整页面阅读
- [ ] 关键数据 2-3 源交叉验证
- [ ] 标注信息时效性
- [ ] 区分事实与观点
- [ ] 标注不确定性

---

## 使用方法

```bash
# 快速查询（L1）
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "查询内容"

# 专题研究（L2）
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "查询内容" --level 2

# 深度调查（L3）
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "查询内容" --level 3

# 指定输出格式
bash ~/.openclaw/workspace/skills/research-workflow/research.sh "查询内容" --output json
```

---

## 相关技能

- [search-fallback](../search-fallback/) - 搜索 Fallback 机制
- [deepreader](../deepreader/) - 网页内容读取
- [skilless](../skilless/) - Skilless 工具集
