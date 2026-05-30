# Vibe 资讯树（AI 大模型 / 智能代理 / VibeCoding）

> **采集窗口**：北京时间 `2026-05-28 10:50` — `2026-05-30 10:50`（48h）  
> **最后 upsert**：`2026-05-30`  
> **说明**：时间字段格式为 `yymmdd HH:MM`（北京时间）；`~tokens` 为正文可读部分粗估（非 HTML 全页）。

---

## 树状目录

```text
vibe（48h）
├── 大模型发布与升级
│   └── Anthropic（Opus 4.8 / Mythos 预告 / Series H）
├── 智能代理产品与平台
│   ├── 编码代理（Claude Code Dynamic Workflows）
│   ├── 企业代理（Microsoft Copilot Super App / M365）
│   └── 研究型代理（ProAct 主动式）
├── VibeCoding / Agentic Engineering
│   ├── 工程化工作流（并行子代理、effort 控费）
│   └── 上下文效率（GenericAgent 论文传播）
├── 安全与治理
│   └── 多轮对抗（Cisco 前沿模型评测）
└── 基础设施
    └── Apple Silicon 推理（MLXcel 开源）
```

---

## 大模型发布与升级

### Anthropic

- **Introducing Claude Opus 4.8**
  - 来源缩写：**Anthropic**
  - 时间：`250528 20:00`（官方发布日 2026-05-28；国内报道多称 5/29 凌晨上线）
  - URL：https://www.anthropic.com/news/claude-opus-4-8
  - ~tokens：**3200**
  - 要点：旗舰升级；强调代理任务诚实度（代码瑕疵漏报约降至 1/4）；Fast Mode 2.5× 且费用降为此前 1/3；同价 $5/$25（in/out M tokens）。

- **Claude Opus 4.8 产品页**
  - 来源缩写：**Anthropic**
  - 时间：`250528 20:00`
  - URL：https://www.anthropic.com/claude/opus
  - ~tokens：**1800**
  - 要点：定位「最强通用可用模型」；Super-Agent 基准唯一全案例端到端完成；Online-Mind2Web 84% 计算机使用。

- **Anthropic raises $65B Series H at $965B valuation**
  - 来源缩写：**Anthropic**
  - 时间：`250529 08:00`
  - URL：https://www.anthropic.com/news/anthropic-raises-65b-series-h（同公告链）
  - ~tokens：**900**
  - 要点：估值 **$965B** 超 OpenAI 公开估值；年化收入 run-rate **$47B**；IPO 预期与算力扩张。

- **Anthropic's Claude Opus 4.8 is four times more honest, Mythos next**
  - 来源缩写：**TNW**
  - 时间：`250528 22:00`
  - URL：https://thenextweb.com/news/anthropics-claude-opus-4-8-is-its-most-honest-ai-model-yet-and-mythos-is-coming-in-weeks
  - ~tokens：**1100**
  - 要点：**Mythos** 级模型数周内更广发布；Project Glasswing 已发现 1 万+ 高危漏洞。

- **World's most valuable AI start-up: Anthropic nears $1 trillion valuation**
  - 来源缩写：**路透系**（Euronews）
  - 时间：`250529 14:00`
  - URL：https://www.euronews.com/business/2026/05/29/worlds-most-valuable-ai-start-up-anthropic-nears-1tn-valuation-overtaking-openai
  - ~tokens：**950**
  - 要点：商业叙事；与 OpenAI、SpaceX 估值对比；美国防部与 Claude 供应争议背景。

- **Anthropic bests OpenAI in valuation race, hitting $965B with Series H**
  - 来源缩写：**PitchBook**
  - 时间：`250529 16:00`
  - URL：https://pitchbook.com/news/articles/anthropic-bests-openai-in-valuation-race-hitting-965b-with-series-h
  - ~tokens：**850**
  - 要点：领投 Altimeter、Dragoneer、Greenoaks、Coatue 等；收入口径与 OpenAI ~$30B 对比。

- **New Claude model drops as Anthropic overtakes OpenAI**
  - 来源缩写：**Rolling Out**
  - 时间：`250529 20:05`
  - URL：https://rollingout.com/2026/05/29/new-claude-model-drops-anthropic-openai/
  - ~tokens：**700**
  - 要点：Opus 4.8 与融资同日；声称优于 GPT-5.5 / Gemini 3.1 Pro 部分基准。

- **刚刚！Claude Opus 4.8 炸场，一夜升级成工作流 AI**
  - 来源缩写：**网易**
  - 时间：`250529 04:00`
  - URL：https://m.163.com/dy/article/KU35GV0P051100B9.html
  - ~tokens：**1300**
  - 要点：国内解读；认为 **Dynamic Workflows + effort control** 比单纯分数更重要；代理执行导向。

