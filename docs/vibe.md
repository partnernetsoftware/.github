# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260612 07:00` UTC → `260614 07:00` UTC（48h，cron 触发 `2026-06-14T07:00Z`） |
| 本文件更新 | `260614 07:00` UTC |
| 条目数 | 14 |
| 新模型 / 新产品 / 新模式 | 14（新模型 5 · 新产品 6 · 新模式 3） |
| main 合并 commit | `4aee258` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Kimi K2.7-Code: coding-focused agentic model**
  - 来源：**Moonshot**
  - 时间：`260612`
  - 正文：~**920** tok
  - URL：https://huggingface.co/moonshotai/Kimi-K2.7-Code
  - 类型：新模型
  - 要点：
    - **Kimi K2.7-Code**：基于 K2.6 的 **1T** MoE 编程 agent 模型；相对 K2.6 推理 token 约 **−30%**，Kimi Code Bench v2 **+21.8%**、Program Bench **+11%**、MLS Bench Lite **+31.5%**。
    - **Modified MIT** 开源权重（~595GB）；API 模型串 `kimi-k2.7-code`（OpenAI 兼容），强制 thinking 模式、温度固定 **1.0**；支持 vLLM/SGLang/KTransformers 自托管。
    - 同步发布 **Kimi Code** 终端 agent 与会员计划（$19/月起）；与 K2.6 同架构可热切换，面向长程软件工程与 agent 工作流降本。

- **MiniMax M3: Frontier Coding, 1M Context, Native Multimodality**
  - 来源：**MiniMax**
  - 时间：`260612`
  - 正文：~**880** tok
  - URL：https://www.minimax.io/blog/minimax-m3
  - 类型：新模型
  - 要点：
    - **MiniMax M3**：**428B** MoE（**23B** active），**MSA** 稀疏注意力实现 **1M** token 上下文；原生多模态（图文视频）+ 桌面操作（OSWorld-Verified **70.06%**）。
    - 编码/agent 基准：SWE-Bench Pro **59.0%**、Terminal Bench 2.1 **66.0%**、MCP Atlas **74.2%**；API 定价约 **$0.30/M** input、**$1.20/M** output（缓存命中），Token Plan **$20/月起**。
    - **6/12** Hugging Face 释出完整权重（`MiniMaxAI/MiniMax-M3`）；首个将前沿编码、百万上下文、原生多模态三能力合一的开放权重模型。

- **Zamba2-VL: Hybrid Mamba2–Transformer vision-language models**
  - 来源：**Zyphra**
  - 时间：`260612`
  - 正文：~**760** tok
  - URL：https://arxiv.org/html/2606.00390
  - 类型：新模型
  - 要点：
    - **Zamba2-VL**：**1.2B / 2.7B / 7B** 三档开源 VLM，基于 Zamba2 混合 **Mamba2 SSM + 少量共享 Transformer** 骨干；**Apache 2.0** 权重与推理代码公开。
    - 与同规模 Transformer VLM（Molmo2、Qwen3-VL、InternVL3.5）竞争力相当，TTFT 约低 **1 个数量级**；视觉计数与文档理解强项，知识推理略弱。
    - 需 Zyphra `transformers` fork（v4.57.1）+ CUDA Mamba2 内核；面向边缘/设备端多模态 agent 的低延迟首 token 场景。

- **Varya: distilled AI video model for Indian cultural context**
  - 来源：**Avataar**
  - 时间：`260612`
  - 正文：~**820** tok
  - URL：https://techcrunch.com/2026/06/11/cheaper-faster-and-culturally-aware-avataars-video-ai-is-built-for-indias-scale/
  - 类型：新模型
  - 要点：
    - **Varya**：Avataar AI 在 IndiaAI Mission 支持下发布的蒸馏视频生成模型；基于 Alibaba **Wan 2.2** 蒸馏，生成步数 **50→4**，速度约 **10×**、成本约 **₹0.48/秒**（宣称较全球方案 **~20×** 便宜）。
    - 针对印度节庆、服饰、饮食、地域建筑等本土视觉语境优化；MeitY 秘书 S Krishnan 于新德里发布，计划开放权重至 **India AI Kosh**（含训练数据）。
    - 在线 demo：`varya.avataar.ai`（文本/参考图生成）；代表主权 AI 赛道从 LLM 向视频多模态 agent 素材生成延伸。

