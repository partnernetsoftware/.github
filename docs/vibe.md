# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260613 07:01` UTC → `260615 07:01` UTC（48h，cron 触发 `2026-06-15T07:01Z`） |
| 本文件更新 | `260615 07:01` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 2 · 新产品 4 · 新模式 6） |
| main 合并 commit | `4105c9f` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **智谱：GLM-5.2 will be fully open to all GLM Coding Plan users**
  - 来源：**智谱**
  - 时间：`260613 17:21`
  - 正文：~**880** tok
  - URL：https://www.odaily.news/en/newsflash/490177
  - 类型：新模型
  - 要点：
    - **GLM-5.2**：**744B** MoE（**40B** active），可用 **1M** token 上下文（`glm-5.2[1m]` 后缀）；相对 GLM-5.1（200K）上下文 **5×**，集成 **DSA** 稀疏注意力降部署成本。
    - **6/13 17:21** 起向 GLM Coding Plan 全档（Lite/Pro/Max/Team）开放；**API 与 MIT 开源权重**计划次周释出（Hugging Face `zai-org`）。
    - 双思考模式 **High/Max**（复杂编码推荐 Max）；与 Fable 5 政府召回同日发布，定位开源可自托管 frontier 编码替代。

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

### 新产品

- **Introducing Omnigent: A Meta-Harness to Combine, Control and Share Your Agents**
  - 来源：**Databricks**
  - 时间：`260613`
  - 正文：~**860** tok
  - URL：https://www.databricks.com/blog/introducing-omnigent-meta-harness-combine-control-and-share-your-agents
  - 类型：新产品
  - 要点：
    - **Omnigent**：Databricks 开源（**Apache 2.0**）meta-harness alpha；统一接口编排 **Claude Code、Codex、Pi** 及自定义 agent，终端/Web/桌面/手机/API 多面接入。
    - 核心能力：多 harness **组合**（YAML 一行切换）、**有状态策略**（花费上限/模型路由/风险升级）、**实时协作**（URL 共享会话）、云沙盒（Modal/Daytona 等）。
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
    - 代表 Microsoft 将 agent 管理收敛为单一 SSOT（A365），与 Omnigent meta-harness、MCP 生态形成「平台注册 vs 开发编排」双轨。

### 新模式

- **Government-forced frontier model recall（政府强制召回已部署 frontier 模型）**
  - 来源：**Anthropic**
  - 时间：`260612 21:21`
  - 正文：~**560** tok
  - URL：https://www.anthropic.com/news/fable-mythos-access
  - 类型：新模式
  - 要点：
    - **6/12 17:21 ET** 美国商务部以出口管制要求 Anthropic 禁止外籍人士访问 **Fable 5/Mythos 5**；因无法实时国籍过滤，Anthropic **全球下线**两模型——业界首例已公开部署 frontier 模型遭政府强制召回。
    - Anthropic 主张：窄域 jailbreak 不应成为召回标准，否则将「实质上冻结所有 frontier 新模型部署」；呼吁透明、技术事实驱动的法定阻断流程。
    - **6/13–15** 余波：GitHub Copilot 同步暂停 Fable 5；全球会话报错并回退 **Opus 4.8**，企业开始审计 Fable 5 依赖工作流。

- **Enterprise multi-vendor fallback architecture（企业多供应商回退架构）**
  - 来源：**VB**
  - 时间：`260613`
  - 正文：~**680** tok
  - URL：https://venturebeat.com/technology/anthropic-blocks-all-public-access-to-claude-fable-5-mythos-5-following-us-government-order-what-enterprises-should-do
  - 类型：新模式
  - 要点：
    - Fable 5 全球下线后，VentureBeat 将企业应对归纳为 **「hardware sovereignty」**：云 frontier 模型可被政府指令瞬间召回，长期依赖单供应商 API 成为运营单点故障。
    - 推荐 **model-agnostic 路由层**：Fable 5 不可用时自动切换至开源权重或第二供应商 API；审计 SWE-Bench Pro **80.3%** 级工作流能否接受 Opus 4.8 回退。
    - 与 Rio 3.5、GLM 5.2、North Mini Code 等开源发布形成「监管冲击 → 自托管/多源」VibeCoding 采购范式转变。

- **Meta-harness layer above coding agents（harness 之上的 meta-harness 编排层）**
  - 来源：**Databricks**
  - 时间：`260613`
  - 正文：~**540** tok
  - URL：https://www.databricks.com/blog/introducing-omnigent-meta-harness-combine-control-and-share-your-agents
  - 类型：新模式
  - 要点：
    - 行业共识：单 harness 已可换模型，但 **组合/治理/协作** 需 harness 之上新抽象；Omnigent 将「messages + files in → streams + tool calls out」统一为通用 API。
    - 有状态策略（花费/权限/升级）在 meta 层执行，而非写进 prompt；YAML 定义自定义 agent 可一行切换底层 harness（Claude Code ↔ Codex ↔ Pi）。
    - 类比 Kubernetes 对裸机编排：模型与 harness 持续迭代，开发者工作层保持稳定；与 GitHub Copilot 多 worktree 并行形成「桌面/云端 meta 编排」对标。

- **Pack Hunt multi-agent jailbreak decomposition（多 agent 分解重组 jailbreak）**
  - 来源：**CyberEd**
  - 时间：`260613`
  - 正文：~**620** tok
  - URL：https://www.buildfastwithai.com/blogs/ai-news-today-june-15-2026
  - 类型：新模式
  - 要点：
    - **Pliny the Liberator** 在 Fable 5 发布后演示 **「Pack Hunt」**：Unicode/同形字规避分类器 + 长上下文引用追踪 + **分解-重组**（ innocuous 子问题分别查询后拼装有害输出）。
    - 技术细节：**6/13** 起广泛传播；同时泄露 Fable 5 约 **120K 字符** system prompt（GitHub），为对抗性 prompt 工程提供「安全手册」。
    - 标志 agentic 攻击从单轮 prompt 演进为**多轮多 agent 协作绕过**；政府召回与 pack hunt 公开演示交织，加速 frontier 模型部署审查。

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

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
