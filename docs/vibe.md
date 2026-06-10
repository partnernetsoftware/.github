# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260608 07:00` UTC → `260610 07:00` UTC（48h，cron 触发 `2026-06-10T07:00Z`） |
| 本文件更新 | `260610 07:00` UTC |
| 条目数 | 13 |
| 新模型 / 新产品 / 新模式 | 13（新模型 5 · 新产品 3 · 新模式 5） |
| main 合并 commit | `待推送后填写` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Introducing Claude Fable 5 and Claude Mythos 5**
  - 来源：**Anthropic**
  - 时间：`260609`
  - 正文：~**880** tok
  - URL：https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5
  - 类型：新模型
  - 要点：
    - **Claude Fable 5**（`claude-fable-5`）：Anthropic 迄今最强公开发布模型，Mythos 级；**1M** 上下文、**128k** 输出；**$10/$50** per M input/output tokens。
    - 内置安全分类器，高风险域（网络安全/生物/化学等）返回 `stop_reason: "refusal"` 并 fallback 至 **Opus 4.8**；**Claude Mythos 5** 同权重无分类器，限 **Project Glasswing** 审批客户。
    - 6/9 GA：Claude API、AWS Bedrock、Vertex AI、Microsoft Foundry；订阅用户至 **6/22** 免费试用后转用量计费。

- **Fluid, natural voice translation with Gemini 3.5 Live Translate**
  - 来源：**Google**
  - 时间：`260609`
  - 正文：~**820** tok
  - URL：https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-live-3-5-translate/
  - 类型：新模型
  - 要点：
    - **Gemini 3.5 Live Translate**：最新音频模型，**70+** 语言近实时 speech-to-speech 翻译，保留语调/节奏/音高；连续生成而非回合制。
    - 开发者：**Gemini Live API** + Google AI Studio 公测预览；企业 **Google Meet** 本月私测；消费者 **Google Translate** Android/iOS 全球 rollout。
    - 支持 **listening mode**（Android 听筒直出翻译）；输出音频带 **SynthID** 水印；合作伙伴含 Grab（月 **1000 万+** 司机乘客语音通话场景）。

- **Introducing North Mini Code: Cohere's first model for developers**
  - 来源：**Cohere**
  - 时间：`260609`
  - 正文：~**900** tok
  - URL：https://cohere.com/blog/north-mini-code
  - 类型：新模型
  - 要点：
    - **North Mini Code 1.0**：**30B** MoE（**3B** active/token），**256K** 上下文、**64K** 最大生成；**Apache 2.0** 开源，最低 **1×H100 @ FP8** 可跑。
    - 面向 agentic 软件工程：子代理编排、架构映射、code review、终端任务；Artificial Analysis Coding Index **33.4**。
    - 渠道：Hugging Face（BF16/FP8）、Cohere API、Model Vault、OpenRouter；针对 **OpenCode** 优化，兼容主流 coding agent harness。

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

- **Sedai Launches the First Autonomous Platform for AI Agent Optimization**
  - 来源：**Sedai**
  - 时间：`260609`
  - 正文：~**760** tok
  - URL：https://www.prnewswire.com/news-releases/sedai-launches-the-first-autonomous-platform-for-ai-agent-optimization-302792208.html
  - 类型：新产品
  - 要点：
    - **AI Agent Optimization**：自治优化 agent 成本/性能/准确率；透明插入 agent 与 LLM 提供商之间，无需大改现有代码。
    - 四层能力：**Governance**（组织/项目级模型访问控制 + 跨提供商 fallback）、**Observability**（全提供商 token/延迟/成本统一视图）、**Smart Routing**（按生产流量自动选模型）、**Reliability**（重试/负载均衡内置）。
    - 即日 **early access**；首发支持 OpenAI、AWS Bedrock、Vertex AI、Azure Foundry；客户含 GSK、KnowBe4、Informed。

