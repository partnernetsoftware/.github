# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260614 07:01` UTC → `260616 07:01` UTC（48h，cron 触发 `2026-06-16T07:01Z`） |
| 本文件更新 | `260616 07:01` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 2 · 新产品 5 · 新模式 5） |
| main 合并 commit | `191ebba` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Rio 3.5 Open 397B**
  - 来源：**IplanRIO**
  - 时间：`260614`
  - 正文：~**920** tok
  - URL：https://huggingface.co/prefeitura-rio/Rio-3.5-Open-397B
  - 类型：新模型
  - 要点：
    - **Rio 3.5 Open 397B**：里约市政 IT 公司 IplanRIO 基于 Alibaba **Qwen 3.5 397B** 后训练；**397B/17B** MoE、**1,010,000** token 上下文、**MIT** 开源权重。
    - 集成 **SwiReasoning** 推理框架：显式 CoT 与潜空间推理动态切换，兼顾精度与 token 效率；agent 编程、数学、STEM、多语言与多模态基准宣称 SOTA 级开源表现。
    - 代表主权 AI 从国家实验室延伸至**市政开源**赛道；与 GLM 5.2 同期强化「政府召回云模型 → 自托管开源」叙事。

- **GLM-5.2 will be fully open to all GLM Coding Plan users**
  - 来源：**智谱**
  - 时间：`260613 17:21`
  - 正文：~**880** tok
  - URL：https://www.odaily.news/en/newsflash/490177
  - 类型：新模型
  - 要点：
    - **GLM-5.2**：**744B** MoE（**40B** active），可用 **1M** token 上下文（`glm-5.2[1m]` 后缀）；相对 GLM-5.1（200K）上下文 **5×**，集成 **DSA** 稀疏注意力降部署成本。
    - **6/13 17:21** 起向 GLM Coding Plan 全档开放；**Anthropic 兼容 API**（`https://api.z.ai/api/anthropic`）可一行切换 Claude Code/Cline；**MIT 开源权重**计划 **6/16–22** 周释出（Hugging Face `zai-org`）。
    - 发布未附 benchmark；双思考模式 **High/Max**；Fable 5 全球下线后成为 VibeCoding 开发者最易接入的 frontier 级编码替代之一。

### 新产品

- **Surpassing Frontier Performance with Fusion**
  - 来源：**OpenRouter**
  - 时间：`260614`
  - 正文：~**900** tok
  - URL：https://openrouter.ai/blog/announcements/fusion-beats-frontier/
  - 类型：新产品
  - 要点：
    - **OpenRouter Fusion**：compound-model API；并行派发至多 **8** 个 panel 模型（含 web_search/fetch），judge 产出结构化共识/矛盾/盲点分析，writer 合成最终答案。
    - 调用方式：`"model": "openrouter/fusion"` 或 tools 数组 `{ "type": "openrouter:fusion" }`；DRACO 基准上 budget panel（Gemini 3 Flash + Kimi K2.6 + DeepSeek V4 Pro）**64.7%**，逼近 Fable 5 单模 **65.3%** 且成本约半。
    - **6/14** 发布 FAQ：非 Fable 替代品；编码场景作 server tool 按需调用；`x-openrouter-fusion-depth` 防递归；HN **6/15** 热议。

- **Cast AI's Kimchi Coding Becomes the First Autonomous Coding Agent to Offer MiniMax M3**
  - 来源：**Cast AI**
  - 时间：`260615`
  - 正文：~**820** tok
  - URL：https://cast.ai/press-release/minimax-m3-comes-to-kimchi-coding/
  - 类型：新产品
  - 要点：
    - **Kimchi Coding** 成为首个集成 **MiniMax M3** 的自主编码 agent；Early Access 于 **kimchi.dev** 分阶段开放，M3 为默认 builder 模型。
    - M3：**1M** 上下文、**MSA** 稀疏注意力（长上下文算力约降至上一代 **1/20**、解码 **15×** 更快）；SWE-bench Pro **59%**；shadow 评测较纯商业模型基线 **2.5×** 降本且质量持平或更优。
    - 支持 Cast AI 推理云 serverless 或客户 **AWS/GCP/Azure/本地 air-gap** 主权部署；内置 FinOps 仪表盘与硬花费上限，自动终止失控 agentic 循环。

