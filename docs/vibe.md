# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260705 07:01` UTC → `260707 07:01` UTC（48h，cron 触发 `2026-07-07T07:01Z`） |
| 本文件更新 | `260707 07:01` UTC |
| 条目数 | 15 |
| 新模型 / 新产品 / 新模式 | 14（新模型 3 · 新产品 7 · 新模式 4） |
| main 合并 commit | `0503953` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
├── 新模式
└── 监管安全
```

### 新模型

- **Hy3 — 295B MoE Apache 2.0 open-weight agent model (256K ctx)**
  - 来源：**Tencent**
  - 时间：`260706`
  - 正文：~**980** tok
  - URL：https://huggingface.co/tencent/Hy3
  - 类型：新模型
  - 要点：
    - **7/6** 腾讯混元正式发布 **Hy3** 完整版（4 月 Preview 后 10 周迭代）：**295B** total / **21B** active MoE（192 experts top-8）+ **3.8B** MTP 推测解码层，**256K** ctx；由 **Apache 2.0** 发布（取消 Preview 版区域限制），权重上 Hugging Face / ModelScope / GitHub，含 FP8 量化版。
    - 基准（厂商自测）：BrowseComp **84.2**、MCP-Atlas **79.1**、SWE-bench Verified **78.0**（仍低于 GLM-5.2 **84.2**）；幻觉率 Preview→正式 **12.5%→5.4%**；FP8 权重 **<300GB**（约为 GLM-5.2 一半），推荐 **8×H20-3e** 自托管；OpenRouter **两周免费**。
    - Vibe 信号：开源 frontier 竞争从「榜单参数」转向「生产可靠性 + 部署经济学」——Hy3 主打 search/tool agent 与跨 harness 一致性，coding 仍让位 GLM-5.2；西方企业首次可无许可障碍评估腾讯权重。

- **LongCat-2.0 — 1.6T MoE agentic coding model (MIT, 1M ctx)**
  - 来源：**Meituan**
  - 时间：`260705`
  - 正文：~**920** tok
  - URL：https://huggingface.co/meituan-longcat/LongCat-2.0
  - 类型：新模型
  - 要点：
    - **7/5–6** 美团正式公开 **LongCat-2.0**（此前 OpenRouter 代号 **Owl Alpha** 连续两月调用量前三）：**1.6T** total / **~48B** active MoE，原生 **1M** ctx（LongCat Sparse Attention），**MIT** 许可；训练+推理全程 **5 万+** 国产 AI ASIC 超算，**35T+** tokens 无回滚。
    - 基准（厂商）：SWE-bench Pro **59.5%**、Terminal-Bench 2.1 **70.8%**、SWE-bench Multilingual **77.3%**；API **$0.75/M** in、**$2.95/M** out，缓存读免费；Anthropic-compatible endpoint 三行变量即可接入 **Claude Code**。
    - Vibe 信号：万亿参数 open-weight agentic coder 经 OpenRouter 实战验证后揭面——亚太 frontier 模型从「榜单」进入「全球 harness 默认可选」。

- **GPT-Realtime-2.1 & GPT-Realtime-2.1 mini — realtime voice reasoning models**
  - 来源：**OpenAI**
  - 时间：`260706`
  - 正文：~**480** tok
  - URL：https://developers.openai.com/api/docs/changelog
  - 类型：新模型
  - 要点：
    - **7/6** OpenAI API Changelog 发布 **GPT-Realtime-2.1** 及蒸馏版 **GPT-Realtime-2.1 mini**，经 `v1/realtime` 端点提供；改进字母数字识别、静音/噪声处理与打断行为。
    - **mini** 定位为更快、更低成本的 realtime 语音推理模型——适合 voice agent 与低延迟交互场景，与 GPT-5.6 系列（仍处政府门控 preview）形成互补产品线。
    - Vibe 信号：agent 栈从文本 coding 向 **实时语音 harness** 延伸；voice-first agent 可复用同一 Responses/Realtime API 基础设施。

### 新产品

- **Sakana Fugu — multi-agent orchestrator as single OpenAI-compatible API**
  - 来源：**Sakana**
  - 时间：`260705`
  - 正文：~**780** tok
  - URL：https://github.com/SakanaAI/fugu
  - 类型：新产品
  - 要点：
    - **7/5** 东京 Sakana AI 将 **Fugu** 多代理编排系统以「单模型 API」交付：内部动态调度 **Gemini 3.1 Pro / Claude Opus 4.8 / GPT-5.5** 等 frontier worker，对外仅暴露 Chat Completions + Responses 标准端点。
    - 双档：**Fugu**（低延迟单 worker 路由）与 **Fugu Ultra**（`fugu-ultra-20260615`，递归子任务并行）；**1M** ctx；一行安装 `curl -fsSL https://sakana.ai/fugu/install | bash`。
    - 基于 ICLR 2026 **TRINITY** + **Conductor** 论文——与 Hermes MoA 2.0 形成「开源虚拟模型 vs 闭源 learned orchestrator」双轨。

