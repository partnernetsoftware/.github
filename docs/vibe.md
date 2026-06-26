# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260624 07:00` UTC → `260626 07:00` UTC（48h，cron 触发 `2026-06-26T07:00Z`） |
| 本文件更新 | `260626 07:00` UTC |
| 条目数 | 17 |
| 新模型 / 新产品 / 新模式 | 17（新模型 6 · 新产品 7 · 新模式 4） |
| main 合并 commit | `c348d4d` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Qwen-AgentWorld-35B-A3B — first native Language World Model across seven agent domains**
  - 来源：**Qwen**
  - 时间：`260624`
  - 正文：~**1180** tok
  - URL：https://qwen.ai/blog?id=qwen-agentworld
  - 类型：新模型
  - 要点：
    - **6/24** 阿里 Qwen 团队开源 **Qwen-AgentWorld-35B-A3B**（MoE **35B** 总参 / **3B** 激活，**256K** 上下文）及 **AgentWorldBench** 评测集；另有 **397B-A17B** 更大版未公开权重。Apache 2.0。
    - 训练目标反转：不优化「下一步动作」，而预测「环境下一状态」——覆盖 MCP、Search、Terminal、SWE、Android、Web、OS 七域统一架构；基于 **10M+** 真实 agent 轨迹，经 CPT→SFT→RL 三阶段。
    - 受控仿真 RL 使 MCPMark **24.6→33.8**；虚构世界训练迁移真实搜索 WideSearch F1 **34.02→50.31**；世界模型 warm-up 无 agent 微调即提升 BFCL v4 **62.29→71.25**。

- **Cohere Command A+ — 218B MoE enterprise agentic model in Microsoft Foundry**
  - 来源：**Cohere**
  - 时间：`260624`
  - 正文：~**920** tok
  - URL：https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/introducing-cohere-command-a-in-foundry/4530376
  - 类型：新模型
  - 要点：
    - **6/24** Cohere **Command A+**（**218B** 总参 / **25B** 激活 MoE，**128K** 输入 / **64K** 生成，**48** 语言，图文+tool use）正式上架 **Microsoft Foundry** serverless API；权重此前已于 **5/20** Hugging Face Apache 2.0 开放。
    - 统一 Command 系列推理/RAG/多模态/翻译能力于单模型；𝜏²-Bench Telecom **37%→85%**，Terminal-Bench Hard **3%→25%**；最低 **2×H100 W4A4** 或单 B200 可私有部署。
    - Foundry 集成使 Azure 企业用户可在同一评估/部署平面选用开源主权模型，与 GPT/Claude 等闭源选项并列——标志 MoE 开源权重进入 hyperscaler 托管目录。

