# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260626 07:00` UTC → `260628 07:00` UTC（48h，cron 触发 `2026-06-28T07:00Z`） |
| 本文件更新 | `260628 07:00` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 3 · 新产品 5 · 新模式 4） |
| main 合并 commit | `e01879d` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Previewing GPT-5.6 Sol: Sol, Terra, and Luna — limited preview of next-generation tiered family**
  - 来源：**OpenAI**
  - 时间：`260626`
  - 正文：~**1120** tok
  - URL：https://openai.com/index/previewing-gpt-5-6-sol/
  - 类型：新模型
  - 要点：
    - **6/26** OpenAI 发布 **GPT-5.6** 三档：**Sol**（旗舰）、**Terra**（日常，性能≈GPT-5.5 但 **2×** 便宜）、**Luna**（最快最便宜）；定价 Sol **$5/$30**、Terra **$2.50/$15**、Luna **$1/$6** per 1M tokens；新增 **30 分钟** prompt cache 与显式 cache breakpoint。
    - 能力：Sol **Terminal-Bench 2.1** SOTA（标准 **88.8%**、Ultra **91.9%**）；新增 **`max`** reasoning effort 与 **`ultra`** 模式（多 subagent 并行）；**7 月** Cerebras 上 Sol 达 **750 tok/s**。
    - 访问：受美国政府要求，首批仅约 **20** 家可信伙伴经 API/Codex 预览，GA 计划数周内；OpenAI 公开反对将此审查流程长期化。

- **MAI-Code-1-Flash — generally available for GitHub Copilot Business and Enterprise**
  - 来源：**GitHub**
  - 时间：`260626`
  - 正文：~**680** tok
  - URL：https://github.blog/changelog/2026-06-26-mai-code-1-flash-for-copilot-business-and-copilot-enterprise/
  - 类型：新模型
  - 要点：
    - **6/26** Microsoft AI 自研 coding 模型 **MAI-Code-1-Flash** 在 **Copilot Business/Enterprise** GA（个人 VS Code 已于 **6/2** 起 rollout）；**256K** 上下文，无第三方蒸馏，直接针对 Copilot harness 训练。
    - **Adaptive thinking**：简单任务短答、复杂任务自动加 reasoning budget；适合高并发 agentic 循环（低延迟 + 低 serving cost）。
    - 企业管理员须在 Copilot 设置启用 **MAI-Code-1-Flash** policy；按 provider list price 计费（usage-based billing）。

- **Claude Mythos 5 — U.S. clears partial redeployment to 100+ trusted cyber partners (Fable 5 still blocked)**
  - 来源：**日経**
  - 时间：`260626`
  - 正文：~**720** tok
  - URL：https://www.japantimes.co.jp/business/2026/06/27/tech/anthropic-mythos-ai-us-use/
  - 类型：新模型
  - 要点：
    - **6/26** 美国商务部 Lutnick 函告 Anthropic：经风险缓解，**Mythos 5** 可重新部署给 **100+** 可信美国组织（Fortune 500、联邦机构、关键基础设施防御方）；Anthropic 正快速恢复已批准客户访问。
    - **Fable 5** 仍全面封锁、无恢复时间表——形成「最强 cyber 档恢复、消费级 cyber 档仍禁」的非对称格局；距 **6/12** 全球下架约两周。
    - 与同日 OpenAI **GPT-5.6** 政府门控预览并列，标志美国 frontier cyber 模型发布从「自愿审查」转向「逐客户许可 + 分级恢复」。

### 新产品

- **OpenMontage — first open-source agentic video production system (12 pipelines, 500+ skills)**
  - 来源：**GitHub**
  - 时间：`260626`
  - 正文：~**760** tok
  - URL：https://github.com/calesthio/OpenMontage
  - 类型：新产品
  - 要点：
    - **6/25–26** `calesthio/OpenMontage` GitHub Trending #1：首个开源 **agent-first** 视频制作系统——**12** 条 pipeline、**52** 工具、**500+** agent skills；AGPL-3.0，**22K+** stars。
    - 无中央 Python orchestrator：AI 编码助手（Claude Code/Cursor/Codex/Copilot）读 YAML manifest + Markdown director skills 编排全流程（调研→脚本→资产生成→剪辑→合成）。
    - 覆盖 animated explainer、documentary montage、talking-head、screen-demo 等；集成 FFmpeg/Remotion/ElevenLabs/FLUX 等 **50+** 媒体工具。

