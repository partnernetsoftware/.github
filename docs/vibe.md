# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260621 07:02` UTC → `260623 07:02` UTC（48h，cron 触发 `2026-06-23T07:02Z`） |
| 本文件更新 | `260623 07:02` UTC |
| 条目数 | 14 |
| 新模型 / 新产品 / 新模式 | 14（新模型 5 · 新产品 6 · 新模式 3） |
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

- **Sakana Fugu / Fugu Ultra — multi-agent orchestration as a single OpenAI-compatible API**
  - 来源：**Sakana**
  - 时间：`260622`
  - 正文：~**1120** tok
  - URL：https://venturebeat.com/orchestration/no-claude-fable-5-no-problem-sakana-achieves-frontier-performance-with-new-fugu-multi-model-auto-synthesis-system
  - 类型：新模型
  - 要点：
    - **6/22** Sakana AI 正式发布 **Fugu**（高速日常）与 **Fugu Ultra**（复杂多步任务）两档编排模型，经单一 OpenAI 兼容端点 `https://api.sakana.ai` 对外；底层基于 TRINITY + Conductor 研究，用 ~7B 协调器动态路由、委派、验证并合成多模型输出。
    - 基准：SWE-Bench Pro **73.7**（超 Claude Opus 4.8 的 69.2 与 GPT-5.5 的 58.6）、LiveCodeBench **93.2**、GPQA-D **95.5**；定价 Fugu Ultra 固定 **$5/$30** per M input/output tokens（>272K 上下文升至 $10/$45），订阅档 $20–$200/月。
    - Fable 5 / Mythos 5 全球下线后，Fugu 以可替换 agent 池规避单厂商断供；暂不对 EU/EEA 开放；Codex CLI 可一行命令接入。

- **GPT-5.5-Cyber — full release for trusted defenders under Daybreak**
  - 来源：**OpenAI**
  - 时间：`260622`
  - 正文：~**980** tok
  - URL：https://openai.com/index/patch-the-planet
  - 类型：新模型
  - 要点：
    - **6/22** OpenAI 将 **GPT-5.5-Cyber** 从 permissive preview 升级为完整版，经 **Trusted Access for Cyber** 向经审核防御方开放；CyberGym 得分 **85.6%**（标准 GPT-5.5 为 81.8%），可自动复现漏洞、生成补丁与修复证据。
    - 与 **Patch the Planet** 联动：联合 Trail of Bits、HackerOne、Calif 为 cURL、Python、Go、Sigstore 等 30+ 开源项目提供 AI 辅助审计与补丁；人类安全工程师在送达维护者前复核全部发现。
    - Anthropic Mythos/Fable 下线后，OpenAI 借 Daybreak 扩大国际政府合作（澳、加、法、德、日、韩、欧盟 ENISA）；Codex Security 插件同步更新，支持 SARIF/CodeQL 集成。

- **TelecomGPT-R1 — 27B open reasoning model tops GSMA telco leaderboard**
  - 来源：**KU**
  - 时间：`260622`
  - 正文：~**720** tok
  - URL：https://www.middleeastainews.com/p/khalifa-university-telecomgpt-r1-wins
  - 类型：新模型
  - 要点：
    - **6/22** 阿布扎比 **Khalifa University** 在 MWC 上海发布 **TelecomGPT-R1**：**27B** 参数电信专用推理模型，Apache-2.0 开源。
    - GSMA Open Telco Leaderboard 平均 **89.6%**，超越所有已测闭源/开源通用与电信模型；由 Digital Future Institute 开发，为 TelecomGPT 系列第三代。
    - 运营商、设备商与研究机构可免费检视与适配，标志垂直领域开源推理模型在行业标准基准上首次全面领先闭源竞品。

- **MOSS-TTS-Local-Transformer-v1.5 — 4B stereo speech model with 48 kHz output**
  - 来源：**OpenMOSS**
  - 时间：`260618`
  - 正文：~**640** tok
  - URL：https://github.com/OpenMOSS/MOSS-TTS
  - 类型：新模型
  - 要点：
    - **6/18** OpenMOSS 发布 **MOSS-TTS-Local-Transformer-v1.5**：**4B** `MossTTSLocal` 骨干由 Qwen3-1.7B 扩至 Qwen3-4B，搭配 **MOSS-Audio-Tokenizer-v2** 实现原生 **48 kHz 立体声**输出。
    - 支持语言标签、稳定克隆、显式停顿控制；家族另含 1.2B–3.8B 变体，覆盖长文本、多说话人对话与实时流式 TTS。
    - **6/22** 社区关注度上升（GitHub 3500+ stars）；对 agent 语音交互栈提供可自托管替代 ElevenLabs/OpenAI TTS 的开源选项。