- **Harness Autonomous Worker Agents & Agent Marketplace — pipeline-native delivery agents (GA)**
  - 来源：**Harness**
  - 时间：`260705`
  - 正文：~**820** tok
  - URL：https://harness.io/platform/worker-agents
  - 类型：新产品
  - 要点：
    - **7/5** 企业软件交付平台 **Harness** 宣布 **Autonomous Worker Agents** 与 **Agent Marketplace** 全面 GA（**6/30** 首发，本周进入交付流水线主流讨论）：agent 作为 **pipeline step** 运行于客户基础设施，继承 OPA 策略、审批门禁与审计轨迹。
    - 预置 agent 覆盖 CI 失败修复、PR 验证、安全扫描、部署回滚等；支持 Anthropic/OpenAI/OpenAI-compatible 模型 + **MCP server** 自定义工具；Marketplace 分 Managed / Certified / Community 三级。
    - Vibe 信号：AI agent 重心从「写代码」转向 **CI/CD→生产** 运维链——与 Claude Code/Cursor 互补，面向 platform/DevOps 团队的 governed agent 交付物。

- **CircleChat — team chat with LLM judge for multi-agent kanban**
  - 来源：**CircleChat**
  - 时间：`260705`
  - 正文：~**640** tok
  - URL：https://www.producthunt.com/products/circlechat
  - 类型：新产品
  - 要点：
    - **7/5** **CircleChat** 上线（Product Hunt #6）：团队聊天中 AI agent 为一等成员，自动拆解目标至看板任务、认领执行并在频道汇报；任务完成前由 **LLM judge** 对照 acceptance criteria 评分，web 输出额外 headless 渲染校验。
    - BYOK 直连 OpenAI/Anthropic/Google/Groq/Cerebras/DeepSeek，不经平台转售 token；**MIT** 可自托管，托管 **$29/月/workspace**。
    - Vibe 信号：多 agent「公司化」编排 + **确定性 judge 门禁**——解决 agent 互批垃圾输出的经典 failure mode。

- **Injective MCP Server — open-source onchain agent bridge for smart contracts**
  - 来源：**Injective**
  - 时间：`260705`
  - 正文：~**700** tok
  - URL：https://github.com/InjectiveLabs/mcp-server
  - 类型：新产品
  - 要点：
    - **7/5** 区块链网络 **Injective** 开源 **MCP server**（**262** tests）：AI coding agent 可用自然语言部署 EVM 合约、执行永续交易、查询链上数据——无需手写交易构造。
    - 配套 Documentation MCP + `injective-evm-developer` agent-skills 包，形成 doc→编码→部署→验证端到端 workflow；兼容 Claude/Cursor/LangChain/CrewAI 等 MCP 客户端。
    - Vibe 信号：MCP 成为 **链上 action** 标准接入层——Web3 agent 从 demo 进入可审计的生产工具链。

