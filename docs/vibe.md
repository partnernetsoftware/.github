# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260622 07:00` UTC → `260624 07:00` UTC（48h，cron 触发 `2026-06-24T07:00Z`） |
| 本文件更新 | `260624 07:00` UTC |
| 条目数 | 16 |
| 新模型 / 新产品 / 新模式 | 16（新模型 7 · 新产品 6 · 新模式 3） |
| main 合并 commit | `9baf233` |

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

- **Pulsar 16B — 30B-class open reasoning at half the parameters (NVIDIA Nemotron)**
  - 来源：**Multiverse**
  - 时间：`260623 09:00`
  - 正文：~**780** tok
  - URL：https://www.globenewswire.com/news-release/2026/06/23/3315999/0/en/Multiverse-Computing-Launches-Pulsar-16B-in-collaboration-with-NVIDIA-Frontier-Grade-Reasoning-at-Half-the-Parameters.html
  - 类型：新模型
  - 要点：
    - **6/23** 西班牙 **Multiverse Computing** 发布 **Pulsar 16B**：**16.15B** 总参数、**3.1B** 激活的 Hybrid Mamba2-Transformer MoE 开源推理模型，基于 NVIDIA **Nemotron-3-Nano-30B** 经 CompactifAI 压缩，无需从头重训。
    - 宣称达到 30B 级前沿推理性能；提供 BF16/FP8/NVFP4 精度；Hugging Face **Apache 2.0** 开源，支持 vLLM/Transformers 推理与 tool calling。
    - NVIDIA 独立复现评测；标志模型压缩技术让主权部署场景可用更小硬件跑前沿推理。

- **Datalab lift — 9B open-weights vision model for schema-driven JSON extraction**
  - 来源：**Datalab**
  - 时间：`260623`
  - 正文：~**850** tok
  - URL：https://www.marktechpost.com/2026/06/23/datalab-releases-lift-a-9b-open-weights-vision-model-that-extracts-structured-json-from-pdfs-using-schemas/
  - 类型：新模型
  - 要点：
    - **6/23** Datalab 发布 **lift**：**9B** 开源视觉模型，直接读 PDF/图像并按用户 JSON Schema 做约束解码输出结构化字段；训练 abstention 对缺失字段返回 null 而非幻觉。
    - 字段准确率 **90.2%**（自托管模型最高），整文档准确率 **20.9%**；代码 Apache 2.0，权重 modified OpenRAIL-M；支持 HuggingFace 本地与 vLLM Docker 生产部署。
    - 延伸 chandra/marker/surya OCR 工具链至 schema 驱动抽取；与同日 Mistral OCR 4 形成「自托管抽取 vs 托管结构化 API」对照。

- **Baidu Unlimited-OCR — MIT open weights for one-shot multi-page PDF parsing**
  - 来源：**Baidu**
  - 时间：`260622`
  - 正文：~**720** tok
  - URL：https://explainx.ai/blog/baidu-unlimited-ocr-one-shot-long-horizon-parsing-2026
  - 类型：新模型
  - 要点：
    - **6/22** 百度发布 **Unlimited-OCR**：**MIT** 开源，**32,768** token 上下文，单次前向完成整份 PDF/多页扫描解析，无需分块再拼接；GitHub 24h 内获 **1.8k** stars。
    - Hugging Face `baidu/Unlimited-OCR` + ModelScope；附 SGLang wheel 与 `infer_multi` 批处理；arXiv `2606.23050`。
    - 与次日 Mistral OCR 4 对比：Unlimited-OCR 胜在长文档自托管一次推理，Mistral 胜在 bbox/块类型/置信度结构化输出。

- **Mistral OCR 4 — bounding boxes, typed blocks, and confidence scores**
  - 来源：**Mistral**
  - 时间：`260623`
  - 正文：~**680** tok
  - URL：https://thecircuitry.to/article/mistral-ocr-4-featuring-bounding-boxes-and-typed-block-classification-mqqt4xhw
  - 类型：新模型
  - 要点：
    - **6/23** Mistral 发布 **OCR 4**：紧凑文档模型，输出标题/表格/公式/签名等 typed block 分类 + 页/词级 bbox 与置信度；支持 PDF/DOC/PPT/ODF。
    - API **$4/1k pages**（Batch API 半价）；接入 **Mistral Search Toolkit** 公测作为 RAG 摄取层；企业可单容器自托管满足数据驻留。
    - 面向 agentic 原语（表单填写、合规检查）与语义分块索引；与 Baidu Unlimited-OCR 同日窗口形成开源长文档 vs 托管结构化两条路线。

- **GPT-5.6 — Codex repo wires model ID, Polymarket odds collapse (still unreleased)**
  - 来源：**OpenAI**
  - 时间：`260623`
  - 正文：~**920** tok
  - URL：https://www.proactiveinvestors.co.uk/companies/news/1094317/traders-abandon-bets-on-a-gpt-5-6-launch-this-week-1094317.html
  - 类型：新模型
  - 要点：
    - **6/23** OpenAI 公开 **Codex** 仓库 PR #29644 加入 `gpt-5.6` 处理逻辑并列入 `NEVER_DEFAULT_MODELS`，阻止 staged rollout 时自动设为默认；尚无 model card 或 API 上架。
    - Polymarket「6/22–28 发布」概率从月初 **83%** 跌至 **18%**；「7/31 前发布」仍定价 **94%**；内部代号 **kindle-alpha** 曾在 Codex 路由短暂出现后被撤回。
    - 传闻规格：~**2M** 上下文、对齐修复、更强 agentic coding；Fable 5 下线后前沿 coding 模型出现空窗，但本周官宣仍未到来。

### 新产品