- **Anthropic 发布 Opus 4.8：动态工作流引领 AI 协作**
  - 来源缩写：**赢政天下**
  - 时间：`250529 10:00`
  - URL：https://www.yingzheng.com/article/anthropic-opus-4-8-dynamic-workflows
  - ~tokens：**1100**
  - 要点：TechCrunch 路线综述；子代理编排、企业 Beta。

---

## 智能代理产品与平台

### 编码代理 · Claude Code

- **Dynamic Workflows（研究预览）— 随 Opus 4.8 发布**
  - 来源缩写：**Anthropic**
  - 时间：`250528 20:00`
  - URL：https://www.anthropic.com/news/claude-opus-4-8
  - ~tokens：**600**（该功能段落）
  - 要点：单会话并行 **数百子代理**；完成后自验证；适合十万行级代码库迁移；Enterprise/Team/Max 可用。

- **Claude Code 上新，竟然是个「销金窟」**
  - 来源缩写：**智东西**（网易转载）
  - 时间：`250529 16:12`
  - URL：https://www.163.com/dy/article/KU411D13051180F7.html
  - ~tokens：**1400**
  - 要点：CLI/桌面/VS Code 预览；Max/Team 默认开；**ultracode** 拉高思考；官方警告 token 远高于普通会话。

- **Effort control（claude.ai / Cowork）**
  - 来源缩写：**Anthropic**
  - 时间：`250528 20:00`
  - URL：https://www.anthropic.com/news/claude-opus-4-8
  - ~tokens：**400**
  - 要点：用户可选思考深度；Opus 4.8 默认 high effort；与 VibeCoding「无脑接受输出」形成对照。

- **Messages API：messages 数组内 system 条目**
  - 来源缩写：**Anthropic**
  - 时间：`250528 20:00`
  - URL：https://www.anthropic.com/news/claude-opus-4-8
  - ~tokens：**250**
  - 要点：代理运行中可更新权限/预算/环境，不破坏 prompt cache。

### 企业代理 · Microsoft

- **This is Microsoft's unreleased AI super app（Copilot Super App / Autopilot / Scout）**
  - 来源缩写：**Sources**（Alex Heath）
  - 时间：`250530 08:00`
  - URL：https://sources.news/p/leaked-microsoft-ai-copilot-super-app-autopilot-scout
  - ~tokens：**650**
  - 要点：泄露截图；整合 chat / 编码 / Cowork；**Autopilot** 代理层；主动代理 **Scout**（类 OpenClaw）。

- **May 2026 announcements — Agents move into action**
  - 来源缩写：**微软 Learn**
  - 时间：`250529 09:00`
  - URL：https://learn.microsoft.com/en-us/partner-center/announcements/2026-may
  - ~tokens：**1200**
  - 要点：Legal Agent（Word）；Cowork / Critique / Council；**Agentic Outlook**；伙伴部署 playbook。

- **Microsoft 365 E7 and Agent 365 GA**
  - 来源缩写：**微软 Learn** / **AlwaysBeyond**
  - 时间：`250501 00:00`（GA 5/1；本窗口内持续引用）
  - URL：https://learn.microsoft.com/en-us/partner-center/announcements/2026-may
  - ~tokens：**500**（Agent 365 相关段落）
  - 要点：第三方代理治理控制面；与 E7 捆绑 — 企业级 agent 运维话题。

### 研究型代理 · ProAct

- **AI Agents Are Learning to Predict What Users Want—Before They Ask**
  - 来源缩写：**Decrypt**
  - 时间：`250529 12:00`（48h 内行业传播；精确刊时未标注）
  - URL：https://decrypt.co/369382/ai-agents-learning-predict-what-users-want-before-ask
  - ~tokens：**1100**
  - 要点：上海交大 × 腾讯 **ProAct**；空闲算力预测需求；轮次 **-14.8%**、幻觉 **-28.1%**（论文数据）。

- **Anticipate and Learn: Unleashing Idle-Time Compute in Proactive Agents**
  - 来源缩写：**arXiv**
  - 时间：`250528 12:00`（编号 2605.25971，2026 年 5 月档）
  - URL：https://arxiv.org/abs/2605.25971
  - ~tokens：**12000+**（全文；新闻摘要约 **800**）
  - 要点：Future-State Prediction + Idle-Time Acquisition；benchmark **ProActEval**（200 场景 / 40 域）。

### 资讯聚合（跨条引用）

- **AI News Briefs BULLETIN BOARD for May 2026**（节选 5/28–5/29）
  - 来源缩写：**RadicalDS**
  - 时间：`250529 18:00`
  - URL：https://radicaldatascience.wordpress.com/2026/05/29/ai-news-briefs-bulletin-board-for-may-2026/
  - ~tokens：**4500**（整板）；本窗口摘录 **~900**
  - 要点：Opus 4.8、MLXcel 开源、Robinhood 代理炒股（5/27 首发，略早于窗口）、Cognition/Devin 融资（同上）。

