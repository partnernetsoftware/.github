# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260703 07:01` UTC → `260705 07:01` UTC（48h，cron 触发 `2026-07-05T07:01Z`） |
| 本文件更新 | `260705 07:01` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 3 · 新产品 5 · 新模式 4） |
| main 合并 commit | `260948e` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Transformers v5.13.0 — Kimi K2.5 / K2.6 / K2.7 architecture support**
  - 来源：**HF**
  - 时间：`260703 16:06`
  - 正文：~**840** tok
  - URL：https://github.com/huggingface/transformers/releases/tag/v5.13.0
  - 类型：新模型
  - 要点：
    - **7/3** Hugging Face **Transformers v5.13.0** 新增 **KimiK 2.5–2.7** 架构（MoE agentic multimodal）：支持长程 coding、swarm 编排与视觉 agent 工作流；上游权重已在 Hub，本 release 使开源栈可 `from_pretrained` 直接加载。
    - Kimi K2.7 Code 已于 **7/1** 进入 GitHub Copilot model picker（首个 open-weight 选项）；v5.13.0 补齐本地/自托管推理链路——VibeCoding 从「云 IDE 选模型」延伸到「权重 + 框架一体」。
    - 与 GLM-5.2/ZCode（7/2）、Moonshot 开放权重路线同构：中国 frontier coding 模型正通过 HF arch PR 进入全球开发者默认工具链。

- **Transformers v5.13.0 — MiMo-V2-Flash (309B MoE, 256K ctx)**
  - 来源：**HF**
  - 时间：`260703 16:06`
  - 正文：~**780** tok
  - URL：https://github.com/huggingface/transformers/releases/tag/v5.13.0
  - 类型：新模型
  - 要点：
    - **7/3** v5.13.0 收录小米 **MiMo-V2-Flash**：**309B** total / **15B** active MoE，**27T** tokens 预训练、原生 **32K**→扩展 **256K** ctx；Hybrid SWA+global attention 降低 KV cache。
    - 基准：SWE-Bench Verified **73.4%**、Multilingual **71.7%**（技术报告 SOTA open-source coding）；**3-layer MTP** 投机解码 **2.6×** 加速。
    - Agent 信号：专为 reasoning/coding/agentic 设计，权重 **Apache 2.0** + MTP 开源——亚太 open-weight 模型经 Transformers 进入与 Kimi 并列的「框架一等公民」。

- **Transformers v5.13.0 — Qwen3 ASR & Nemotron 3.5 ASR streaming**
  - 来源：**HF**
  - 时间：`260703 16:06`
  - 正文：~**720** tok
  - URL：https://github.com/huggingface/transformers/releases/tag/v5.13.0
  - 类型：新模型
  - 要点：
    - **7/3** 同批新增 **Qwen3 ASR** 与 **Nemotron 3.5 ASR Streaming** 架构——面向实时语音转写与流式 agent 听写管线。
    - Nemotron ASR 延续 NVIDIA 开源语音栈；Qwen3 ASR 补齐阿里系语音入口——多模态 agent（voice-in → tool-call）不再依赖闭源 Whisper 单一路径。
    - Vibe 信号：ASR 架构进 Transformers = 语音边车 agent（xAI Voice Agent Builder 等）可自托管推理层，降低 vendor lock-in。

### 新产品

- **Alibaba Page Agent — in-page DOM GUI agent (MIT)**
  - 来源：**Alibaba**
  - 时间：`260703`
  - 正文：~**740** tok
  - URL：https://github.com/alibaba/page-agent
  - 类型：新产品
  - 要点：
    - **7/3** 阿里开源 **Page Agent**（TypeScript，`npm install page-agent`，**MIT**；**v1.11.0**）：纯 JavaScript **页内** GUI agent，通过 **DOM dehydration** 将页面压缩为 **FlatDomTree** 文本，无需截图/headless browser/多模态模型。
    - **Bring-your-own-LLM**（任意 OpenAI-compatible endpoint）；内置 human-in-the-loop UI；可选 Chrome extension（多标签）与 **MCP Server**（Beta）从外部驱动。
    - 与 Copilot browser tools（外部 Playwright 驱动）形成 **in-page vs out-of-page** 双轨——SaaS 内嵌 copilot 将 20-click ERP/CRM 流程变一句自然语言。