- **Salesforce Agentic B2C Developer Toolkit — CLI, MCP server, and IDE extension for commerce agents**
  - 来源：**Salesforce**
  - 时间：`260626`
  - 正文：~**680** tok
  - URL：https://www.salesforce.com/blog/b2c-commerce-june-26-release/
  - 类型：新产品
  - 要点：
    - **6/26** Salesforce B2C Commerce **June '26** 发布 **Agentic B2C Developer Toolkit**：统一 **CLI** + **MCP server** + **VS Code IDE Extension** + agent skills，支持 Agentforce Vibes/Claude Code/Codex/Cursor/Copilot 对话式操作。
    - 能力：沙箱创建、cartridge 部署、组件生成、作业管理；VS Code 扩展提供 B2C API 全谱调试与实时类型提示；GitHub Actions CI/CD 工作流。
    - 标志垂直电商 agent 工具链产品化——从通用 VibeCoding 向 **MCP 可交付 commerce agent** 渗透。

- **GitHub Desktop 3.6 — Copilot SDK commit/conflict resolution + Git worktrees for parallel agents**
  - 来源：**GitHub**
  - 时间：`260626`
  - 正文：~**740** tok
  - URL：https://github.blog/changelog/2026-06-26-github-desktop-3-6-worktrees-and-deeper-copilot-integration/
  - 类型：新产品
  - 要点：
    - **6/26** **GitHub Desktop 3.6.0** 全面迁移至 **Copilot SDK**：AI 辅助 commit message 生成（读取 `.github/copilot-instructions.md` + `AGENTS.md`）与 merge conflict 解释/建议 resolution。
    - 新增 **Git worktrees** 原生支持——多分支并行开发无需反复 stash/switch/clone，直接对接 coding agent 的隔离 worktree 会话模式。
    - 所有 Copilot 功能内置 **model picker** + **BYOK**（第三方 API 或本地模型）；macOS/Windows 渐进 rollout。

- **gstack — Garry Tan's 23-persona Claude Code slash-command engineering team (MIT)**
  - 来源：**GitHub**
  - 时间：`260627`
  - 正文：~**820** tok
  - URL：https://github.com/garrytan/gstack
  - 类型：新产品
  - 要点：
    - **6/27** YC CEO **Garry Tan** 发布 **gstack**（MIT，**117K+** stars）：**23** 个 slash command 角色（CEO/Designer/Eng Manager/Release/Doc/QA/Security 等）+ **8** 工具，全 Markdown 配置，将 Claude Code 变为「虚拟工程团队」。
    - 核心命令：`/ship`（sync→test→coverage audit→PR）、`/review`（生产级 bug hunt）、`/qa`（真实浏览器测试）、`/security`（OWASP+STRIDE）；无专有 runtime，纯 Claude Code 配置层。
    - 标志 VibeCoding 从「单 agent 对话」转向**可 fork 的高层工程角色 playbook**——高管/创始人公开其 agent 工作流 SSOT。

- **DeepSpec + DSpark — open-source speculative decoding stack for DeepSeek-V4 (60–85% per-user speedup)**
  - 来源：**DeepSeek**
  - 时间：`260627`
  - 正文：~**880** tok
  - URL：https://github.com/deepseek-ai/DeepSpec
  - 类型：新产品
  - 要点：
    - **6/26–27** DeepSeek 开源 **DeepSpec**（MIT 全栈 speculative decoding 训练/评测工具链）及 **DSpark** 框架；Hugging Face 发布 V4 Pro / V4 Flash 的 DSpark 版 checkpoint（原 V4 权重 + draft 模块，非新架构）。
    - 生产实测（对比 MTP-1 baseline、吞吐不变）：V4-Flash 单用户生成 **+60–85%**、V4-Pro **+57–78%**；半自回归 draft + confidence-scheduled verification，离线 accepted length 超 Eagle3 **26–31%**。
    - 与 OpenAI Cerebras **750 tok/s** 硬件路线对照：DSpark 走** commodity GPU 算法加速**开源路线——agent 长循环推理成本显著下降。