- **Claude Tag — persistent multiplayer AI teammate in Slack (Opus 4.8)**
  - 来源：**Anthropic**
  - 时间：`260623`
  - 正文：~**1050** tok
  - URL：https://www.anthropic.com/news/introducing-claude-tag
  - 类型：新产品
  - 要点：
    - **6/23** Anthropic 发布 **Claude Tag**：Slack 内常驻共享 AI 队友，频道内 `@Claude` 委派任务；基于 **Opus 4.8**，Claude Enterprise/Team 公测可用，取代旧 Claude in Slack（**8/3** 退役）。
    - 组织级单一身份 + 管理员按频道限定工具/代码库/数据源；支持 ambient 主动跟进、跨频道记忆、异步长任务与定时自驱；Anthropic 内部产品团队 **65%** 代码经 Tag 生成。
    - 与 Claude Code 演进关系：从单人 IDE agent 扩展为多人协作层；计划数周内扩展至 Slack 以外平台。

- **Cursor proprietary model + Origin Git platform + Cursor Mobile iOS beta**
  - 来源：**Cursor**
  - 时间：`260623`
  - 正文：~**880** tok
  - URL：https://the-decoder.com/cursor-announces-its-own-ai-model-a-new-git-platform-and-a-mobile-app/
  - 类型：新产品
  - 要点：
    - **6/23** Cursor（Anysphere）宣布三项产品：自研 frontier 级模型（从零训练、非开源底座，算力为前代 Composer **10–20×**，数周内出货）、**Origin** 云 Git 平台、**Cursor Mobile** iOS 测试版。
    - **Origin** 面向人机/agent 并发读写：负载测试数千 agent 同时读写单仓库，自动解决 merge conflict、修复 CI 失败、处理 review 评论；内部与合作伙伴已用，秋季公开。
    - **Cursor Mobile** 远程管理 agent、解阻塞任务、审阅 agent 截图；标志 VibeCoding 工具链向「自研模型 + agent-native Git + 移动端遥控」垂直整合。

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

- **Zafin AIOS — agent orchestration control plane for regulated institutions**
  - 来源：**Zafin**
  - 时间：`260623`
  - 正文：~**750** tok
  - URL：https://www.prnewswire.com/news-releases/zafin-launches-aios-an-end-to-end-platform-to-orchestrate-and-govern-agentic-work-302806892.html
  - 类型：新产品
  - 要点：
    - **6/23** 金融科技平台商 **Zafin** 发布 **AIOS**：面向银行/保险等受监管机构的端到端 agent 编排与控制平面，统一调度自有与第三方已注册 agent、底层模型与工具调用。
    - 内置企业护栏、成本管控与 **proof-of-work** 审计链；覆盖从业务运营到软件交付全路径；推出 **AIOS Accelerator** 限时计划助机构从实验迈向受控 agentic 生产。
    - Deloitte 调查显示仅 **21%** 组织具备成熟自治 AI 治理——AIOS 定位填补「任务级 AI 生产力→跨工作流运营产能」缺口。

- **LumApps AI Employee Hub — workforce-wide agent discovery and orchestration**
  - 来源：**LumApps**
  - 时间：`260623`
  - 正文：~**680** tok
  - URL：https://www.prnewswire.co.uk/news-releases/lumapps-launches-the-ai-employee-hub-to-accelerate-ai-adoption-302807174.html
  - 类型：新产品
  - 要点：
    - **6/23** 员工体验平台 **LumApps** 发布 **AI Employee Hub**：覆盖通讯、HR、IT、运营等日常业务流程的 agent 与服务目录，让员工无需 IT 技能即可发现、创建、编排数字劳动力。
    - 集成 Google Workspace / Microsoft 365；面向 desk/frontline/分布式团队；已服务 **1000 万+** 用户（Zapier、Genuine Parts 等）。
    - 标志 enterprise agent 从「IT 部门部署」转向「员工自助编排」——people-first 企业 AI 采用路径。

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

- **Ambient multiplayer teammate — org-scoped shared agent with channel memory (Claude Tag)**
  - 来源：**Anthropic**
  - 时间：`260623`
  - 正文：~**620** tok
  - URL：https://venturebeat.com/technology/anthropic-launches-claude-tag-replacing-its-slack-app-with-a-persistent-ai-teammate-that-learns-monitors-and-works-autonomously
  - 类型：新模式
  - 要点：
    - Claude Tag 将 agent 从「单人私聊工具」变为「频道内共享队友」：组织级身份、按频道隔离记忆与工具权限，任何人可接续他人发起的线程。
    - **Ambient** 模式主动监控频道上下文、标记遗漏任务、跨工具拉取相关信息——从 on-demand 问答演进为 always-on 协作参与者。
    - 对比 Microsoft Copilot 横向铺全应用栈，Anthropic 选择先深耕 Slack 单表面：用持久 presence + 跨频道记忆积累机构知识，再扩展平台。

- **Document AI bifurcation — self-hosted long-horizon parsing vs managed structured extraction**
  - 来源：**Baidu**
  - 时间：`260622`
  - 正文：~**540** tok
  - URL：https://explainx.ai/blog/baidu-unlimited-ocr-one-shot-long-horizon-parsing-2026
  - 类型：新模式
  - 要点：
    - **6/22–23** 百度 Unlimited-OCR（MIT 开源、整 PDF 一次推理）与 Mistral OCR 4（API $4/1k pages、bbox+块分类+置信度）同日窗口发布，框定 2026 文档 AI 两极。
    - 自托管路线：数据驻留、离线、高吞吐批处理、schema/长文档一次过；托管路线：per-field 验证、引用溯源、低资源语言、agentic 表单/合规原语。
    - 对 VibeCoding/RAG 影响：agent 文档摄取层选型从「统一 OCR API」变为按合规/精度/成本三角匹配路线，而非单一默认方案。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