- **OpenThinkerAgent-32B — open terminal and coding agent from Qwen3-32B post-training**
  - 来源：**OpenThoughts**
  - 时间：`260624`
  - 正文：~**780** tok
  - URL：https://arxiv.org/abs/2606.24855
  - 类型：新模型
  - 要点：
    - **6/24** OpenThoughts 发布 **OpenThinkerAgent-32B**：基于 **Qwen3-32B** 在 **100K** 过滤任务-轨迹对上 post-train 的开源 agent 模型；Terminal Bench **26%**，七项 coding/terminal 基准均值 **44.8%**。
    - 同步开放权重、**OpenThoughts-Agent-SFT-100K** 数据集、**AgentTrove**/**TaskTrove** 全量轨迹及消融实验记录；宣称同规模开源数据配方 SOTA。
    - 提供可复现 pipeline（GitHub `open-thoughts/OpenThoughts-Agent`），降低社区自建 terminal agent 的数据策展门槛。

- **Ornith-1.0 — MIT-licensed agentic coding family with self-scaffolding RL**
  - 来源：**DeepReinforce**
  - 时间：`260625`
  - 正文：~**850** tok
  - URL：https://huggingface.co/deepreinforce
  - 类型：新模型
  - 要点：
    - **6/25** Deep Reinforce AI 发布 **Ornith-1.0** 四档 MIT 开源 agentic coding 模型族：**9B** Dense、**31B**、**35B MoE**、**397B MoE**；基于 Gemma 4 / Qwen 3.5 预训练底座微调。
    - 核心创新：模型可学习自身 RL scaffold，摆脱固定人工设计 harness；**9B** 为入门档，**397B MoE** 面向最高精度多步任务。
    - Hugging Face 即时下载，配套 REST API + Python/JS/Go SDK；文档 `docs.deepreinforce.ai/ornith-1.0`，兼容 Transformers/vLLM/TGI。

- **LFM2.5-230M — 230M edge agentic model running on Pi 5 and smartphones**
  - 来源：**Liquid**
  - 时间：`260625`
  - 正文：~**720** tok
  - URL：https://www.liquid.ai/blog/lfm2-5-230m
  - 类型：新模型
  - 要点：
    - **6/25** Liquid AI 发布 **LFM2.5-230M**（**230M** 参数，**32K** 上下文）：LFM2 混合架构（gated conv + GQA），**19T** token 预训练 + 三阶段 post-train（SFT 蒸馏→DPO→多域 RL）。
    - 边缘实测：Galaxy S25 Ultra **213 tok/s** decode，Raspberry Pi 5 **42 tok/s**；数据抽取超越 **4×** 参数量级竞品（Qwen3.5-0.8B、Gemma 3 1B）；已在 Unitree G1 人形机器人 Jetson Orin 上跑通技能编排 demo。
    - Base + Instruct 双 checkpoint Hugging Face 开放；day-one 支持 llama.cpp/MLX/vLLM/SGLang/ONNX——标志 sub-1B agent 进入「手机/机器人可部署」实用区间。

- **GPT-5.6 — limited enterprise preview under US government case-by-case approval**
  - 来源：**Verge**
  - 时间：`260625 21:57`
  - 正文：~**880** tok
  - URL：https://www.theverge.com/ai-artificial-intelligence/957372/openai-will-delay-gpt-5-6-after-trump-administration-request
  - 类型：新模型
  - 要点：
    - **6/25** 特朗普政府要求 OpenAI 分阶段发布 **GPT-5.6**；CEO Altman 在全员 Q&A 确认将以**有限预览**形式先向少量企业客户开放，预览期内联邦政府**逐客户审批**访问资格——较 Anthropic Fable/Mythos 全球下架的 export-control 令更宽松。
    - 截至 **6/25** 仍无 model card 或公开 API 字符串；Codex 仓库已预埋 `gpt-5.6` 路由逻辑；传闻 ~**2M** 上下文、新 **max** reasoning effort、更强 agentic coding。
    - Polymarket「6/30 前最佳模型」Anthropic **94.8%**；更广泛公开发布指向 **7 月第二周**——标志美国前沿模型发布首次纳入行政审查流程。

### 新产品

- **OpenAI Jalapeño — first co-designed LLM inference Intelligence Processor with Broadcom**
  - 来源：**OpenAI**
  - 时间：`260624`
  - 正文：~**920** tok
  - URL：https://openai.com/index/openai-broadcom-jalapeno-inference-chip/
  - 类型：新产品
  - 要点：
    - **6/24** OpenAI 与 Broadcom 联合发布 **Jalapeño**——OpenAI 首款 **Intelligence Processor** 推理加速器，专为 ChatGPT/Codex/API 及未来 agentic 产品 LLM 负载架构设计；**9 个月**从设计到 tape-out，号称最快 ASIC 周期之一。
    - 早期测试显示每瓦性能显著优于 SOTA；架构减少数据搬运、平衡算力/内存/网络以逼近理论峰值利用率；集成 Broadcom Tomahawk 网络硅与 Celestica 机架方案。
    - 多代计算平台首步，计划 **2026 年底** 初始部署；标志 OpenAI 从「租云算力」向全栈（产品→模型→芯片）垂直整合。

- **Gong Revenue Harness — agentic execution layer with Custom Agents and MCP**
  - 来源：**Gong**
  - 时间：`260624`
  - 正文：~**780** tok
  - URL：https://www.gong.io/press/gong-launches-mission-big-dipper-revenue-harness
  - 类型：新产品
  - 要点：
    - **6/24** Gong 发布 **Mission Big Dipper**：收入 AI OS 新增 **Gong Revenue Harness** agentic 执行层——统一编排、治理 revenue cycle 全域 agent；**Custom Agents** 让 RevOps/销售经理无工程支持即可构建部署受控 agent。
    - 继承 Agent Studio 与 **MCP** 支持投资；扩展 Gong Assistant 至统一操作面，Gong Enable 新增 AI Coach / AI Builder for Scorecards；Account Console Dry Run 预计 **7 月** 上线。
    - 定位解决企业 AI 早期痛点：通用工具缺 revenue 上下文与治理而在生产环境失效——垂直领域 agent 编排控制平面产品化。

- **Gemini 3.5 Flash Computer Use — built-in browser/mobile/desktop agent tool**
  - 来源：**Google**
  - 时间：`260624`
  - 正文：~**820** tok
  - URL：https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-computer-use-gemini-3-5-flash/
  - 类型：新产品
  - 要点：
    - **6/24** Google 将 **Computer Use** 从独立 Gemini 2.5 模型升级为 **Gemini 3.5 Flash** 内置原生 tool——开发者调用标准 Flash endpoint 启用 `computer_use` 即可构建跨 browser/mobile/desktop 的屏幕操控 agent。
    - OSWorld **78.4**（超 GPT-5.4 mini **72.1**、Gemini 3 Flash **65.1**，略低于 Opus 4.8 **83.4**）；动作含 `intent` 推理字段；可选企业护栏（敏感操作需确认、检测到 prompt injection 自动停止）。
    - Gemini API + Gemini Enterprise Agent Platform 公测可用；Browserbase demo 与 GitHub reference implementation 同步发布——computer use 从「专用模型」变为 Flash 标配能力。

- **WordPress Studio Code — agentic WordPress expert in desktop app beta**
  - 来源：**WP**
  - 时间：`260625`
  - 正文：~**680** tok
  - URL：https://wordpress.com/blog/2026/06/25/studio-code-desktop/
  - 类型：新产品
  - 要点：
    - **6/25** WordPress 将终端版 **Studio Code** agent 扩展至 **Studio 桌面应用**（macOS/Windows/Linux）公测，取代 V1 AI assistant；CLI 版仍免费可用。
    - 自然语言驱动：创建站点、性能审计、批量内容/插件/主题管理、标注式批量更新、预览站生成与本地→staging/production 同步。
    - 标志 VibeCoding 从通用 IDE 向**垂直 CMS agent** 渗透——降低 WordPress 开发者首次尝试 agentic 工作流门槛。

- **Claude Code 2.1.191 — /rewind, permanent background-agent stop, MCP reliability**
  - 来源：**Anthropic**
  - 时间：`260625`
  - 正文：~**640** tok
  - URL：https://explainx.ai/blog/claude-code-2-1-191-rewind-mcp-background-agents-2026
  - 类型：新产品
  - 要点：
    - **6/25** Claude Code **2.1.191** 发布 **20+** CLI 变更：`/rewind` 在 `/clear` 后恢复上下文；任务面板停止 background agent **永久生效**（不再静默复活导致重复编辑）。
    - 流式输出 100ms coalescing 降低 CPU **~37%**；MCP `tools/list`/`prompts/list`/`resources/list` 瞬态错误退避重试；headless OAuth 跳过浏览器弹窗。
    - 修复逗号分隔 hook matcher、沙箱网络「Always allow」会话持久、权限对话框 recently-denied 记忆——提升长时 agent 会话稳定性。

- **JetBrains AI — Codex (GPT-5.4-mini medium) as recommended default agent**
  - 来源：**JetBrains**
  - 时间：`260625`
  - 正文：~**900** tok
  - URL：https://blog.jetbrains.com/ai/2026/06/codex-is-now-the-recommended-agent-in-jetbrains-ai/
  - 类型：新产品
  - 要点：
    - **6/25** JetBrains 将 **Codex + GPT-5.4-mini medium reasoning** 设为 AI Chat **推荐默认 agent**（取代需手动选择的 Chat 模式）；Junie/Claude Agent/ACP 兼容 agent 仍可切换。
    - 离线基准：Java **225** + C# **38** + Python **90** 真实代码库任务；Codex solve rate **39.9%** vs Junie(Gemini 3 Flash) **39.1%**，在线 A/B 验证 Codex 留存更优；评估数据开源于 **DPAIA** 仓库。
    - 标志 IDE 厂商从「多 agent 并列」转向**数据驱动默认路由**——降低新用户 agent 采用摩擦，OpenAI 获 JetBrains 官方背书。

- **Gemini API Computer Use public preview — multi-environment agent actions with safety policies**
  - 来源：**Google**
  - 时间：`260624`
  - 正文：~**560** tok
  - URL：https://ai.google.dev/gemini-api/docs/computer-use
  - 类型：新产品
  - 要点：
    - **6/24** Gemini API changelog 标注 Computer Use **public preview**：支持 browser/mobile/desktop 三环境、带 `intent` 的精简动作、可配置安全策略与 opt-in prompt injection 截图扫描。
    - Interactions API 文档将 **gemini-3.5-flash** 标为 Computer Use 推荐模型；legacy `gemini-2.5-computer-use-preview` 降级为遗留路径。
    - 与同日 Flash 内置 tool 发布配套，为开发者提供从 demo 到生产的 API 契约与 reference implementation。

### 新模式

- **Language World Models — predict environment state, not agent action (Qwen-AgentWorld paradigm)**
  - 来源：**Qwen**
  - 时间：`260624`
  - 正文：~**640** tok
  - URL：https://arxiv.org/abs/2606.24597
  - 类型：新模式
  - 要点：
    - Qwen-AgentWorld 提出 **Language World Model (LWM)** 范式：训练目标从「给定观测选动作」反转为「给定动作预测环境下一状态」——七域（MCP/Search/Terminal/SWE/Android/Web/OS）统一于单一预训练目标。
    - 两种互补用法：(1) 解耦环境模拟器——可控注入真实环境难触发的 edge case 做 agentic RL；(2) 统一 agent 基础模型 warm-up——无需 agent 微调即提升未见 benchmark。
    - 对比 Snowflake Agent World Model（代码驱动 SQL 环境）与 WebWorld（仅 Web）：首个七域原生世界模型；标志 agent 训练从「绑死生产环境」转向「可控仿真 + 真实环境」双层管线。

- **Government-regulated staggered frontier release — case-by-case customer approval (GPT-5.6)**
  - 来源：**Verge**
  - 时间：`260625`
  - 正文：~**580** tok
  - URL：https://www.theverge.com/ai-artificial-intelligence/957372/openai-will-delay-gpt-5-6-after-trump-administration-request
  - 类型：新模式
  - 要点：
    - **6/25** 美国行政分支首次介入 frontier 模型发布节奏：OpenAI 接受「有限企业预览 + 政府逐客户审批」而非即时全球 GA——与 Anthropic export-control 全球下架形成不对称监管。
    - 标志 AI 发布从「厂商自主节奏」转向「国家安全审查前置」；企业需预备审批流程、fallback 模型与迁移预案。
    - 对 VibeCoding 影响：前沿 coding 模型空窗期（Fable 5 下架 + GPT-5.6 延迟）拉长，开发者短期更依赖 Opus 4.8/Sonnet 4.6 或开源 Ornith/Qwen-AgentWorld 路线。

- **Native computer use in flash-tier model — screen control as first-class tool, not separate endpoint**
  - 来源：**Google**
  - 时间：`260624`
  - 正文：~**520** tok
  - URL：https://blog.google/innovation-and-ai/models-and-research/gemini-models/introducing-computer-use-gemini-3-5-flash/
  - 类型：新模式
  - 要点：
    - Google 将 computer use 从「独立 preview 模型」并入 **最快/最便宜 frontier Flash** 的工具栈——与 function calling、Search、Maps grounding 同级，降低 agent 架构复杂度与每任务 token 成本。
    - 三环境（browser/mobile/desktop）+ intent 标注 + 可选 injection 检测，形成「单模型多 surface agent」标准范式。
    - 对比 Anthropic computer use（独立 API）与 OpenAI Operator：Flash 内置路线使成本敏感型 agent 工作流（持续测试、办公自动化）更易规模化。

- **Benchmark-driven default agent routing — open DPAIA + online A/B for IDE defaults**
  - 来源：**JetBrains**
  - 时间：`260625`
  - 正文：~**540** tok
  - URL：https://blog.jetbrains.com/ai/2026/06/codex-is-now-the-recommended-agent-in-jetbrains-ai/
  - 类型：新模式
  - 要点：
    - JetBrains 用真实代码库任务（自动化测试验证）+ 成本上限（≤2% 用户超 **$20/月**）+ 在线 A/B 行为信号，而非品牌或合作关系，选定默认 agent。
    - **DPAIA**（Developer Productivity AI Arena）开源评测集使选择可复现、可随模型迭代重评——标志 IDE agent 默认从「厂商捆绑」转向「实证最优」。
    - 用户可随时切换 agent；推荐仅为起点——但默认路由对 agent 采用率有决定性影响，将重塑 Codex vs Junie vs Claude Agent 市场份额。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