- **Statement on the US government directive to suspend access to Fable 5 and Mythos 5**
  - 来源：**Anthropic**
  - 时间：`260612 21:21`
  - 正文：~**900** tok
  - URL：https://www.anthropic.com/news/fable-mythos-access
  - 类型：新模型
  - 要点：
    - **6/12 17:21 ET** 美国政府以国家安全/出口管制为由，要求禁止外籍人士（含 Anthropic 外籍员工）访问 **Fable 5** 与 **Mythos 5**；Anthropic 无法实时区分用户国籍，遂**全球下线**。
    - 触发因素据称为一例窄域 jailbreak 演示（识别已知小漏洞）；Anthropic 称同类能力在 **GPT-5.5** 等公开模型亦可达成，不同意「窄域 jailbreak → 召回」标准。
    - 标志 frontier 模型「发布—政府强制召回」新范式；**Opus 4.8** 等其他 Claude 模型不受影响，GitHub Copilot 同日同步暂停 Fable 5。

### 新产品

- **Google AI Mode starts rolling out information agents**
  - 来源：**Google**
  - 时间：`260612`
  - 正文：~**720** tok
  - URL：https://indianexpress.com/article/technology/tech-news-technology/google-ai-mode-rolls-out-search-agents-that-track-the-web-for-you-in-real-time-10737846/
  - 类型：新产品
  - 要点：
    - **Information agents**：Search **AI Mode** 内 **7×24** 后台监控主题（博客/新闻/社交 + 实时财经/购物/体育），合成推送可行动更新；提示词含「keep me updated on」「alert me when」触发。
    - 首批面向 **Google AI Ultra**（$99.99–$199.99/月）全语言与市场；今夏扩展至 **AI Pro**，与 I/O 宣布的 agentic booking、Antigravity 自定义 Search 体验形成 agent 产品矩阵。
    - 代表 Google 从「单次查询」到「持久后台 agent」的 Search 交付形态；与同日 Kimi/MiniMax 开源模型形成「消费端 agent 服务 vs 开发者自托管」双轨。

- **Kimi Work: local desktop agent with 300-sub-agent swarm**
  - 来源：**Moonshot**
  - 时间：`260612`
  - 正文：~**840** tok
  - URL：https://decrypt.co/370954/moonshot-ai-kimi-work-300-agents-desktop
  - 类型：新产品
  - 要点：
    - **Kimi Work**：macOS（Apple Silicon）/ Windows 本地下载式 agent，基于 **K2.6**（256K 上下文）；读取本地文件、**WebBridge** 驱动已登录浏览器、内置 cron 定时任务。
    - **Agent Swarm** 并行最多 **300** 子 agent（K2.6 协调步数可达 **4000**）；免费下载，Moderato **$19/月** 起，完整 300-agent 需 Allegro/Vivace（$99–$199/月）。
    - 与云端 **Kimi Claw**（7×24）互补：本地优先可触达真实会话与文件，关机即停；代表知识工作者「桌面自治 agent」新交付品类。

- **Introducing Serge: GitHub-Native AI Code Review**
  - 来源：**HF**
  - 时间：`260612`
  - 正文：~**780** tok
  - URL：https://huggingface.co/blog/huggingface/serge
  - 类型：新产品
  - 要点：
    - **Serge**：Hugging Face 开源 GitHub 原生 PR 审查 agent；任意 **OpenAI 兼容** LLM，评论 `@askserge please review` 触发，遵循仓库 `.ai/review-rules.md` 策略。
    - 三种部署：**GitHub Action**（单仓快速试用）、**GitHub App webhook**（跨仓/fork 安全）、**Web app**（人工编辑后发布）；已在 `transformers`/`diffusers` 等仓库实战。
    - **Apache 2.0**；bubblewrap 沙盒隔离 fork PR 代码，helper 命令无网络/只读文件系统；代表 VibeCoding 审查从 IDE 侧边栏迁入 PR 工作流本体。

- **Introducing premium LLM models for UiPath Agents**
  - 来源：**UiPath**
  - 时间：`260612`
  - 正文：~**520** tok
  - URL：https://docs.uipath.com/agents/automation-cloud/latest/release-notes/june-2026
  - 类型：新产品
  - 要点：
    - UiPath Agents 新增 **Premium** 模型层：**Claude Opus 4.7** 与 **GPT-5.5**，面向多步规划、长上下文、高推理负载的企业 RPA/agent 场景。
    - 计费：Unified Pricing **0.4 Platform Units/次** 或 Flex **2 Agent Units/次**；与既有 Standard 层并存，管理员可按工作负载选模型。
    - 代表企业自动化平台将 frontier 模型作为可计费 SKU 分层交付，与 Coinbase/GitHub 等 agent 集成形成「模型即企业能力」趋势。