- **GPT-5.6 launch window — alignment fix and 1.5M token context (rumored)**
  - 来源：**TechTimes**
  - 时间：`260621`
  - 正文：~**1050** tok
  - URL：https://www.techtimes.com/articles/318799/20260621/gpt-56-launch-window-starts-monday-alignment-fix-15m-token-context-inside.htm
  - 类型：新模型
  - 要点：
    - **6/21–23** OpenAI 仍未官宣 **GPT-5.6**；Polymarket 合约将 **6/22–28** 标为最可能发布周（总交易量超 **$1.1M**）；**6/18** 泄露称 **6/25** 为计划发布日，内部代号 **kindle-alpha**。
    - 部分 ChatGPT Pro 账户疑似已影子部署——单次软件构建耗时从 GPT-5.5 的 ~10 分钟增至 ~60 分钟；Codex 路由日志曾短暂出现 `gpt-5.6` 标识。
    - 预期升级：**1.5M** 上下文、重设计 reward audit pipeline 修复 GPT-5.5 对齐污染；Fable 5 下线后 agentic coding 前沿出现空窗。

### 新产品

- **Google Interactions API — GA as primary interface for Gemini models and agents**
  - 来源：**Google**
  - 时间：`260622`
  - 正文：~**920** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/interactions-api-general-availability/
  - 类型：新产品
  - 要点：
    - **6/22** Google 宣布 **Interactions API** 正式 GA，成为 Gemini 模型与 agent 的**默认主接口**；AI Studio、官方文档与 SDK 示例均已切换，legacy `generateContent` 仍支持但前沿 agent 能力将优先独家登陆 Interactions。
    - 新能力：**Managed Agents**（远程 Linux 沙箱，默认 Antigravity agent）、`background=True` 异步长任务、工具混搭（Google Search/Maps + 自定义函数）、Deep Research 升级版、Nano Banana 2 图像/Lyria 3 音乐/多说话人 TTS。
    - Schema 从 role 结构改为 typed **Steps**；Flex 档降价 **50%**；发布 `gemini-interactions-api` Skill 供 coding agent 自动对齐最佳实践；LiteLLM/Eigent/Agno 已集成。

- **Productboard Spark — agentic product system with MCP push to Cursor/Codex**
  - 来源：**PB**
  - 时间：`260622`
  - 正文：~**880** tok
  - URL：https://www.productboard.com/blog/introducing-spark-agentic-product-system/
  - 类型：新产品
  - 要点：
    - **6/22** Productboard 发布 **Spark**：首个面向产品团队的 **agentic product system**（公测），从客户反馈、竞品、代码库到交付规格全流程 AI 原生重建。
    - 专用 agent 覆盖 VoC 分析、规格撰写、竞品研究、代码库理解；输出全程可溯源至真实客户笔记；规格可经新 **MCP** 一键推入 **Claude Code、Codex、Cursor**，消除 PM→工程 handoff 损耗。
    - 支持 GitHub 代码库接地规格、上线后自动拉取 Pendo/Hex/Amplitude 分析做 launch review；标志 VibeCoding 上游「产品意图→可执行 spec」链路产品化。

- **Patch the Planet — Daybreak open-source maintainer security program**
  - 来源：**OpenAI**
  - 时间：`260622`
  - 正文：~**860** tok
  - URL：https://openai.com/index/patch-the-planet
  - 类型：新产品
  - 要点：
    - **6/22** OpenAI 在 Daybreak 下推出 **Patch the Planet**：与 Trail of Bits 合作，为开源维护者提供 AI 辅助漏洞发现+**人类复核**+补丁开发+协调披露全链路，避免 AI 报告淹没维护者。
    - 首期覆盖 cURL、Python、Go、Sigstore、pyca/cryptography 等 19+ 项目；5 天冲刺发现数百问题、合并数十补丁，并产出可复用 fuzzing/差分测试流水线。
    - 维护者可获 ChatGPT Pro、条件性 Codex Security 访问与 API 额度；标志「AI 找洞→专家验真→维护者拍板」的 agentic 安全运维新模式落地开源生态。

- **Zoom Virtual Agent — Agent Architect and Agent Performance Suite**
  - 来源：**Zoom**
  - 时间：`260622`
  - 正文：~**680** tok
  - URL：https://news.zoom.com/introducing-agent-architect-and-agent-performance-suite-for-zoom-virtual-agent/
  - 类型：新产品
  - 要点：
    - **6/22** Zoom 为 **Zoom Virtual Agent (ZVA)** 发布 **Agent Architect**（可视化 agent 生成与部署）与 **Agent Performance Suite**（持续优化与个性化），并增强跨 Zoom CX 的客户上下文层。
    - 帮助企业更快生成端到端对话式 AI agent、优化多渠道客服表现；CCW Las Vegas **6/22–25** 展台首发演示。
    - 标志企业客服栈从「聊天机器人配置」演进为「agent 架构师 + 性能闭环」一体化平台。

