# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260623 07:00` UTC → `260625 07:00` UTC（48h，cron 触发 `2026-06-25T07:01Z`） |
| 本文件更新 | `260625 07:00` UTC |
| 条目数 | 16 |
| 新模型 / 新产品 / 新模式 | 16（新模型 6 · 新产品 7 · 新模式 3） |
| main 合并 commit | `e3cf008` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Krea 2 Raw and Turbo — 12B open-weights image generation at 2-second inference**
  - 来源：**Krea**
  - 时间：`260623`
  - 正文：~**1050** tok
  - URL：https://venturebeat.com/technology/enterprise-grade-ai-image-generation-in-2-seconds-is-here-krea-2-raw-and-turbo-available-as-open-weights-under-custom-license
  - 类型：新模型
  - 要点：
    - **6/23** Krea 发布 **Krea 2 Raw**（未蒸馏 mid-training 基座，供 LoRA/微调）与 **Krea 2 Turbo**（Trajectory Distribution Matching 蒸馏，**~2 秒**出图、高美学多样性）两档 **12B** 图像生成权重，Hugging Face 开放下载。
    - **Krea 2 Community License**：≤50 席位免费商用，更大组织须签 Enterprise；所有部署方须实现技术护栏（防 CSAM/NCII/诽谤等）。官方 API 仍独立按 microdollar 计费，与权重发布解耦。
    - 标志 Krea 从多模型 SaaS 聚合器转型为自研模型供应商；与 FLUX.2 等开源路线形成「可微调 Raw + 低门槛 Turbo」双 checkpoint 产品形态。

- **Qwen-AgentWorld-35B-A3B — first native Language World Model across seven agent domains**
  - 来源：**Qwen**
  - 时间：`260624`
  - 正文：~**1180** tok
  - URL：https://venturebeat.com/technology/alibabas-model-never-trained-as-an-agent-and-improved-agent-performance-across-seven-benchmarks
  - 类型：新模型
  - 要点：
    - **6/24** 阿里 Qwen 团队开源 **Qwen-AgentWorld-35B-A3B**（MoE **35B** 总参 / **3B** 激活，**256K** 上下文）及 **AgentWorldBench** 评测集；另有 **397B-A17B** 更大版未公开权重。Apache 2.0。
    - 训练目标反转：不优化「下一步动作」，而预测「环境下一状态」——覆盖 MCP、Search、Terminal、SWE、Android、Web、OS 七域统一架构；基于 **10M+** 真实 agent 轨迹，经 CPT→SFT→RL 三阶段。
    - 受控仿真 RL 使 MCPMark **24.6→33.8**；虚构世界训练迁移真实搜索 WideSearch F1 **34.02→50.31**；世界模型 warm-up 无 agent 微调即提升 BFCL v4 **62.29→71.25**。

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

- **OpenAI Bidi-1 — bidirectional voice model surfacing in ChatGPT (unannounced rollout)**
  - 来源：**TCatalog**
  - 时间：`260623`
  - 正文：~**720** tok
  - URL：https://www.testingcatalog.com/openai-prepares-bidirectional-voice-mode-for-rollout-on-chatgpt/
  - 类型：新模型
  - 要点：
    - **6/23** OpenAI 尚未官宣，但 ChatGPT Web/App 已出现 **Bidi 1**（**Bi-directional**）语音模型选项；部分用户可提前体验——可同时听、说、不打断用户，支持任务中途切换与实时翻译。
    - 三档智力：**Instant / Medium / High**；选中后语音气泡变黄；相较当前 Advanced Voice 显著改善长对话上下文保持与停顿容忍。
    - 渐进 opt-in 发布，EEA 可能延后；Codex 语音升级将随后独立推出；API 开放时间未确认——属「软上线」而非 model card 级正式发布。

