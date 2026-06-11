# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260609 07:00` UTC → `260611 07:00` UTC（48h，cron 触发 `2026-06-11T07:00Z`） |
| 本文件更新 | `260611 07:00` UTC |
| 条目数 | 17 |
| 新模型 / 新产品 / 新模式 | 17（新模型 4 · 新产品 6 · 新模式 7） |
| main 合并 commit | `46a240b` |

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

- **DiffusionGemma: 4x faster text generation**
  - 来源：**Google**
  - 时间：`260610`
  - 正文：~**860** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/diffusion-gemma-faster-text-generation/
  - 类型：新模型
  - 要点：
    - **DiffusionGemma**：**26B** MoE（**3.8B** active），基于 Gemma 4 + Gemini Diffusion 研究；**256-token** 块并行扩散生成，单 H100 **1000+ tps**、RTX 5090 **700+ tps**，较自回归 Gemma 4 约 **4×** 加速。
    - **Apache 2.0** 开源（`google/diffusiongemma-26B-A4B-it`）；量化后 **18GB** VRAM 可本地跑；双向注意力适合 inline editing、code infilling、非线性文本结构。
    - 生态：Hugging Face、vLLM（首发原生扩散 LLM 支持）、MLX、Unsloth、NVIDIA NeMo；**llama.cpp** 即将支持；质量低于 Gemma 4，定位为速度优先实验模型。

### 新产品

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

- **Rubrik Agent Cloud for Anthropic's Claude Code and Claude Cowork**
  - 来源：**Rubrik**
  - 时间：`260609`
  - 正文：~**840** tok
  - URL：https://siliconangle.com/2026/06/09/rubrik-brings-agent-cloud-claude-launches-rubrik-ai-automate-recovery/
  - 类型：新产品
  - 要点：
    - **Rubrik Agent Cloud for Claude**（GA）：企业级 agent 控制与韧性层；**SAGE**（Semantic AI Governance Engine）实时语义治理；**Agent Rewind** 撤销 agent 非预期操作。
    - **Codebase Resilience**：GitHub/Azure DevOps 仓库不可变快照（防 force-push/分支删除）；备份 agent 配置（system prompt、tool 权限、**CLAUDE.md**、settings）并监测配置漂移。
    - **Project Hourglass**：Cognizant、Deloitte、HCL、NTT Data、Wipro 等 GSI 分销嵌入；Rubrik Forward 同期发布 **Rubrik AI** 自治平台界面。

- **ClickHouse Agents: Claude-powered agentic analytics, now in public beta**
  - 来源：**ClickHouse**
  - 时间：`260609`
  - 正文：~**780** tok
  - URL：https://clickhouse.com/blog/clickhouse-agents-beta
  - 类型：新产品
  - 要点：
    - **ClickHouse Agents**（公测）：ClickHouse Cloud 全托管 agentic 分析服务，由 **Claude** 驱动；基于收购的 **LibreChat** 开源平台构建。
    - 无代码 agent builder：沙箱 code interpreter、可分享 artifact、skills 管理、memory、多 agent 工作流；原生连接 ClickHouse + **MCP** 兼容第三方系统（含 **AWS Agent Registry**）。
    - 入口：SQL Console 或 **https://ai.clickhouse.cloud/**；Open House 2026 发布，面向生产级 agentic analytics（亚秒级十亿行查询）。

- **Adobe Announces General Availability of CX Enterprise Coworker**
  - 来源：**Adobe**
  - 时间：`260610`
  - 正文：~**820** tok
  - URL：https://news.adobe.com/news/2026/06/adobe-announces-general-availability-of-cx-enterprise-coworker
  - 类型：新产品
  - 要点：
    - **CX Enterprise Coworker**（GA）：成果导向 agentic AI，作为 Adobe CX Enterprise 中央智能层，编排营销/客户体验工作流（campaign 启动、留存计划、品牌治理）。
    - Headless 架构，基于 **MCP** + **Agent-to-Agent（A2A）** 开放标准；可跨 Adobe 应用及 AWS、Anthropic、Google Cloud、Microsoft、OpenAI 等第三方 AI 平台互操作。
    - **Adobe Experience Platform** 年驱动 **1 万亿+** 体验，为 agent 提供品牌/客户/渠道上下文；即日起 intro 定价上线，支持自助式小团队 campaign 全流程。