- **i10X Superagent — human-directed Chief of Staff across 100+ tools**
  - 来源：**i10X**
  - 时间：`260622`
  - 正文：~**620** tok
  - URL：https://markets.businessinsider.com/news/stocks/i10x-launches-superagent-1036266766
  - 类型：新产品
  - 要点：
    - **6/22** 新加坡 **i10X.ai**（15 万+ 用户工作流平台）发布 **Superagent**：用户设定商业目标后 agent 写计划并在 **100+** 已连接工具间执行，但在发邮件、上线 deck 或资金操作前**强制人工确认**。
    - 定位「首席幕僚」而非完全自主 agent——计划可见、关键动作需批准、无静默越权。
    - 已在 i10X 工作区内可用；代表 enterprise agent 部署中「autonomy with guardrails」的产品化路径。

- **Zensar AgentMesh — 80+ pre-built enterprise agents on six-layer platform**
  - 来源：**Zensar**
  - 时间：`260622`
  - 正文：~**700** tok
  - URL：https://techedgeai.com/zensar-unveils-agentmesh-a-scalable-agentic-ai-platform-for-enterprises/
  - 类型：新产品
  - 要点：
    - **6/22** 印度 IT 服务商 **Zensar** 发布 **ZenseAI.AgentMesh**：六层架构企业 agentic 平台，内置 **80+** 预部署 agent（KYC、欺诈检测、理赔、合规文档处理等）。
    - 开箱集成 SAP、Salesforce、ServiceNow、Snowflake、Databricks；云或本地部署；宣称 **6–8 周**上线，内置 EU AI Act 与 SR 11-7 合规对齐。
    - 标志垂直行业 agent 目录化交付——企业无需从零编排，直接选购行业 agent 接入现有数据管道。

### 新模式

- **Orchestration Models — learned multi-model routing as commercial API (Fugu paradigm)**
  - 来源：**Sakana**
  - 时间：`260622`
  - 正文：~**580** tok
  - URL：https://console.sakana.ai/get-started
  - 类型：新模式
  - 要点：
    - Fugu 将 LangGraph/CrewAI 式多 agent 编排**黑盒封装为单一 LLM API**：用户发一次请求，协调器自动拆分、委派、验证、合成，路由信息对开发者不可见。
    - 与 RouteLLM/Not Diamond 等「选单一最优模型」路由不同，Fugu 支持多轮并行/串行委派；背景 orchestration token 计入账单。
    - 出口管制与单厂商断供背景下，「可替换 agent 池 + 学习型协调器」成为 frontier 能力的实用对冲——不必拥有最大单体模型也能逼近 Fable/Mythos 性能。

- **Agent-first developer API — Interactions replaces generateContent for stateful workflows**
  - 来源：**Google**
  - 时间：`260622`
  - 正文：~**520** tok
  - URL：https://ai.google.dev/gemini-api/docs/interactions/interactions-overview
  - 类型：新模式
  - 要点：
    - Google 明确前沿长任务与 agent 能力将**优先独家**登陆 Interactions API——从「无状态 completion」转向「有状态 step 流 + 服务端状态 + 托管沙箱」。
    - 单一端点同时服务模型推理（`gemini-3.5-flash` 等）与 agent（`antigravity-preview`、`deep-research-*`）；`background=True` 解耦长任务与客户端连接。
    - 对 VibeCoding 的影响：coding agent 默认通过 Interactions + Antigravity 沙箱构建，Gemini CLI 已让位于 **Antigravity CLI**（**6/18** 对个人 Pro/Ultra 停服）。

- **Agentic product management — spec-to-IDE via MCP without copy-paste**
  - 来源：**PB**
  - 时间：`260622`
  - 正文：~**480** tok
  - URL：https://www.productboard.com/blog/introducing-spark-agentic-product-system/
  - 类型：新模式
  - 要点：
    - Productboard Spark 将 PM 工作流从「人写 spec → 复制到 IDE」变为「agent 从真实产品数据生成可追溯 spec → MCP 直推 Cursor/Codex/Claude Code」。
    - 多专用 agent 共享产品战略、OKR、客户历史上下文——区别于每轮重置的通用 ChatGPT 会话。
    - 标志 VibeCoding 上游意图层产品化：PM agent 与 coding agent 经 MCP 形成闭环，Spec-Driven 与 Vibe 的边界在工具链层面开始融合。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