- **GPT-5.6 — Codex repo wires model ID, June 25 launch window passes without release**
  - 来源：**OpenAI**
  - 时间：`260625`
  - 正文：~**880** tok
  - URL：https://www.theneuron.ai/explainer-articles/gpt-56-rumors-everything-we-think-we-know/
  - 类型：新模型
  - 要点：
    - **6/23–25** OpenAI **Codex** 仓库 PR #29644 加入 `gpt-5.6` 处理逻辑并列入 `NEVER_DEFAULT_MODELS`；内部代号 **kindle-alpha** 曾在路由短暂出现后撤回；截至 **6/25** 仍无 model card 或 API 上架。
    - Polymarket「6/22–28 发布」概率从月初 **83%** 跌至 **~18%**；「7/31 前发布」仍定价 **~94%**；传闻规格 ~**2M** 上下文、对齐修复、更强 agentic coding。
    - Fable 5 下线后前沿 coding 模型出现空窗；业界预期 ChatGPT 先于 API 24–48h 内开放——但 6/25 传闻发布日已过，正式官宣仍未到来。

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
    - 多代计算平台首步，计划 **2026 年底** 初始部署；标志 OpenAI 从「租云算力」向全栈（产品→模型→芯片）垂直整合，用自家模型加速芯片设计本身。

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
  - 正文：~**920** tok
  - URL：https://www.techtimes.com/articles/318974/20260624/cursor-trains-first-frontier-model-scratch-colossus-15-trillion-parameters.htm
  - 类型：新产品
  - 要点：
    - **6/23–24** Cursor（Anysphere）宣布三项产品：自研 frontier 级模型（**>1.5T** 参数、从零预训练于 xAI **Colossus** **100K+ GPU**，非 Kimi K2.5 底座）、**Origin** 云 Git 平台、**Cursor Mobile** iOS 测试版。
    - **Origin** 面向人机/agent 并发读写：负载测试单仓库 **~22 commits/s**、**296K clones/h**；自动解决 merge conflict、修复 CI、处理 review 评论；秋季 GA，现 waitlist。
    - **Cursor Mobile** 远程管理 agent、解阻塞任务、审阅 agent 截图；标志 VibeCoding 工具链向「自研模型 + agent-native Git + 移动端遥控」垂直整合。

- **Meta Glasses — $299 AI glasses lineup powered by Muse Spark from day one**
  - 来源：**Meta**
  - 时间：`260623`
  - 正文：~**850** tok
  - URL：https://www.meta.com/blog/introducing-meta-glasses-a-range-of-new-styles-from-meta-and-essilorluxottica-starting-at-299/
  - 类型：新产品
  - 要点：
    - **6/23** Meta 与 EssilorLuxottica 发布自有品牌 **Meta Glasses**（非 Ray-Ban/Oakley 标），**$299** 起；无显示屏，含相机、开放耳扬声器、专用 AI 动作键；Kylie Jenner 联名款同步上市。
    - 首发搭载 **Muse Spark**（Meta Superintelligence Labs 首款产品模型）驱动重建版 Meta AI；同日通过 OTA 推送至美加 Ray-Ban Meta / Oakley Meta。
    - 本月新增 **Dynamic Photo**（多帧自动选最佳）；即将支持无屏眼镜行人导航；实时翻译扩展 **14 种语言**（日/中/韩/印地语等）。

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

- **Full-stack inference co-design — model-aware ASIC as competitive moat (Jalapeño)**
  - 来源：**OpenAI**
  - 时间：`260624`
  - 正文：~**560** tok
  - URL：https://openai.com/index/openai-broadcom-jalapeno-inference-chip/
  - 类型：新模式
  - 要点：
    - Jalapeño 标志 frontier lab 从「租 GPU 训推」转向「按自家模型负载定制硅」——OpenAI 用当前服务用户的模型加速芯片设计与优化，形成软件-硬件飞轮。
    - 架构围绕 LLM 推理数据流（减少搬运、平衡算存网）而非通用 GPU 矩阵乘；多代平台路线图暗示推理成本曲线将受自研硅重塑。
    - 对 VibeCoding/agent 生态影响：更低推理延迟与成本将使长时 agent 会话、并行 subagent 编排从「贵到仅限 Enterprise」走向更广泛可用——算力充裕度成为 agent 工作流扩张前提。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