### 新模式

- **Generation + durable tier naming — Sol/Terra/Luna decouple capability from version number (GPT-5.6)**
  - 来源：**OpenAI**
  - 时间：`260626`
  - 正文：~**520** tok
  - URL：https://openai.com/index/previewing-gpt-5-6-sol/
  - 类型：新模式
  - 要点：
    - GPT-5.6 引入新命名范式：**数字**（5.6）标识代际，**Sol/Terra/Luna** 标识可独立迭代的持久能力档位——告别 nano/mini 尺寸命名，转向用例导向分层。
    - 各 tier 可按自身节奏升级而无需 bump 代际号；开发者按 intelligence/speed/cost 三轴选型而非参数量猜测。
    - 标志 frontier 产品线从「版本号=型号」转向「代际+档位」——类似云实例族（compute-optimized vs memory-optimized）的 LLM 化。

- **Ultra subagent orchestration — beyond single-agent reasoning in frontier models**
  - 来源：**OpenAI**
  - 时间：`260626`
  - 正文：~**480** tok
  - URL：https://openai.com/index/previewing-gpt-5-6-sol/
  - 类型：新模式
  - 要点：
    - GPT-5.6 Sol 新增 **`ultra`** 模式：超越单 agent 的 **`max`** reasoning，自动调度 **subagent** 并行加速复杂任务（coding/security/biology 长程工作流）。
    - 与 `max`（单 agent 深度推理）形成两级控制：`max` = 时间换质量，`ultra` = 多 agent 换吞吐与并行探索。
    - 标志 frontier API 从「调 temperature/reasoning effort」进化到**显式多 agent 编排开关**——厂商将 agent-of-agents 内建为产品能力。

- **Government-gated staggered frontier release — vetted-partner preview before GA (GPT-5.6)**
  - 来源：**TC**
  - 时间：`260626`
  - 正文：~**620** tok
  - URL：https://techcrunch.com/2026/06/26/openai-unveils-gpt-5-6-sol-terra-and-luna-models-but-only-accessible-to-limited-preview-partners-for-now-per-us-gov/
  - 类型：新模式
  - 要点：
    - **6/26** 特朗普 **6/2** 网络安全行政令后，OpenAI 接受「约 **20** 家可信伙伴预览 + 政府逐客户知情」而非即时全球 GA——较 Anthropic Fable/Mythos 全球下架更温和但仍创先例。
    - OpenAI 在官方稿中公开反对此流程长期化，称将阻碍 cyber defender 与全球伙伴获取工具；短期配合以换取数周内 broader availability。
    - 对 VibeCoding：前沿 coding 模型空窗期（Fable 5 下架 + GPT-5.6 受限预览）拉长，开发者短期更依赖 Opus 4.8、开源 Kimi K2.7 Code/Ornith 路线。

- **Asymmetric cyber-model re-access — Mythos 5 restored, Fable 5 still blocked under export controls**
  - 来源：**POLITICO**
  - 时间：`260626`
  - 正文：~**560** tok
  - URL：https://www.politico.com/news/2026/06/26/white-house-makes-peace-with-anthropic-for-now-00965675
  - 类型：新模式
  - 要点：
    - **6/26** 白宫部分撤销 Anthropic export ban：**Mythos 5** 恢复 **100+** 已批准美企/机构访问，但 **Fable 5**（面向更广泛开发者/消费者的 cyber 能力档）仍全面禁运——「最强档先放、普及档后议」的分级恢复模式。
    - 与 OpenAI 同日 **GPT-5.6** 政府门控预览形成双厂商对齐：frontier cyber 模型发布默认附带**政府逐客户许可 + 非对称 tier 恢复**。
    - VibeCoding 影响：general-purpose cyber coding（Fable 5）持续不可用，agent 开发者需转向 Mythos 受限渠道、GPT-5.6 预览名单或开源/亚太替代（Sakana Fugu、360 屠龙峰等）。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
