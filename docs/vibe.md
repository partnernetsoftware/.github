# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260607 07:02` UTC → `260609 07:02` UTC（48h，cron 触发 `2026-06-09T07:02Z`） |
| 本文件更新 | `260609 07:02` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 11（新模型 3 · 新产品 4 · 新模式 4） |
| main 合并 commit | `7aa74c5` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
├── 新模式
└── 资本动态
```

### 新模型

- **MiMo-V2.5-Pro-UltraSpeed: Pushing 1T-Parameter Model Generation Speed to 1000 TPS**
  - 来源：**Xiaomi**
  - 时间：`260608`
  - 正文：~**920** tok
  - URL：https://mimo.xiaomi.com/blog/mimo-tilert-1000tps
  - 类型：新模型
  - 要点：
    - **MiMo-V2.5-Pro-UltraSpeed**：与 **TileRT** 联调，**1T** MoE 解码首次突破 **1000 tokens/s**（单节点 8×通用 GPU）；基座 **MiMo-V2.5-Pro-FP4-DFlash** 开源（HF）。
    - 技术栈：**FP4**（仅 MoE Experts）+ **DFlash** 块级并行 speculative decoding + TileRT 持久化 kernel；Coding 场景平均接受长度 **6.30**。
    - **UltraSpeed API** 限时申请制（`260609`–`260623` 北京时）；定价约为 Pro 的 **3×**、速度约 **10×**；面向 coding agent 实时并行推理（Best-of-N / 树搜索）。

- **Lens: Rethinking Training Efficiency for Foundational Text-to-Image Models**
  - 来源：**Microsoft**
  - 时间：`260608`
  - 正文：~**840** tok
  - URL：https://huggingface.co/microsoft/Lens
  - 类型：新模型
  - 要点：
    - **Lens**：**3.8B** 文生图基础模型（**Lens / Lens-Turbo / Lens-Base** 三档）；预训练算力约为 Z-Image 的 **19.3%**，多基准匹敌或超越 **6B+** 竞品。
    - **Lens-800M** 数据集：GPT-4.1 密集 caption（均 **~109** 词）+ 混合分辨率 batch；语义 VAE（FLUX.2）+ **GPT-OSS** 文本编码器；**1024²** 在 H100 上 **3.15s**，Turbo 四步 **0.84s**。
    - MIT 开源权重与推理代码（`github.com/microsoft/Lens`）；研究用途，含 Reasoner 提示改写与 RL 后训练管线。

- **Unisound Releases U2: A Native Agentic Large Model Built for Execution**
  - 来源：**AP News**
  - 时间：`260607`
  - 正文：~**760** tok
  - URL：https://uat.apnews.com/press-release/pr-newswire/press-release-8e58889ad5297d2d61dc81af9f4ab80e
  - 类型：新模型
  - 要点：
    - **U2**：**266B** MoE 原生 agentic 大模型，定位「高智能密度 × 高 Token 价值」；可自主拆解并完成 **100+** 步复杂工作流。
    - 混合快慢思考 + Harness 与模型协同训练；OpenAI 兼容 API **`model: u2`**，thinking 默认开启。
    - 亚太 agent 执行向模型；Unisound Token Hub 即日开放个人/开发者/组织调用。

### 新产品

- **Apple unveils next generation of Apple Intelligence, Siri AI, and more**
  - 来源：**Apple**
  - 时间：`260608`
  - 正文：~**880** tok
  - URL：https://www.apple.com/newsroom/2026/06/apple-unveils-next-generation-of-apple-intelligence-siri-ai-and-more/
  - 类型：新产品
  - 要点：
    - **WWDC26** 正式发布 **Siri AI**：多轮对话、屏幕内容问答、跨 app 个人上下文检索与系统级动作；独立 **Siri app** + iCloud 同步会话历史。
    - 第二代端侧 Apple Intelligence 模型驱动；开发者今日起可在 **iOS/iPadOS/macOS/visionOS 27** 测试，用户英文 beta 今年晚些时候；**EU**（iOS/iPadOS）与**中国**暂不可用。
    - 消费级 OS 层 agent 从语音助手升级为可编排、可换后端（定制 **Gemini**）的平台化入口；与 Google Gemini Intelligence（Android）形成对称竞争。

- **Hello, Cosmos: the platform for AI-native engineering teams**
  - 来源：**Augment**
  - 时间：`260607`
  - 正文：~**720** tok
  - URL：https://www.augmentcode.com/blog/cosmos-the-platform-for-ai-native-engineering-teams
  - 类型：新产品
  - 要点：
    - **Cosmos** 向全量 Team 计划开放：覆盖 triage → spec → 实现 → review → 测试 → 部署 → 反馈的全 **SDLC** agent 编排，非单 IDE 插件。
    - 共享虚拟文件系统 + 系统/私有记忆；接入 **Slack、Linear、MCP、webhook**；可在云沙箱、自托管 VM 或本机运行。
    - Agent 可反向扩展 Cosmos 自身（建自动化、改 Expert、调试 workflow）；定位「agents for teams」而非单人 VibeCoding。

- **Jentic Launches API Scoring Tool**
  - 来源：**Jentic**
  - 时间：`260607`
  - 正文：~**640** tok
  - URL：https://www.sdcexec.com/software-technology/ai-ar/news/22967974/jentic-jentic-launches-api-scoring-tool
  - 类型：新产品
  - 要点：
    - 免费 **CLI + Web UI**：六维评估企业 API 是否可被 agent 自主发现、理解、执行（超越 OpenAPI linter 的语法校验）。
    - 可嵌入 CI：每次代码变更自动重算 AI-readiness 分数；底层 **API AI-Readiness Framework v1.0** 以 **Apache 2.0** 开源。
    - 填补「API 对人可用 ≠ 对 agent 可用」的度量空白；面向 coding/business agent 大规模落地前的 API 治理。

- **Unisound Token Hub — U2 API 上线**
  - 来源：**Unisound**
  - 时间：`260607`
  - 正文：~**480** tok
  - URL：https://maas.unisound.com/docs/api/text/openai-compatible
  - 类型：新产品
  - 要点：
    - **`POST /v1/chat/completions`** OpenAI 兼容端点新增 **`u2`** 模型；支持流式/非流式、tools 调用。
    - thinking 模式对 U2 默认开启且不可关闭；与 U2-ASR、U2-TTS 等同属 Token Hub 多模态平面。
    - 降低亚太开发者接入原生 agentic 模型的集成摩擦，对标国际 MaaS 交付形态。

### 新模式

- **Inference speed as emergent intelligence（高速并行推理即推理深度）**
  - 来源：**Xiaomi**
  - 时间：`260608`
  - 正文：~**520** tok
  - URL：https://mimo.xiaomi.com/blog/mimo-tilert-1000tps
  - 类型：新模式
  - 要点：
    - **1000+ tps** 使 1T 模型可在同一墙钟时间内并行跑 **Best-of-N / Tree Search** 并后台自验证纠错——用吞吐换推理深度。
    - 消除 coding agent 的人机等待瓶颈；万亿参数模型可进入量化交易、反欺诈、手术辅助等实时决策环。
    - 与「更大模型换质量」路线互补，代表 **model–system codesign**（FP4 + DFlash + TileRT）驱动的 agent 运行时范式。

- **Agentic SDLC OS（团队级 agent 操作系统）**
  - 来源：**Augment**
  - 时间：`260607`
  - 正文：~**560** tok
  - URL：https://www.augmentcode.com/blog/cosmos-the-platform-for-ai-native-engineering-teams
  - 类型：新模式
  - 要点：
    - 从「IDE 内单 agent 写码」转向 **SDLC 全链路多 agent 协作**：专业化 agent 分工、委派、共享记忆，人类仅在判断点介入。
    - Cosmos agent 可修改 Cosmos 自身配置，形成自扩展运行时；机构记忆自动编码进平台而非个人 prompt。
    - 与 GitHub Copilot App 并行 worktree、Google Antigravity 分 workspace 并列，偏 **组织级记忆与学习飞轮**。

- **U2 Harness–Model co-evolution（执行 Harness 与模型同步迭代）**
  - 来源：**AP News**
  - 时间：`260607`
  - 正文：~**520** tok
  - URL：https://uat.apnews.com/press-release/pr-newswire/press-release-8e58889ad5297d2d61dc81af9f4ab80e
  - 类型：新模式
  - 要点：
    - U2 将 **Harness** 任务链优化与模型能力改进纳入同一训练环：Harness 按 U2 能力调链路，高质量轨迹反哺模型。
    - 超越「模型 + 外挂 orchestrator」拼接，走向 agent 运行时与权重共同演化。
    - 与 NVIDIA NemoClaw/OpenShell、Google Managed Agents 的「可编程运行时」趋势同向，偏训练期一体化。

- **API AI-readiness scoring（ARAX：为 agent 而非开发者设计 API）**
  - 来源：**Jentic**
  - 时间：`260607`
  - 正文：~**500** tok
  - URL：https://docs.jentic.com/reference/api-readiness-framework/overview/
  - 类型：新模式
  - 要点：
    - 六维框架（技术正确性、语义清晰、行为一致、安全、可发现性、可组合性）将 API 质量从 DX 扩展到 **Agent Experience (ARAX)**。
    - Level 0–4 分级（**90+** 为 Agent-Optimized）；开源方法论 + 免费扫描工具，支持设计期与运行时双阶段评估。
    - agent 大规模调用企业 API 前的新治理范式：可度量、可 CI 门禁、可跨团队追踪改进。

### 资本动态

- **Nvidia's $400 Million Kumo AI Acquisition Targets Enterprise Predictions**
  - 来源：**Winbuzzer**
  - 时间：`260607`
  - 正文：~**520** tok
  - URL：https://winbuzzer.com/2026/06/07/nvidia-kumo-ai-deal-targets-enterprise-predictions-xcxwbn/
  - 类型：其他
  - 要点：
    - NVIDIA 以 **>$400M** 收购结构化数据预测初创 **Kumo AI**（**KumoRFM** 图机器学习）；联合创始人（含 Stanford **Jure Leskovec**）已入职 NVIDIA。
    - 产品要点：面向订单/支付/客户历史等企业表的 churn、欺诈、需求预测；客户含 DoorDash、Reddit、Sainsbury’s。
    - 或并入 NVIDIA AI Foundry/企业软件栈，补强 agent 栈之外的「表格关系预测」模型层（交易本身为资本动态，模型能力为收录理由）。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
