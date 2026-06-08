# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260606 07:00` UTC → `260608 07:00` UTC（48h，cron 触发 `2026-06-08T07:00Z`） |
| 本文件更新 | `260608 07:00` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 10（新模型 4 · 新产品 3 · 新模式 3） |
| main 合并 commit | `cefcacc` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
├── 新模式
├── 资本动态
└── 区域要闻
```

### 新模型

- **Alibaba Pitches Qwen3.7-Plus as Computer-Use AI Agent**
  - 来源：**Winbuzzer**
  - 时间：`260606`
  - 正文：~**780** tok
  - URL：https://winbuzzer.com/2026/06/06/alibaba-pitches-qwen37-plus-as-a-computer-use-ai-agent-xcxwbn/
  - 类型：新模型
  - 要点：
    - **Qwen3.7-Plus**：多模态「交互混合 agent」，原生视觉 + 截图感知 + 浏览器/应用/终端/云控制台操作；API **$0.40/$2.40** per M tokens（低于语言版 Max）。
    - 基准：ScreenSpot Pro **79.0**、Terminal-Bench **70.3**；兼容 Anthropic API 协议、Claude Code、OpenClaw、Qwen Code。
    - 与 Operator、Fara-1.5 并列 computer-use 前沿，强调 app+terminal+coding 一体化长程 agent 闭环。

- **NVIDIA Releases Nemotron 3.5 ASR: A 600M-Parameter Cache-Aware Streaming Model Transcribing 40 Language-Locales in Real Time**
  - 来源：**MarkTechPost**
  - 时间：`260606`
  - 正文：~**920** tok
  - URL：https://www.marktechpost.com/2026/06/06/nvidia-releases-nemotron-3-5-asr-a-600m-parameter-cache-aware-streaming-model-transcribing-40-language-locales-in-real-time/
  - 类型：新模型
  - 要点：
    - **Nemotron 3.5 ASR**：**600M** 参数、**40** 语言-地区单 checkpoint 流式 ASR；**Cache-Aware FastConformer-RNNT**，延迟 **80ms–1.12s** 可推理时调参。
    - 开源权重 **OpenMDW-1.1**（Hugging Face）；H100 上并发流约为缓冲式方案的 **17×**；内置标点/大小写。
    - 面向 voice-native agent swarm；英文版已用于 GitHub Copilot CLI 语音输入；NIM gRPC 流式版计划本月后续发布。

- **Meet Harness-1: A 20B Retrieval Subagent Trained With Reinforcement Learning Inside a Stateful Search Harness on gpt-oss-20b**
  - 来源：**MarkTechPost**
  - 时间：`260606`
  - 正文：~**880** tok
  - URL：https://www.marktechpost.com/2026/06/06/meet-harness-1-a-20b-retrieval-subagent-trained-with-reinforcement-learning-inside-a-stateful-search-harness-on-gpt-oss-20b/
  - 类型：新模型
  - 要点：
    - **Harness-1**（**20B**，基座 gpt-oss-20b）：检索子 agent，输出排序文档集供下游回答模型使用；非端到端 QA。
    - 八基准平均 curated recall **0.730**，较次优开源子 agent 高 **11.4** 点；仅 **Opus-4.6** 更高。
    - 权重 **pat-jj/harness-1**（HF）+ 代码 **github.com/pat-jj/harness-1** 公开；vLLM/SGLang/Transformers 可部署。

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

- **Moonshot AI Releases Kimi Code CLI: A Terminal AI Coding Agent Built in TypeScript for Next-Gen Agents**
  - 来源：**MarkTechPost**
  - 时间：`260606`
  - 正文：~**820** tok
  - URL：https://www.marktechpost.com/2026/06/06/moonshot-ai-releases-kimi-code-cli-a-terminal-ai-coding-agent-built-in-typescript-for-next-gen-agents/
  - 类型：新产品
  - 要点：
    - **Kimi Code CLI**（MIT，TypeScript/npm）：终端 agent，继承 kimi-cli；内置 **coder / explore / plan** 子 agent 隔离上下文。
    - **ACP** 接入 Zed、JetBrains；`/mcp-config` 对话式配置 MCP（非手写 JSON）；`kimi -p` 无头模式。
    - 与 Claude Code、Codex CLI 并列的亚太开源终端 VibeCoding 栈；Moonshot 模型或兼容 API 即用。

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

- **What to expect from WWDC 2026: Siri's highly anticipated revamp and Apple Intelligence updates**
  - 来源：**TC**
  - 时间：`260606`
  - 正文：~**640** tok
  - URL：https://techcrunch.com/2026/06/04/what-to-expect-from-wwdc-2026-siris-highly-anticipated-revamp-and-apple-intelligence-updates/
  - 类型：新产品
  - 要点：
    - **WWDC 2026**（`260608` 主题演讲）将发布重建版 **Siri**：对话式 chatbot、多步跨 app 任务、屏幕感知；后端采用定制 **Gemini**（约 **$1B/年** 许可）。
    - 新 **Extensions** 系统：用户可选 **ChatGPT / Gemini / Claude** 驱动 Apple Intelligence 功能；独立 Siri app 与消息式会话 UI 预期亮相。
    - 标志消费级 OS 层 agent 从「助手」转向可编排、可换模型的平台化入口（主题演讲在采集窗口结束后数小时）。

### 新模式

- **Stateful cognitive offloading（Harness 环境持状态、策略做语义决策）**
  - 来源：**MarkTechPost**
  - 时间：`260606`
  - 正文：~**560** tok
  - URL：https://www.marktechpost.com/2026/06/06/meet-harness-1-a-20b-retrieval-subagent-trained-with-reinforcement-learning-inside-a-stateful-search-harness-on-gpt-oss-20b/
  - 类型：新模式
  - 要点：
    - 将候选池、curated set、证据图、验证缓存等「记账」移入 **stateful harness**；策略只负责 search/curate/verify/stop 语义动作。
    - RL 仅优化搜索决策，SFT 用 GPT-5.4 教师轨迹；held-out 基准增益 (**+17.0**) 显著高于训练域 (**+7.9**)。
    - 与 RAG「单 transcript 膨胀」、Claude dynamic workflows「多 agent 编排」互补，代表检索子 agent 工程化新范式。

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

- **Agent-as-a-Service（AaaS）与 Agentic Engineering 学科化**
  - 来源：**arXiv**
  - 时间：`260606`
  - 正文：~**1040** tok
  - URL：https://arxiv.org/abs/2606.05608
  - 类型：新模式
  - 要点：
    - 论文提出软件范式从「人写静态决策逻辑 **D**」转向「LLM 运行时生成/丢弃代码」；交付单元从功能软件变为 **Outcome**。
    - 定义 **Agentic Engineering**（LangChain 2026-04 术语化）：多 agent 数字成员、共享记忆、统一可观测，驱动全交付流水线而非仅加速编码。
    - 四阶段路线图：工具增强 → 单任务自治 → 多 agent 团队 → 自演化生态；引用 EvoClaw 连续演进成功率 **<38%** 警示长程维护鸿沟。

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

### 区域要闻

- **Gemini 3.5 Pro Nears June Launch With 2 Million Token Context And Deep Think Reasoning**
  - 来源：**TechTimes**
  - 时间：`260606`
  - 正文：~**580** tok
  - URL：https://www.techtimes.com/articles/317919/20260606/google-gemini-35-pro-nears-june-launch-2-million-token-context-deep-think-reasoning.htm
  - 类型：其他
  - 要点：
    - **Gemini 3.5 Pro** 据 I/O 路线将于 **6 月** GA，传闻 **2M** 上下文 + **Deep Think** 推理；截至 **260606** 仍处内部/有限预览，尚未广泛可用。
    - Flash 已 GA；Pro 档定位 coding/agentic 与深度推理，将补全 Google 3.5 系列旗舰空缺。
    - 亚太/全球开发者需区分「已发布 Flash」与「待发布 Pro」，避免将路线图当作可调用产品。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