- **OpenClaw v2026.7.1-beta.2 — GPT-5.6 series & Nemotron Super 1M ctx**
  - 来源：**OpenClaw**
  - 时间：`260705 09:10`
  - 正文：~**640** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.7.1-beta.2
  - 类型：新产品
  - 要点：
    - **7/5** 开源个人 AI 助手 **OpenClaw** `v2026.7.1-beta.2`：新增 **GPT-5.6** 全系 provider 支持；**Nemotron Super** 启用 **1M** ctx 窗口；保留 OpenRouter 显式鉴权头。
    - 跨平台 agent 运行时快速跟进 frontier 型号——VibeCoding harness 竞争从「谁有最好 UI」转向「谁最快接上新模型 API」。

- **CachePilot — drop-in AI API caching proxy (20% of savings pricing)**
  - 来源：**CachePilot**
  - 时间：`260706`
  - 正文：~**700** tok
  - URL：https://cachepilot.serveousercontent.com
  - 类型：新产品
  - 要点：
    - **7/6** **CachePilot** 上线：一行改 `base_url` 即可代理 **OpenAI / Anthropic / OpenRouter**；L0 内存 + L1 Redis + 规范化层识别重复 prompt，缓存命中 **<1ms**、零 provider 费用。
    - 定价：**节省额的 20%**（无订阅/最低消费），7 天免费试用；用户自持 API key。
    - Agent 经济层：长程 agent 重复 system prompt 可占账单 **~70%**——中间件缓存成为 VibeCoding 降本基础设施。

- **mcptools 1.0.0 — R SDK for MCP with Posit Connect deployment**
  - 来源：**Posit**
  - 时间：`260706`
  - 正文：~**560** tok
  - URL：https://opensource.posit.co/blog/2026-07-06_mcptools-1-0-0/
  - 类型：新产品
  - 要点：
    - **7/6** **mcptools** 首个 major release 上 CRAN：R 生态 MCP SDK 支持从认证远程 server 拉取 tools、在 **Posit Connect** 一键部署 MCP server（`plumber2` `_server.yml` 标准）。
    - 原生支持图片等富内容类型；简化 `mcp_tools()` 配置对接第三方 MCP。
    - Vibe 信号：MCP 工具层从 Python/TS 扩展到 **R 数据科学**栈——企业分析 agent 可复用同一 Connect 治理面。

- **AgentGuard v0.6.0 — agent memory poisoning detection (MCP server)**
  - 来源：**Dockfix**
  - 时间：`260705 01:55`
  - 正文：~**620** tok
  - URL：https://github.com/dockfixlabs/agentguard/releases/tag/v0.6.0
  - 类型：新产品
  - 要点：
    - **7/5** **AgentGuard** `v0.6.0` 首发 **ASI-MEMORY-POISON** 检测：扫描向量库、LangChain Memory、RAG 管线中未净化的持久化写入。
    - **14** 条规则、**26** 个 memory sink 模式，Python + TS 双语言；含 MCP server 模式，可嵌入 agent CI 流水线。
    - 长程 Vibe agent 的安全交付物：记忆层从「功能」升级为需门禁的 **信任边界**。

### 新模式

- **VeRO — evaluation harness for agents to optimize agents (ICML 2026)**
  - 来源：**Scale**
  - 时间：`260706`
  - 正文：~**880** tok
  - URL：https://scale.com/blog/vero
  - 类型：新模式
  - 要点：
    - **7/6** Scale AI 发布 **VeRO**（Versioning, Rewards, and Observations）开源 harness（GitHub `scaleapi/vero`），ICML 2026 Seoul **7/7** poster；benchmark **edit–execute–evaluate** 循环中 optimizer agent 改进 target agent。
    - 实证：工具型任务（GAIA、TAU-Bench Retail、SimpleQA）最优配置平均 **+8–9%**，GAIA 最高 **4.3×**；推理型（GPQA、MATH）几乎无提升——**workflow/tool 可优化，forward-pass 推理不可**。
    - Vibe 信号：agent 工程分裂为「AI 可 trial-and-error 的 harness 层」与「仍须人类判断的 reasoning 层」——meta-agent 优化成为 coding agent 新能力前沿。