- **AI News May 30 2026**
  - 来源缩写：**AIToolsRecap**
  - 时间：`250530 06:00`
  - URL：https://aitoolsrecap.com/Blog/ai-news-may-30-2026
  - ~tokens：**800**
  - 要点：日汇总；Anthropic $965B + Opus 4.8 SWE-Bench Pro 69.2% 等。

---

## VibeCoding / Agentic Engineering

- **Claude Code Dynamic Workflows →「AI 工程队」范式**
  - 来源缩写：**网易** / **智东西**
  - 时间：`250529 04:00` — `250529 16:12`
  - URL：https://m.163.com/dy/article/KU35GV0P051100B9.html · https://www.163.com/dy/article/KU411D13051180F7.html
  - ~tokens：**1400**（合并阅读）
  - 要点：从「单上下文循环」到 **拆任务 + 并行 subagent + 复核**；Vibe 风险提示：**token 成本陡增**，需小范围试跑 — 典型 agentic engineering 控费议题。

- **GenericAgent: Contextual Information Density Maximization**
  - 来源缩写：**arXiv** / **AgentPedia**
  - 时间：`250428 00:00`（论文 2604.17091；本窗口内技术圈续热）
  - URL：https://arxiv.org/abs/2604.17091 · https://agentpedia.codes/blog/generic-agent-guide
  - ~tokens：**900**（导读）/ **15000+**（论文）
  - 要点：~**30K** 活跃上下文预算；分层记忆 + SOP 结晶 + **主动截断压缩**；对标 Vibe 长会话爆上下文问题。

> **窗口内 VibeCoding 专名报道较少**；上述条目偏 **agentic 工程化**（编排、控费、验证），与「纯 Vibe 盲信输出」形成行业对照。

---

## 安全与治理

- **Proprietary Problems: No Frontier Model Is Multi-Turn Immune**
  - 来源缩写：**Cisco**
  - 时间：`250528 10:00`
  - URL：https://blogs.cisco.com/ai/proprietary-problems
  - ~tokens：**2000**
  - 要点：15 款闭源旗舰；多轮 ASR **7.89%–88.30%**；单轮 ASR 不能代表真实风险。

- **Cisco report finds no closed frontier AI model is safe from multi-turn attacks**
  - 来源缩写：**SiliconANGLE**
  - 时间：`250527 18:00`（发布；**250528** 仍在 48h 传播窗口内）
  - URL：https://siliconangle.com/2026/05/27/cisco-report-finds-no-closed-frontier-ai-model-safe-multi-turn-attacks/
  - ~tokens：**950**
  - 要点：GPT-5.4 单轮 2.74% → 多轮 24.68%；Gemini 3 Pro 18.1% → 73.35%。

- **Cisco study finds major frontier models susceptible to multi-turn prompt injection**
  - 来源缩写：**SC Media**
  - 时间：`250528 08:00`
  - URL：https://www.scworld.com/news/cisco-study-finds-major-frontier-models-susceptible-to-multi-turn-prompt-injection-attacks
  - ~tokens：**700**
  - 要点：治理建议 — 运行时护栏、红队、应用层监控；拒绝单轮指标采购。

---

## 基础设施（代理运行时）

- **MLXcel goes open source, joining the Agentic AI Foundation**
  - 来源缩写：**RadicalDS**（转述 MLX 社区）
  - 时间：`250528 12:00`
  - URL：https://radicaldatascience.wordpress.com/2026/05/29/ai-news-briefs-bulletin-board-for-may-2026/（条目 5/28）
  - ~tokens：**350**
  - 要点：Apache 2.0；M5 Max 预填充最高 **2.70×** mlx-lm；**70+** 文本架构、**22** VLM；降低 Apple 端侧代理推理门槛。

---

## 窗口外但常被连带提及（未收录详情）

| 标题 | 时间 | 原因 |
|------|------|------|
| Robinhood AI agentic trading | `250527` | 早于窗口起点（~62h） |
| Cognition / Devin $1B @ $26B | `250527` | 同上 |
| OpenAI Codex 税务自改进代理 | `250527` | 同上 |
| Google I/O Gemini Spark / Antigravity | `250520` | 超出 48h |

---

## 统计

| 维度 | 数量 |
|------|------|
| 收录条目（叶子） | **28** |
| 一级主题 | **5** |
| 来源语种 | 英 **22** / 中 **6** |

---

*下次 cron upsert：在窗口内追加叶子节点，并更新「统计」与窗口时间戳。*
