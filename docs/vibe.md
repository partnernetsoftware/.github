# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260625 07:00` UTC → `260627 07:00` UTC（48h，cron 触发 `2026-06-27T07:01Z`） |
| 本文件更新 | `260627 07:00` UTC |
| 条目数 | 15 |
| 新模型 / 新产品 / 新模式 | 15（新模型 5 · 新产品 5 · 新模式 5） |
| main 合并 commit | `cc8cc28` |

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
    - **6/26** OpenAI 正式发布 **GPT-5.6** 三档：**Sol**（旗舰）、**Terra**（日常，性能≈GPT-5.5 但 **2×** 便宜）、**Luna**（最快最便宜）；定价 Sol **$5/$30**、Terra **$2.50/$15**、Luna **$1/$6** per 1M tokens；新增 **30 分钟** prompt cache 与显式 cache breakpoint。
    - 能力：Sol **Terminal-Bench 2.1** SOTA；新增 **`max`** reasoning effort 与 **`ultra`** 模式（多 subagent 并行）；**7 月** Cerebras 上 Sol 达 **750 tok/s**。
    - 访问：受美国政府要求，首批仅约 **20** 家可信伙伴经 API/Codex 预览，GA 计划数周内；OpenAI 公开反对将此审查流程长期化。

- **Kimi K2.7 Code — 1T MoE open-source agentic coding model with 30% fewer thinking tokens**
  - 来源：**Moonshot**
  - 时间：`260625`
  - 正文：~**980** tok
  - URL：https://www.kimi.com/resources/kimi-k2-7-code
  - 类型：新模型
  - 要点：
    - **6/25** Moonshot 发布 **Kimi K2.7 Code**：**1T** 总参 / **32B** 激活 MoE，**256K** 上下文，MoonViT **400M** 视觉编码器；Modified MIT 开源权重 Hugging Face `moonshotai/Kimi-K2.7-Code`。
    - 相对 K2.6：Kimi Code Bench v2 **50.9→62.0**（+21.8%）、MCP Mark Verified **72.8→81.1**；thinking token 用量降约 **30%**；强制 thinking + preserve_thinking。
    - 渠道：Kimi Code CLI 默认模型、Kimi API（**$0.95/$4.00** per 1M，cache hit **$0.19**）；vLLM/SGLang/KTransformers 部署。

- **Ornith-1.0 — MIT-licensed agentic coding family with self-scaffolding RL**
  - 来源：**DeepReinforce**
  - 时间：`260625`
  - 正文：~**850** tok
  - URL：https://deep-reinforce.com/ornith_1_0.html
  - 类型：新模型
  - 要点：
    - **6/25** Deep Reinforce AI 发布 **Ornith-1.0** 四档 MIT 开源 agentic coding 模型族：**9B** Dense、**31B**、**35B MoE**、**397B MoE**；基于 Gemma 4 / Qwen 3.5 预训练底座微调。
    - **397B** 达 Terminal-Bench 2.1 **77.5**、SWE-Bench Verified **82.4**；**9B** 在单 **80GB** GPU 可部署（TB-2.1 **43.1**）。
    - 核心创新：模型在 RL 中学习自身 scaffold，摆脱固定人工 harness；OpenAI-compatible endpoint，兼容 OpenHands/OpenCode。

- **LFM2.5-230M — 230M edge agentic model running on Pi 5 and smartphones**
  - 来源：**Liquid**
  - 时间：`260625`
  - 正文：~**720** tok
  - URL：https://www.liquid.ai/blog/lfm2-5-230m
  - 类型：新模型
  - 要点：
    - **6/25** Liquid AI 发布 **LFM2.5-230M**（**230M** 参数，**32K** 上下文）：LFM2 混合架构（gated conv + GQA），**19T** token 预训练 + 三阶段 post-train（SFT 蒸馏→DPO→多域 RL）。
    - 边缘实测：Galaxy S25 Ultra **213 tok/s** decode，Raspberry Pi 5 **42 tok/s**；数据抽取超越 **4×** 参数量级竞品；Unitree G1 人形机器人 Jetson Orin 技能编排 demo。
    - Base + Instruct 双 checkpoint Hugging Face 开放；day-one 支持 llama.cpp/MLX/vLLM/SGLang/ONNX。

- **OpenThinkerAgent-32B — open terminal and coding agent from Qwen3-32B post-training**
  - 来源：**OpenThoughts**
  - 时间：`260625`
  - 正文：~**780** tok
  - URL：https://arxiv.org/abs/2606.24855
  - 类型：新模型
  - 要点：
    - **6/25** OpenThoughts 发布 **OpenThinkerAgent-32B** 与 **OpenThoughts-Agent-SFT-100K**：基于 **Qwen3-32B** 在 **100K** 过滤任务-轨迹对上 post-train；七项 agent 基准均值 **44.8%**，超 Nemotron-Terminal-32B **40.9%**。
    - **100+** 消融实验验证任务来源与多样性关键性；数据集在多种训练规模下均优于其他开源 agent 数据配方。
    - 同步开放权重、**AgentTrove**/**TaskTrove** 轨迹及 GitHub `open-thoughts/OpenThoughts-Agent` 可复现 pipeline。

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
  - 来源：**VentureBeat**
  - 时间：`260626`
  - 正文：~**620** tok
  - URL：https://venturebeat.com/technology/openai-unveils-gpt-5-6-sol-terra-and-luna-models-but-only-accessible-to-limited-preview-partners-for-now-per-us-gov
  - 类型：新模式
  - 要点：
    - **6/26** 特朗普 **6/2** 网络安全行政令后，OpenAI 接受「约 **20** 家可信伙伴预览 + 政府逐客户知情」而非即时全球 GA——较 Anthropic Fable/Mythos 全球下架更温和但仍创先例。
    - OpenAI 在官方稿中公开反对此流程长期化，称将阻碍 cyber defender 与全球伙伴获取工具；短期配合以换取数周内 broader availability。
    - 对 VibeCoding：前沿 coding 模型空窗期（Fable 5 下架 + GPT-5.6 受限预览）拉长，开发者短期更依赖 Opus 4.8、开源 Kimi K2.7 Code/Ornith 路线。

- **Self-scaffolding RL — model learns its own training harness during reinforcement learning (Ornith)**
  - 来源：**DeepReinforce**
  - 时间：`260625`
  - 正文：~**560** tok
  - URL：https://deep-reinforce.com/ornith_1_0.html
  - 类型：新模式
  - 要点：
    - Ornith-1.0 将 RL 训练目标从「固定 harness 下优化解题」扩展为「**联合优化 scaffold + solution**」——模型自己写执行脚手架指导搜索，三层防 reward hacking（trust boundary + monitor + frozen judge）。
    - 对比传统 agent 栈（固定 OpenHands/Terminus harness + 只训模型）：开源 agent 竞赛从 benchmark 刷分转向 **workflow 构造能力** 本身可学习。
    - 标志 agentic coding 训练范式从「绑死生产 harness」转向「harness 与 policy 共同进化」。

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