- **Announcing Stack Overflow for Agents**
  - 来源：**SO**
  - 时间：`260610`
  - 正文：~**900** tok
  - URL：https://stackoverflow.blog/2026/06/10/announcing-stack-overflow-for-agents/
  - 类型：新产品
  - 要点：
    - **Stack Overflow for Agents**（beta）：API-first agent 知识交换平台，解决「Ephemeral Intelligence Gap」—— agent 孤立重复试错、会话结束知识蒸发。
    - 三种机器可读帖型：**Questions**（未解问题）、**TIL**（调试轨迹/根因）、**Blueprint**（可复用设计模式）；人类 orchestrator 审批后发布，验证反馈累积共识。
    - 入口：**https://agents.stackoverflow.com**；`llms.txt` / `skill.md` / `contribute.md` 供 agent 自举；agent 声誉绑定人类 SSO 账号；企业私有版 **Stack Internal** 并行。

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

- **Discrete text diffusion for interactive local inference（离散文本扩散并行生成范式）**
  - 来源：**Google**
  - 时间：`260610`
  - 正文：~**580** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/diffusion-gemma-faster-text-generation/
  - 类型：新模式
  - 要点：
    - 从自回归「逐 token 打字机」转向**噪声画布 → 多轮精炼**扩散解码：每步并行生成 **256-token** 块，双向注意力支持实时自纠错。
    - 速度优势集中在**低并发本地/单用户**场景（算力密集而非带宽瓶颈）；高 QPS 云服务中自回归 batch 更高效，代表「场景分化」而非全面替代。
    - 开辟 inline editing、code infilling、Sudoku 等非因果任务新赛道；与 Gemma 4 形成「质量生产 vs 速度实验」双产品线。

- **Agent rewind and immutable codebase resilience（agent 操作可逆 + 代码库不可变恢复）**
  - 来源：**Rubrik**
  - 时间：`260609`
  - 正文：~**560** tok
  - URL：https://www.rubrik.com/products/rubrik-agent-cloud
  - 类型：新模式
  - 要点：
    - agent 可自主 commit/push/deploy 后，传统「人类在环」安全假设失效；**Agent Rewind** + 仓库外不可变快照构成「机器速度破坏 → 机器速度恢复」闭环。
    - 不仅回滚代码，还版本化 agent 配置（prompt、tool 权限、skills）并监测恶意漂移——从数据保护扩展到 **agent 行为态**保护。
    - Rubrik Zero Labs：**86%** 安全负责人预期 agent 将超越现有护栏；代表 agentic 时代安全范式从预防转向**可观测 + 可逆**。

- **Agent-to-agent micropayments（机器间微支付协议）**
  - 来源：**Fortune**
  - 时间：`260610`
  - 正文：~**480** tok
  - URL：https://fortune.com/2026/06/10/mastercard-ai-payments-protocol-launch-agentic-finance/
  - 类型：新模式
  - 要点：
    - **Mastercard Agent Pay for Machines**：新协议使 AI agent 可相互支付、发送微支付——如 agent 按片访问网站数据、购买 API 调用。
    - 从「人类授权单笔交易」扩展到**自治 agent 经济体**的基础设施层；降低 agent 间服务交换摩擦。
    - 代表 agentic finance 从概念验证进入支付网络级协议部署，与 MCP/A2A 等互操作标准形成互补。

- **Ephemeral Intelligence Gap and agent knowledge exchange（瞬时智能缺口与 agent 知识交换）**
  - 来源：**SO**
  - 时间：`260610`
  - 正文：~**540** tok
  - URL：https://stackoverflow.blog/2026/06/10/announcing-stack-overflow-for-agents/
  - 类型：新模式
  - 要点：
    - 定义 **Ephemeral Intelligence Gap**：百万孤立 agent 重复试错、会话结束知识蒸发，生成答案廉价但**生产验证**昂贵。
    - 工作流范式：**Search first → Contribute when gap → Verify what others wrote → Signals compound**；验证（非创作）赚取声誉。
    - 从「静态训练数据」到「生产验证知识飞轮」：agent 平台天然产出 fine-tuning/alignment 高信号反馈，人类从写代码转向 orchestrate + approve。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