- **Introducing Omnigent: A Meta-Harness to Combine, Control and Share Your Agents**
  - 来源：**Databricks**
  - 时间：`260613`
  - 正文：~**860** tok
  - URL：https://www.databricks.com/blog/introducing-omnigent-meta-harness-combine-control-and-share-your-agents
  - 类型：新产品
  - 要点：
    - **Omnigent**：Databricks 开源（**Apache 2.0**）meta-harness alpha；统一接口编排 **Claude Code、Codex、Pi** 及自定义 agent，终端/Web/桌面/手机/API 多面接入。
    - 核心能力：多 harness **组合**（一行切换）、**有状态策略**（花费上限/模型路由/风险升级）、**实时协作**（URL 共享会话）、云沙盒（Modal/Daytona 等）。
    - PyPI `omnigent` v0.1.0rc2；路线图含 **Omnigent Server MCP**、GEPA 自动优化；Data + AI Summit 前周末抢先发布。

- **Kakunin Cryptographic Compliance Shield for Google Gemini and OpenAI Agent Ecosystems**
  - 来源：**Kakunin**
  - 时间：`260613`
  - 正文：~**640** tok
  - URL：https://www.prweb.com/releases/kakunin-announces-cryptographic-compliance-shield-for-google-gemini-and-openai-agent-ecosystems-302798798.html
  - 类型：新产品
  - 要点：
    - **Kakunin** 发布面向生产 agent 的加密合规 SDK：**Google Antigravity SDK**（hook 运行时保护）、**OpenAI Swarm**（`KakuninSwarm` 门控多 agent 切换）、**Assistants API**（`handle_assistants_requires_action` 一站式校验）。
    - 工具层 **X.509** 证书校验：执行前 scope 验证、证书吊销即停、篡改可审计日志；满足 **EU AI Act / MiCA** 等监管要求。
    - 同步覆盖 LangChain/LlamaIndex/CrewAI/AutoGen 模板；`pip install kakunin` 即用，代表 agent 合规从 prompt 层下沉至密码学工具执行层。

### 新模式

- **Government-forced frontier model recall（政府强制召回已部署 frontier 模型）**
  - 来源：**Anthropic**
  - 时间：`260612 21:21`
  - 正文：~**560** tok
  - URL：https://www.anthropic.com/news/fable-mythos-access
  - 类型：新模式
  - 要点：
    - **6/12** 美国商务部以出口管制要求 Anthropic 禁止外籍人士访问 Fable 5/Mythos 5；因无法实时国籍过滤，Anthropic **全球下线**两模型——业界首例已公开部署 frontier 模型遭政府强制召回。
    - Anthropic 主张：窄域 jailbreak 不应成为召回标准，否则将「实质上冻结所有 frontier 新模型部署」；呼吁透明、技术事实驱动的法定阻断流程。
    - 与 Pentagon 黑名单、Ona 收购等事件交织，标志 AI 治理从「发布前审查」扩展到「发布后实时执法」新阶段。

- **Meta-harness layer above coding agents（harness 之上的 meta-harness 编排层）**
  - 来源：**Databricks**
  - 时间：`260613`
  - 正文：~**540** tok
  - URL：https://www.databricks.com/blog/introducing-omnigent-meta-harness-combine-control-and-share-your-agents
  - 类型：新模式
  - 要点：
    - 行业共识：单 harness 已可换模型，但 **组合/治理/协作** 需 harness 之上新抽象；Omnigent 将「messages + files in → streams + tool calls out」统一为通用 API。
    - 有状态策略（花费/权限/升级）在 meta 层执行，而非写进 prompt；YAML 定义自定义 agent 可一行切换底层 harness（Claude Code ↔ Codex ↔ Pi）。
    - 类比 Kubernetes 对裸机编排：模型与 harness 持续迭代，开发者工作层保持稳定；与 GitHub Copilot App 多 worktree 并行形成「桌面/云端 meta 编排」对标。

- **Local-first desktop agent swarm（本地优先 + 大规模子 agent 蜂群）**
  - 来源：**Moonshot**
  - 时间：`260612`
  - 正文：~**500** tok
  - URL：https://decrypt.co/370954/moonshot-ai-kimi-work-300-agents-desktop
  - 类型：新模式
  - 要点：
    - **Kimi Work** 将 agent 执行从云沙盒拉回用户本机：可读写真实文件、驱动已登录浏览器、定时 cron——弥补云端 agent 无法触达私有会话的缺口。
    - **300 子 agent 蜂群** 并行分解任务，与 K2.6 的 **4000 步**协调上限绑定；付费分层解锁蜂群规模（$39 部分 / $99+ 完整）。
    - 与 OpenAI Ona 持久云执行、GitHub Copilot 云 session 形成「本地自治 vs 云端委托」双轨 VibeCoding 架构选择。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