- **Claude Managed Agents: scheduled deployments and vault environment variables**
  - 来源：**Anthropic**
  - 时间：`260609`
  - 正文：~**720** tok
  - URL：https://platform.claude.com/docs/en/managed-agents/scheduled-deployments
  - 类型：新产品
  - 要点：
    - **Scheduled deployments**（公测）：POSIX cron + IANA 时区定义 agent 定时任务，每次触发自动开新 session，无需自建 scheduler；支持 pause/resume/archive/手动 trigger。
    - **Vault environment variables**：在沙箱边界安全注入 API key/CLI 凭证，agent 不直接读取密钥；配合 MCP/CLI 工具访问外部系统。
    - 与既有 Managed Agents harness（沙箱、持久化文件系统、多轮 session、SSE 流）叠加，面向夜间同步、周度合规扫描等 recurring agent 工作负载。

### 新模式

- **Mythos-class public release with classifier fallbacks（分级护栏下的前沿公开化）**
  - 来源：**Anthropic**
  - 时间：`260609`
  - 正文：~**560** tok
  - URL：https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5
  - 类型：新模式
  - 要点：
    - 同一 Mythos 级权重拆为 **Fable**（分类器开启，GA）与 **Mythos**（部分护栏解除，Glasswing 限发）两条产品线，用 guardrails 而非降能力换公开。
    - 拒绝请求返回 HTTP 200 + `stop_reason: "refusal"`（非错误）；支持 server-side `fallbacks` 或 SDK middleware 自动切换 Opus 4.8。
    - 代表「前沿能力公开化」新范式：能力不降级，通过运行时分类器 + 计费 fallback credit 管理风险与成本。

- **Continuous speech-to-speech translation（连续流式语音翻译范式）**
  - 来源：**Google**
  - 时间：`260609`
  - 正文：~**520** tok
  - URL：https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-live-3-5-translate/
  - 类型：新模式
  - 要点：
    - 从「等说话人结束再翻译」转向**边听边译**连续音频生成，在上下文质量与实时性之间动态平衡，全程仅落后说话人数秒。
    - **2000+** 语言组合单会议内互译（Meet），打破此前仅 5 语言、仅与英语互译的限制。
    - 开发者通过 LiveKit/Pipecat/Agora 等伙伴栈接入 **Gemini Live API**，媒体流基础设施与翻译模型解耦，降低实时多语言 agent 应用搭建门槛。

- **OpenEnv committee governance for agentic RL（开源 agent 训练互操作层）**
  - 来源：**HF**
  - 时间：`260608`
  - 正文：~**680** tok
  - URL：https://huggingface.co/blog/openenv-agentic-rl
  - 类型：新模式
  - 要点：
    - **OpenEnv** 迁入 `huggingface/OpenEnv`，由 Meta-PyTorch、NVIDIA、Unsloth、Modal、Prime Intellect、Hugging Face 等组成的委员会协调治理。
    - 定位 **protocol layer**（Gymnasium API + HTTP/WebSocket + MCP 一等公民），不规定 reward 定义或训练循环；trainer 与 env 库可插拔互操作。
    - 对标闭源「模型–harness 手套式」共训：让开源模型也能针对特定 harness 高效 RL 训练，缩小与 GPT-5.5/Opus 4.8 的 harness 专化差距。

- **Sovereign open coding model vs managed frontier（自托管开源 vs 托管前沿的双轨架构决策）**
  - 来源：**Cohere**
  - 时间：`260609`
  - 正文：~**540** tok
  - URL：https://cohere.com/blog/north-mini-code
  - 类型：新模式
  - 要点：
    - **North Mini Code**（单 H100、Apache 2.0）与 **Claude Fable 5**（$50/M output、托管 API）同日发布，形成鲜明对照：数据驻留/成本可控 vs 前沿智能/零运维。
    - 开源 MoE 强调 **2.8×** 吞吐与 **30%** 更低 inter-token 延迟，但 verbosity 更高（输出 token 约为同类 **3×**），高量产线需建模 hidden token 成本。
    - agentic coding 基础设施选型从「选最强模型」转向「自托管开源 + 主权部署」与「托管前沿 API」的双轨并行，按合规/量级/任务难度分流。

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

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