- **What's new in data agents: Supercharging your AI workflows**
  - 来源：**Google**
  - 时间：`260616`
  - 正文：~**950** tok
  - URL：https://cloud.google.com/blog/products/data-analytics/new-data-agents-across-the-agentic-data-cloud
  - 类型：新产品
  - 要点：
    - **Agentic Data Cloud** 批量发布 data agents：**Data Engineering Agent**（GA）、**Data Science / Insights / Deep Research**（preview）、**Looker Dashboard Agent**、**Database Observability / Onboarding** 等。
    - 开发者工具：**Data Agent Kit**（preview）、**Managed MCP Servers** for Databases（GA，AlloyDB/Spanner/Cloud SQL/Bigtable/Firestore）、**MCP Toolbox for Databases 1.0**（GA）、**QueryData** NL→SQL（preview）。
    - **Conversational Analytics** 扩展至 BigQuery/Lakehouse/AlloyDB/Spanner/Cloud SQL；Gemini Enterprise 作业务用户「前门」消费已发布 agent。

- **Agent SDK overview — monthly Agent SDK credit (effective June 15)**
  - 来源：**Anthropic**
  - 时间：`260615`
  - 正文：~**720** tok
  - URL：https://docs.anthropic.com/en/docs/claude-code/sdk
  - 类型：新产品
  - 要点：
    - **6/15** 起 **Agent SDK**、`claude -p` 无头模式、**Claude Code GitHub Actions** 及基于 SDK 的第三方 agent 从订阅额度迁至独立 **Agent SDK credit**（按月、不滚存、按 API 价计费）。
    - 额度约 **Pro $20 / Max 5x $100 / Max 20x $200**；交互式 Claude.ai 聊天与终端内 **Claude Code 会话**仍走原订阅，不受影响。
    - 耗尽后需手动开启 overflow 或切换 API key；标志 Anthropic 将「人机协作」与「无人值守 agent」拆为可计费 SKU。

- **MC1297981 — Agent Registry API transition to Agent 365**
  - 来源：**Microsoft**
  - 时间：`260615`
  - 正文：~**580** tok
  - URL：https://mc.merill.net/message/MC1297981
  - 类型：新产品
  - 要点：
    - **6/15** 起旧版 **agent registry Graph API** 退役；企业须迁移至 **Agent 365（A365）** 驱动的 agent 注册 Graph API（**5/1** 已 GA）。
    - 仅通过旧 API 注册且未重注册的 agent **将停止工作**；管理员可在 M365 管理中心 **All agents** 视图统一观测与治理。
    - 代表 Microsoft 将 agent 管理收敛为单一 SSOT（A365），与 OpenRouter Fusion、Google Managed MCP 形成「平台注册 vs 开发编排」双轨。

### 新模式

- **Municipal sovereign open-weight post-training（市政主权开源后训练）**
  - 来源：**Exame**
  - 时间：`260614`
  - 正文：~**480** tok
  - URL：https://exame.com/inteligencia-artificial/prefeitura-do-rio-lanca-ia-propria-e-supera-outros-modelos-em-analises-de-desempenho/
  - 类型：新模式
  - 要点：
    - **Rio 3.5** 代表「不从头预训练、基于 Qwen 3.5 后训练 + SwiReasoning」的**低成本主权模型**路径（首代 IA 开发约 **R$500k**，宣称较成品方案 **~30×** 便宜）。
    - 与印度 Varya 视频蒸馏、中国 GLM 5.2 开源并列，形成全球「地方政府/市政 IT 发布 frontier 级开源权重」新赛道。
    - VibeCoding 启示：开发者可 fork 市政/区域优化权重，在本土语言与合规场景获得比通用云模型更可控的 agent 底座。