- **Hermes MoA 2.0 — virtual model presets in open-source agent framework**
  - 来源：**Nous**
  - 时间：`260705`
  - 正文：~**860** tok
  - URL：https://www.techtimes.com/articles/319754/20260705/hermes-moa-20-combines-gpt-claude-deepseek-outscore-any-one-model.htm
  - 类型：新模式
  - 要点：
    - **7/5** Nous Research **Hermes Mixture of Agents 2.0**：多 reference model 独立分析 + aggregator 合成，预设以 **virtual model** 出现在 CLI/Telegram/Discord 模型选择器；`/moa [prompt]` 单次高质量调用。
    - 工程细节：reference 输出追加至最新 user turn 保 prompt cache；禁止嵌套 MoA；仅 aggregator 持完整 tool access。内部 HermesBench 预设报 **0.8202** vs Opus 单模 **0.7607**。
    - 地缘语境：Fable 5 全球停服 19 天后（**7/1** 恢复），MoA 2.0 将「受限 frontier」重构为「可组装开放组合」。

- **Learned orchestrator vs ensemble MoA — dual multi-model routing paradigms**
  - 来源：**Sakana**
  - 时间：`260705`
  - 正文：~**580** tok
  - URL：https://arxiv.org/abs/2606.21228
  - 类型：新模式
  - 要点：
    - **7/5** 同周 **Sakana Fugu**（learned coordinator，RL 训练路由/委托/验证）与 **Hermes MoA 2.0**（用户配置 reference+aggregator 集成）代表多模型路由两条路径：**黑盒协调器 API** vs **透明可配 ensemble**。
    - Fugu 强调 export-control 韧性；MoA 强调 prompt cache 友好与 reference 输出可审计——企业选型须在 **性能/合规/可观测** 三角取舍。
    - 对 VibeCoding：「选模型」正演变为「选编排范式」——单 endpoint 多 worker 成为与 MCP 工具层并列的新抽象。

- **China humanlike-agent compliance — persona agents sunset before July 15 rules**
  - 来源：**SCMP**
  - 时间：`260706`
  - 正文：~**680** tok
  - URL：https://www.scmp.com/tech/big-tech/article/3359482/bytedance-and-alibaba-disable-humanlike-ai-custom-agents-new-rules-loom
  - 类型：新模式
  - 要点：
    - **7/6** 字节 **Doubao** 与阿里 **Qwen** 宣布下线可定制人格/情感交互 agent 功能，配合 **7/15** 生效的《人工智能拟人化交互服务管理暂行办法》；Doubao **7/15** 停服、Qwen **7/10** 起分批下线。
    - 豁免：客服机器人、知识问答、职场助手、教研工具等 **非持续情感交互** 场景——coding/agent 工具链与「拟人陪伴」监管分流。
    - 全球 Vibe 对照：agent 产品架构须区分 **task-oriented agent** 与 **anthropomorphic companion**——同一「Agent」标签下合规路径截然不同。

### 监管安全

- **China interim measures on anthropomorphic AI interaction services (effective 260715)**
  - 来源：**GT**
  - 时间：`260706`
  - 正文：~**520** tok
  - URL：https://www.globaltimes.cn/page/202607/1365159.shtml
  - 类型：其他
  - 要点：
    - **7/6** 中国拟人化 AI 交互服务 interim measures **7/15** 生效：针对模拟人格/思维/沟通风格并提供 **持续情感交互** 的服务。
    - 字节/阿里已提前下线 Doubao/Qwen 自定义 agent——亚太 agent 平台须在两周内完成功能审计与数据留存策略调整。
    - 对全球 agent 开发者：出海中国区须将「情感陪伴型」与「生产力型」agent 分拆 SKU。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