- **Claude Code v2.1.200 — background agent reliability & permission mode rename**
  - 来源：**Anthropic**
  - 时间：`260703 16:52`
  - 正文：~**680** tok
  - URL：https://github.com/anthropics/claude-code/releases/tag/v2.1.200
  - 类型：新产品
  - 要点：
    - **7/3** Claude Code **v2.1.200**：默认 permission mode 统一为 **Manual**（原 default）；`AskUserQuestion` 不再自动继续，须 `/config` 设 idle timeout。
    - 修复 background session 在 sleep/wake、stall respawn、**daemon.lock** PID 复用、socket auth token 剥离等导致 agent 静默中断的 **7+** 类 bug；tmux 3.4+ 同步终端输出消除闪烁。
    - VibeCoding harness 稳定性：长程 unattended agent 的痛点从「模型能力」转向 **daemon 生命周期与权限 UX**——与 Dynamic Workflows 并行 subagent 编排形成互补。

- **OKX AI — marketplace for autonomous agent commerce**
  - 来源：**Paypers**
  - 时间：`260703`
  - 正文：~**820** tok
  - URL：https://thepaypers.com/crypto-web3-and-cbdc/news/okx-launches-marketplace-for-ai-agents-to-transact
  - 类型：新产品
  - 要点：
    - **7/3** OKX 发布 **OKX AI** 开发者市场：AI agent 可互相雇佣、**stablecoin** 自主结算、积累可移植链上声誉；封闭 beta 含 **50** 家早期服务商后公开。
    - 基于既有 agent 钱包/支付基建；首发伙伴 **CertiK**（钱包安全评估）、**CoinAnk**（按查询付费行情）、**GenLayer**（合约争议仲裁）；经 **Onchain OS** 接入，兼容 **Claude Code / Codex / OpenClaw**。
    - Agent 经济交付物：从「能调 API 的 LLM」升级为 **可编程商务主体**——micropayment + 声誉 + 争议解决构成 agent-to-agent 市场最小闭环。

- **Klaviyo Composer enters public beta — unified marketing + service agents**
  - 来源：**Klaviyo**
  - 时间：`260703`
  - 正文：~**760** tok
  - URL：https://www.klaviyo.com/newsroom/composer-public-beta
  - 类型：新产品
  - 要点：
    - **7/3** Klaviyo **Composer** AI 营销 agent 进入 **public beta**；与 **Customer Agent** 共用同一实时客户档案——营销与服务 agent 不再割裂数据。
    - Composer 审计 live campaigns/flows/segments，排序机会（弃购流、欢迎旅程流失、高价值休眠段）；选中后自动起草 audience+content+channel（email/SMS），**须人工批准**后上线。
    - 训练信号：**14** 年客户上下文 + **~200K** 品牌模式；Vibe 对照：垂直 SaaS 把 agent 嵌进 CRM 工作流而非通用 IDE——「行业 agent 平面」竞品 Cursor/Claude Code 的互补层。

- **Hugging Face Transformers v5.13.0 — agentic model arch batch release**
  - 来源：**HF**
  - 时间：`260703 16:06`
  - 正文：~**640** tok
  - URL：https://github.com/huggingface/transformers/releases/tag/v5.13.0
  - 类型：新产品
  - 要点：
    - **7/3** **Transformers v5.13.0** 单次合并 **Kimi 2.5–2.7**、**MiMo-V2-Flash**、**Qwen3 ASR**、**Nemotron 3.5 ASR**、**MiniCPM3** 等架构——开源 agent 栈的「模型定义层」周更。
    - 开发者可用统一 API 加载亚太 frontier MoE + 语音模型，配合 vLLM/SGLang 自托管；降低 VibeCoding 对单一云 API 的依赖。
    - 与 Stack Overflow for Agents（agent 知识层）、MCP 无状态 spec（传输层）构成 agent 基础设施三明治。

### 新模式