- **Compound multi-model deliberation API（复合多模型审议 API）**
  - 来源：**OpenRouter**
  - 时间：`260614`
  - 正文：~**540** tok
  - URL：https://openrouter.ai/docs/guides/features/plugins/fusion
  - 类型：新模式
  - 要点：
    - Fusion 将 MoA（Mixture of Agents）研究范式产品化为**单 slug 可调用**的 compound model；简单查询自动 bypass panel，复杂问题才触发多模型审议。
    - 开发者可自定义 **analysis_models** panel（1–8 个）与 judge；预算 preset 用开源/中端模型组合逼近 frontier 单模表现，标志 VibeCoding 从「选最强模型」转向「按任务组 panel」。
    - 编码场景推荐作 **server tool** 而非 drop-in 替换：基座模型处理日常编码，架构决策/最佳实践研究时选择性调用 Fusion。

- **'Fix this code' defensive-task-as-jailbreak trigger（防御性任务被认定为 jailbreak 触发召回）**
  - 来源：**Fortune**
  - 时间：`260615 18:35`
  - 正文：~**560** tok
  - URL：https://fortune.com/2026/06/15/fix-this-code-three-words-behind-us-government-shut-down-anthropic-fable-mythos-ai-models-katie-moussouris-open-letter/
  - 类型：新模式
  - 要点：
    - Amazon 安全研究员向政府上报的「jailbreak」实质为 **"Fix this code"** 提示：让 Fable 5 读代码库并修补漏洞——Katie Moussouris（Luta Security）审阅后认为这是**标准防御性工作流**而非 Mythos 专属 uplift。
    - 出口管制逻辑将「向非公民分发」视为出口，Anthropic 无法实时过滤国籍，故 **6/12** 全球下线 Fable 5/Mythos 5；GitHub Copilot 同步暂停 Fable 5，会话回退 **Opus 4.8**。
    - 行业警示：若「发现已知小漏洞」即触发召回标准，将**实质上冻结所有 frontier 新模型部署**；加速企业多源/自托管采购范式。

- **Interactive vs programmatic agent billing split（交互 vs 程序化 agent 计费双轨）**
  - 来源：**Anthropic**
  - 时间：`260615`
  - 正文：~**500** tok
  - URL：https://docs.anthropic.com/en/docs/claude-code/sdk
  - 类型：新模式
  - 要点：
    - **6/15** Anthropic 正式将 Claude 订阅拆为 **交互桶**（聊天、终端内 Claude Code、Cowork）与 **程序化桶**（SDK、`-p`、CI、第三方 agent），两桶独立计量、独立上限。
    - 行业含义：agent 厂商可将「人坐前面写代码」与「无人值守流水线」定价分离；第三方 daemon/headless 工具被明确归入程序化面，无法再蹭订阅无限额度。
    - 与 OpenAI Assistants API 弃用（**8 月**）转向 Agents SDK 的长期架构调整形成对标——订阅补贴 agent 的时代结束。

- **Task-complexity model routing in coding agents（编码 agent 按任务复杂度路由模型）**
  - 来源：**Cast AI**
  - 时间：`260615`
  - 正文：~**620** tok
  - URL：https://cast.ai/press-release/minimax-m3-comes-to-kimchi-coding/
  - 类型：新模式
  - 要点：
    - Kimchi 将企业 AI 采购从「选单一最强模型」转为 **per-step 路由**：简单步骤用开源权重，复杂评估/推理 reserved 给 frontier 或 M3 级模型。
    - 内置 **token 优化 orchestrator** 对生成代码评分并持续反馈，在准确度与 token 消耗间动态平衡；硬花费上限从 API key 到组织级 enforce。
    - WSJ 报道企业正普遍采用「混合 open-weight + 商业 frontier」策略；Kimchi shadow 模式 **2.5×** 降本验证该范式在真实编码流水线可行。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
