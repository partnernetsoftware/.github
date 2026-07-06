# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260704 07:01` UTC → `260706 07:01` UTC（48h，cron 触发 `2026-07-06T07:01Z`） |
| 本文件更新 | `260706 07:01` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 10（新模型 1 · 新产品 4 · 新模式 5） |
| main 合并 commit | `37c0092` |

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

- **LongCat-2.0 — 1.6T MoE agentic coding model (MIT, 1M ctx)**
  - 来源：**Meituan**
  - 时间：`260705`
  - 正文：~**920** tok
  - URL：https://huggingface.co/meituan-longcat/LongCat-2.0
  - 类型：新模型
  - 要点：
    - **7/5** 美团正式公开 **LongCat-2.0**（此前 OpenRouter 代号 **Owl Alpha** 连续两月调用量前三）：**1.6T** total / **~48B** active MoE，原生 **1M** ctx（LongCat Sparse Attention），**MIT** 许可；训练+推理全程 **5 万+** 国产 AI ASIC 超算，**35T+** tokens 无回滚。
    - 基准（厂商）：SWE-bench Pro **59.5%**、Terminal-Bench 2.1 **70.8%**、SWE-bench Multilingual **77.3%**；API **$0.75/M** in、**$2.95/M** out，缓存读免费；Anthropic-compatible endpoint 三行变量即可接入 **Claude Code**。
    - Vibe 信号：万亿参数 open-weight agentic coder 经 OpenRouter 实战验证后揭面——亚太 frontier 模型从「榜单」进入「全球 harness 默认可选」；权重 Hub 页已上线（上传进行中）。

### 新产品

- **Sakana Fugu — multi-agent orchestrator as single OpenAI-compatible API**
  - 来源：**Sakana**
  - 时间：`260705`
  - 正文：~**780** tok
  - URL：https://github.com/SakanaAI/fugu
  - 类型：新产品
  - 要点：
    - **7/5** 东京 Sakana AI 将 **Fugu** 多代理编排系统以「单模型 API」交付：内部动态调度 **Gemini 3.1 Pro / Claude Opus 4.8 / GPT-5.5** 等 frontier worker，对外仅暴露 Chat Completions + Responses 标准端点。
    - 双档：**Fugu**（低延迟单 worker 路由，可 opt-out 特定模型）与 **Fugu Ultra**（`fugu-ultra-20260615`，递归子任务并行，固定深池）；**1M** ctx；一行安装 `curl -fsSL https://sakana.ai/fugu/install | bash`，`codex-fugu` 快速启动。
    - 基于 ICLR 2026 **TRINITY** + **Conductor** 论文并持续重训协调器——与 Hermes MoA 2.0 形成「开源虚拟模型 vs 闭源 learned orchestrator」双轨。

- **OpenClaw v2026.7.1-beta.2 — GPT-5.6 series & Nemotron Super 1M ctx**
  - 来源：**OpenClaw**
  - 时间：`260705 09:10`
  - 正文：~**640** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.7.1-beta.2
  - 类型：新产品
  - 要点：
    - **7/5** 开源个人 AI 助手 **OpenClaw** `v2026.7.1-beta.2`：新增 **GPT-5.6** 全系 provider 支持；**Nemotron Super** 启用 **1M** ctx 窗口；保留 OpenRouter 显式鉴权头。
    - 跨平台（Any OS / Any Platform）agent 运行时快速跟进 frontier 型号——VibeCoding harness 竞争从「谁有最好 UI」转向「谁最快接上新模型 API」。
    - 与 LongCat-2.0（Claude Code 三变量接入）、Hermes Agent（MoA 虚拟模型）构成 agent 后端「多模型即插即用」周。

- **CachePilot — drop-in AI API caching proxy (20% of savings pricing)**
  - 来源：**CachePilot**
  - 时间：`260706`
  - 正文：~**700** tok
  - URL：https://cachepilot.serveousercontent.com
  - 类型：新产品
  - 要点：
    - **7/6** **CachePilot** 上线：一行改 `base_url` 即可代理 **OpenAI / Anthropic / OpenRouter**；L0 内存 + L1 Redis + 规范化层识别重复 prompt，缓存命中 **<1ms**、零 provider 费用。
    - 定价：**节省额的 20%**（无订阅/最低消费），7 天免费试用；用户自持 API key，请求 SHA-256 哈希追踪。
    - Agent 经济层：长程 agent 重复 system prompt / few-shot 可占 API 账单 **~70%**——中间件缓存成为 VibeCoding 降本与多 agent 并行编排的基础设施选项。

- **AgentGuard v0.6.0 — agent memory poisoning detection (MCP server)**
  - 来源：**Dockfix**
  - 时间：`260705 01:55`
  - 正文：~**620** tok
  - URL：https://github.com/dockfixlabs/agentguard/releases/tag/v0.6.0
  - 类型：新产品
  - 要点：
    - **7/5** **AgentGuard** `v0.6.0` 首发 **ASI-MEMORY-POISON** 检测：扫描向量库（ChromaDB/Pinecone/Weaviate 等）、LangChain Memory、RAG 管线中未净化的持久化写入——区别于单轮 prompt injection，污染 **持续影响** 后续所有 agent 决策。
    - **14** 条规则、**26** 个 memory sink 模式，Python + TS 双语言；含 MCP server 模式，可嵌入 agent CI 流水线。
    - 长程 Vibe agent（mem_put / RAG / conversation buffer）的安全交付物：记忆层从「功能」升级为需门禁的 **信任边界**。