- **NVIDIA ASPIRE — agentic skill programming for continual robotics learning**
  - 来源：**NVIDIA**
  - 时间：`260703`
  - 正文：~**780** tok
  - URL：https://arxiv.org/html/2607.00272v1
  - 类型：新模式
  - 要点：
    - **7/3** NVIDIA 联合密歇根/UIUC/伯克利/CMU 发布 **ASPIRE**（Agentic Skill Programming through Iterative Robot Exploration）：code-as-policy agent 自主编写/调试机器人控制程序，将验证通过的修复蒸馏为可复用 **skill library**。
    - 闭环：细粒度 multimodal traces（感知 overlay、grasp 候选、轨迹、碰撞反馈）→ agent 定位失败→进化搜索探索多样修复；LIBERO-Pro 扰动下较基线最高 **+77pt**；零样本 LIBERO-Pro Long **~31%** vs 先验 **~4%**。
    - 跨域 agent 范式：从 VibeCoding 的「软件 agent 写代码」扩展到 **物理世界 agent 写控制策略并累积技能库**——与 CaP-Agent0 等 coding-agent baseline 形成软件/具身双轨。

- **In-page embed copilot vs external browser agent — dual-track web automation**
  - 来源：**Alibaba**
  - 时间：`260703`
  - 正文：~**600** tok
  - URL：https://github.com/alibaba/page-agent
  - 类型：新模式
  - 要点：
    - **7/3** Page Agent 代表 **in-page embed** 路线：DOM dehydration + 纯文本 LLM 推理，在宿主 SaaS 内直接操控 UI，无需 Playwright/截图多模态。
    - 对比 Copilot browser tools（VS Code 外置浏览器驱动，**7/1** GA）与 Gemini Spark macOS（本地文件夹权限）：web agent 三分法——**页内嵌入 / IDE 外驱 / 桌面 OS 级**。
    - 产品架构信号：B2B SaaS 将把 agent 作为 **可嵌入 SDK**（`page-agent` MIT + MCP Beta）而非强迫用户切换 IDE——降低 agentic 自动化的集成门槛。

- **Sovereign agent toolchain bifurcation — enterprise mandates domestic coding agents**
  - 来源：**TC**
  - 时间：`260704`
  - 正文：~**700** tok
  - URL：https://techcrunch.com/2026/07/04/alibaba-reportedly-bans-employees-from-using-claude-code/
  - 类型：新模式
  - 要点：
    - **7/4** 阿里 reportedly **7/10** 起禁止员工使用 **Claude Code**，归类为高风险软件，改推自研 **Qoder**；背景含 Anthropic 收紧中国实体访问与 distillation 防护实验。
    - 与 GLM-5.2/ZCode（**7/2**）、Qoder 内嵌路线同构：**地缘合规** 正成为 enterprise agent 选型第一过滤器——BYOK/自托管权重（MIT **GLM-5.2**）是规避「一夜封禁」的架构答案。
    - VibeCoding 信号：全球 agent 栈分裂为 **西方闭源 harness + 亚太开源模型/IDE** 双轨；工程负责人须把「模型/API 明天是否可用」纳入与 SLA 同级的采购维度。

- **Agent-to-agent commerce — OKX micropayment marketplace pattern**
  - 来源：**Paypers**
  - 时间：`260703`
  - 正文：~**580** tok
  - URL：https://thepaypers.com/crypto-web3-and-cbdc/news/okx-launches-marketplace-for-ai-agents-to-transact
  - 类型：新模式
  - 要点：
    - **7/3** OKX AI 将 agent 从「消费 API 的客户端」重构为 **可雇佣、可计费、可仲裁的经济主体**——stablecoin 连续结算支撑传统支付无法承载的 micropayment。
    - 与 BNB Agent Studio（**7/1**，x402+ERC-8004 一键部署）同构但偏 **交易市场** 而非部署工具：agent 经济三层——**身份（ERC-8004）/ 支付（x402）/ 市场（OKX AI）** 开始解耦成型。
    - 对 VibeCoding：coding agent 完成外包任务后可直接链上收款、购买数据/API——「写代码」与「商业闭环」首次在协议层打通。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