### 新模式

- **Hermes MoA 2.0 — virtual model presets in open-source agent framework**
  - 来源：**Nous**
  - 时间：`260705`
  - 正文：~**860** tok
  - URL：https://www.techtimes.com/articles/319754/20260705/hermes-moa-20-combines-gpt-claude-deepseek-outscore-any-one-model.htm
  - 类型：新模式
  - 要点：
    - **7/5** Nous Research **Hermes Mixture of Agents 2.0**：多 reference model 独立分析 + aggregator 合成，预设以 **virtual model** 出现在 CLI/Telegram/Discord 模型选择器（与 Claude/GPT 并列）；`/moa [prompt]` 单次高质量调用后回退默认模型。
    - 工程细节：reference 输出追加至最新 user turn 保 prompt cache；禁止嵌套 MoA；仅 aggregator 持完整 tool access。内部 HermesBench 预设（GPT-5.5+DeepSeek→Opus aggregator）报 **0.8202** vs Opus 单模 **0.7607**（基准尚未完全公开）。
    - 地缘语境：Fable 5 全球停服 19 天后（**7/1** 恢复），MoA 2.0 将「受限 frontier」重构为「可组装开放组合」——出口管制下的 VibeCoding 架构备选。

- **EdgeBench — log-sigmoid scaling law for 12h+ agent environment learning**
  - 来源：**ByteDance**
  - 时间：`260704`
  - 正文：~**840** tok
  - URL：https://edge-bench.org/
  - 类型：新模式
  - 要点：
    - **7/4** 字节 Seed 发布 **EdgeBench**：**134** 个真实世界超长程任务（软件工程/科学发现/形式数学/游戏等），每任务 **12–72h** 连续 agent 交互 + 多级反馈；开源 **51** 任务 + **SForge** 评测 harness（work/judge 双容器隔离防刷分）。
    - 核心发现：~**38,000** 小时 agent 交互后，性能随交互时长呈 **log-sigmoid** 缩放律（**R²=0.998**）；前沿 agent 环境学习速度约每 **3 个月翻倍**——为「部署后持续学习」提供可量化范式，补传统 pretrain scaling 瓶颈。
    - 12h 榜：**Claude Opus 4.8** **51.3%** > GPT-5.5 **48.4%**；Vibe 信号：agent 评测从 one-shot 基准转向 **学习曲线**——决定「跑多久」可比决定「用哪个模型」更关键。

- **Sovereign agent toolchain bifurcation — enterprise mandates domestic coding agents**
  - 来源：**TC**
  - 时间：`260704 16:32`
  - 正文：~**720** tok
  - URL：https://techcrunch.com/2026/07/04/alibaba-reportedly-bans-employees-from-using-claude-code/
  - 类型：新模式
  - 要点：
    - **7/4** 阿里 reportedly **7/10** 起禁止员工使用 **Claude Code**（高风险软件），改推自研 **Qoder**；背景含 Anthropic 收紧中国实体访问与 anti-distillation 实验（3 月启动、7 月撤下）。
    - 与 GLM-5.2/ZCode、Qoder 内嵌路线同构：**地缘合规** 正成为 enterprise agent 选型第一过滤器——BYOK/自托管 MIT 权重是规避「一夜封禁」的架构答案。
    - VibeCoding 信号：全球 agent 栈分裂为 **西方闭源 harness + 亚太开源模型/IDE** 双轨；工程负责人须把「模型/API 明天是否可用」纳入与 SLA 同级的采购维度。

- **Learned orchestrator vs ensemble MoA — dual multi-model routing paradigms**
  - 来源：**Sakana**
  - 时间：`260705`
  - 正文：~**580** tok
  - URL：https://arxiv.org/abs/2606.21228
  - 类型：新模式
  - 要点：
    - **7/5** 同周 **Sakana Fugu**（learned coordinator，RL 训练路由/委托/验证）与 **Hermes MoA 2.0**（用户配置 reference+aggregator 集成）代表多模型路由两条路径：**黑盒协调器 API** vs **透明可配 ensemble**。
    - Fugu 强调 export-control 韧性（单 vendor 受限时自动绕行）；MoA 强调 prompt cache 友好与 reference 输出可审计——企业选型须在 **性能/合规/可观测** 三角取舍。
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
    - 全球 Vibe 对照：agent 产品架构须区分 **task-oriented agent**（工具调用/代码执行）与 **anthropomorphic companion**（人格/情感依赖）——同一「Agent」标签下合规路径截然不同。

### 监管安全

- **China interim measures on anthropomorphic AI interaction services (effective 260715)**
  - 来源：**GT**
  - 时间：`260706`
  - 正文：~**520** tok
  - URL：https://www.globaltimes.cn/page/202607/1365159.shtml
  - 类型：其他
  - 要点：
    - **7/6** 中国拟人化 AI 交互服务 interim measures **7/15** 生效：针对模拟人格/思维/沟通风格并提供 **持续情感交互** 的服务；关切极端思想传播、隐私泄露、身心健康与用户依赖风险。
    - 字节/阿里已提前下线 Doubao/Qwen 自定义 agent——亚太 agent 平台须在两周内完成功能审计与数据留存策略调整。
    - 对全球 agent 开发者：出海中国区须将「情感陪伴型」与「生产力型」agent 分拆 SKU，避免一刀切合规风险。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
