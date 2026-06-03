# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260601 07:00` UTC → `260603 07:00` UTC（48h，cron 触发 `2026-06-03T07:00Z`） |
| 本文件更新 | `260603 07:00` UTC |
| 条目数 | 17 |
| 新模型 / 新产品 / 新模式 | 17（新模型 4 · 新产品 8 · 新模式 5） |
| main 合并 commit | `PLACEHOLDER` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **NVIDIA Launches Alpamayo 2 Super Open Reasoning Model for Robotaxis**
  - 来源：**NVIDIA**
  - 时间：`260601`
  - 正文：~**980** tok
  - URL：https://nvidianews.nvidia.com/news/nvidia-alpamayo-2-super-robotaxis
  - 类型：新模型
  - 要点：
    - 开源 **32B** 推理型 **VLA**：跨全栈驾驶栈推理、规划与行动，面向 L4 robotaxi；家族从 10B 扩至 32B。
    - 多任务：推理、自动标注、场景理解、模型批判、蒸馏到小模型；今夏 GitHub 推理代码 + Hugging Face 权重。
    - 配套 **AlpaGym**、**OmniDreams**、Omniverse **NuRec** 与 physical AI agent skills（神经重建、场景生成、闭环 RL）。

- **Mellum2 Goes Open Source: A Fast Model for AI Workflows**
  - 来源：**JetBrains**
  - 时间：`260601`
  - 正文：~**920** tok
  - URL：https://blog.jetbrains.com/ai/2026/06/mellum2-goes-open-source-a-fast-model-for-ai-workflows/
  - 类型：新模型
  - 要点：
    - **12B MoE**（每 token **2.5B** 激活）、Apache 2.0；base / instruct / thinking checkpoint 与 [arXiv:2605.31268](https://arxiv.org/pdf/2605.31268) 技术报告。
    - 面向路由、RAG 摘要、子代理与私有部署；128K 上下文、GQA + 滑动窗口 + MTP 推测解码；同类模型推理速度 **>2×**。
    - 从单任务补全演进为工具调用与多步 agentic 工作流的 **focal model**（非多模态，专精 NL+代码）。

- **MiniMax M3: Frontier Coding, 1M Context, Native Multimodality — All in One Model**
  - 来源：**MiniMax**
  - 时间：`260601`
  - 正文：~**1120** tok
  - URL：https://www.minimax.io/blog/minimax-m3
  - 类型：新模型
  - 要点：
    - 首个将 **前沿 coding/agent**、**1M 上下文**（**MSA** 稀疏注意力）、**原生多模态**（图/视频/桌面操作）合于一体的 **open-weight** 模型；API/Token Plan/MiniMax Code 已上线，权重与技术报告约 **10 天内**开源。
    - 基准：SWE-Bench Pro **59.0%**、Terminal-Bench 2.1 **66.0%**、MCP Atlas **74.2%**；≤512K 与 >512K 分档计价，支持 thinking 开关与 `priority` 服务层。
    - Token Plan 三档（Plus **$20**/月 ~1.7B tokens 等）；标准 API 首周促销约 **$0.3/M** input、**$1.2/M** output（cache）。

- **Building a hill-climbing machine: Launching seven new MAI models**
  - 来源：**MS AI**
  - 时间：`260602`
  - 正文：~**1050** tok
  - URL：https://microsoft.ai/news/building-a-hillclimbing-machine-launching-seven-new-mai-models/
  - 类型：新模型
  - 要点：
    - 微软自研 **MAI** 家族 **7** 款：旗舰推理 **MAI-Thinking-1**、**MAI-Code-1-Flash**（**5B** agentic coding，深度集成 Copilot/VS）、**MAI-Image-2.5**（含 Flash）、**MAI Transcribe-1.5**、**MAI-Voice-2** 等；零蒸馏、干净数据自训。
    - 分发：**Foundry**、OpenRouter、Fireworks、Baseten；开发者**首次可调权重**（fine-tune）。
    - 与 Mayo Clinic 共建医疗前沿模型（Mayo 拥有权，验证后经 Azure Foundry 对外）；配套 Frontier Tuning 与 RLE 强化学习环境。

### 新产品

- **OpenAI models GPT-5.5 and GPT-5.4—and Codex—now on Amazon Bedrock**
  - 来源：**AWS**
  - 时间：`260601`
  - 正文：~**1020** tok
  - URL：https://www.aboutamazon.com/news/aws/bedrock-openai-models
  - 类型：新产品
  - 要点：
    - **GA**：GPT-5.5、GPT-5.4 经 Bedrock 下一代推理引擎 + **OpenAI 兼容 Responses API**；定价与 OpenAI 直客一致、无 AWS 加价，计入云承诺。
    - **Codex** 经 Bedrock 路由（CLI / 桌面 / VS Code），IAM、VPC、加密与现有 AWS 治理一致。
    - **Bedrock Managed Agents**（OpenAI agent harness + AgentCore）与多厂商模型同一控制台选型。

- **openclaw 2026.5.31-beta.4**
  - 来源：**OpenClaw**
  - 时间：`260601 02:04`
  - 正文：~**1050** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.31-beta.4
  - 类型：新产品
  - 要点：
    - **Skill Workshop** Control UI：提案列表/今日动作/修订/文件预览/审查；`skill_workshop` 工具可 apply/reject/quarantine。
    - 官方插件 **`@openclaw/copilot`**（Copilot SDK harness）、**`@openclaw/tokenjuice`**；**Workboard** 多代理编排与 run 跟踪。
    - SQLite 化 iMessage 队列与插件安装索引；Tailscale Serve 绑定 Gateway；MiniMax M3 等 provider 元数据更新。

- **GitHub Copilot is moving to usage-based billing**
  - 来源：**GitHub**
  - 时间：`260601`
  - 正文：~**720** tok
  - URL：https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
  - 类型：新产品
  - 要点：
    - **6 月 1 日**起 Premium Request 改为 **GitHub AI Credits**（1 credit = $0.01）；按 input/output/cached token 与模型 API 价计费。
    - 月费不变（Pro $10、Pro+ $39 等），含等额 credits；**代码补全与 Next Edit 仍不限量**不扣 credits。
    - Business/Enterprise 6–8 月促销加赠 credits；组织级预算与池化用量；agentic 长会话成本与用量对齐。

- **Salt Security launches Salt Code**
  - 来源：**Salt**
  - 时间：`260601`
  - 正文：~**950** tok
  - URL：https://salt.security/press-releases/salt-security-launches-salt-code-the-first-agentic-security-solution-to-enforce-security-policies-inside-ai-coding-assistants
  - 类型：新产品
  - 要点：
    - 在 **Claude Code / Cursor / Copilot / Codex / Gemini CLI / Antigravity** 等助手内通过 **MCP** 实时强制执行安全策略（生成即合规）。
    - Posture Governance Engine 统一代码、控制面配置与运行时；预置 OWASP API、**MCP Security Top 10**、LLM Security、OpenAPI 等策略包。
    - 现有 Salt 客户无额外费用；非客户可通过 EAP（前 100 家）申请，覆盖 CI/CD 到 runtime 全链路。

- **GitHub Copilot app: The agent-native desktop experience**
  - 来源：**GitHub**
  - 时间：`260602`
  - 正文：~**1180** tok
  - URL：https://github.blog/news-insights/product-news/github-copilot-app-the-agent-native-desktop-experience/
  - 类型：新产品
  - 要点：
    - **Copilot app** 技术预览：单一 **My Work** 视图并行管理多仓库 agent 会话、issue、PR 与后台自动化；每会话独立 **git worktree** 隔离。
    - **Canvas** 双向工作面（计划/PR/终端/浏览器/部署状态）；**Agent Merge** 自动推进 CI/审查/合并；云/本地 **sandbox** 与策略管控。
    - **Copilot SDK** GA（Node/Python/Go/.NET/Rust/Java）暴露与 app 相同 runtime；CLI 重设计 TUI、语音、`/every` 定时任务；伙伴 **agent apps**（LaunchDarkly、PagerDuty、Miro 等）。

- **Introducing the LogRocket MCP: Take the blindfold off your AI agents**
  - 来源：**LogRocket**
  - 时间：`260602`
  - 正文：~**880** tok
  - URL：https://blog.logrocket.com/introducing-the-logrocket-mcp/
  - 类型：新产品
  - 要点：
    - 托管 MCP **`mcp.logrocket.com/mcp`**（OAuth），把 **Galileo AI** 会话回放/客服/工单洞察注入 Cursor、Claude Code、Codex 等 agent。
    - 用例：自动发现 UX/技术问题并路由 coding agent 修复、产品研究 agent、客服 agent 还原用户真实操作路径。
    - 将「人去看 LogRocket」改为 agent 侧 **push 诊断与修复建议**，缩短从观察到 PR 的闭环。

- **Zip Launches AI Superagents and MCP for Procurement**
  - 来源：**Zip**
  - 时间：`260602`
  - 正文：~**920** tok
  - URL：https://www.businesswire.com/news/home/20260602279324/en/Zip-Launches-AI-Superagents-and-Procurement-Native-MCP-Delivering-the-First-Governed-AI-Platform-for-Finance-and-Procurement
  - 类型：新产品
  - 要点：
    - **Zip Superagents**：嵌入采购编排平台，可审合同、解阻塞审批、编码发票、调研供应商；动作在 Zip 内审计与治理。
    - **Zip MCP**：采购原生 MCP，经 OAuth 把 spend/合同/供应商数据接入 Claude、ChatGPT 等；员工在对话中即可发起采购请求。
    - 首发五类 Superagent（Procurement / Contract / AP / Config / Intake）；**模型无关** MCP，beta 今夏 GA。

- **AI alone won't change your business. The system running it will.**
  - 来源：**Microsoft**
  - 时间：`260602`
  - 正文：~**1100** tok
  - URL：https://blogs.microsoft.com/blog/2026/06/02/ai-alone-wont-change-your-business-the-system-running-it-will/
  - 类型：新产品
  - 要点：
    - **Build 2026** 统一叙事：Azure + GitHub + Foundry + **Agent 365** + M365/Windows/Security 作为单一 agent 系统（建→上下文→运行→治理→改进）。
    - **Foundry** 为 agent runtime（多模型路由、工具调用、协作）；**Agent 365** + Entra/Purview/Defender 为企业控制面（**Entra Agent ID**、审计、策略）。
    - **Frontier Tuning**：用组织真实 agent trace 在 RLE 中 RL 微调 MAI；Excel 场景称可达 GPT-5.4 级且 **~10×** 更高效。

### 新模式

- **A harness for every task: dynamic workflows in Claude Code**
  - 来源：**Anthropic**
  - 时间：`260602`
  - 正文：~**980** tok
  - URL：https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code
  - 类型：新模式
  - 要点：
    - Claude Code 可**现场编写 JavaScript harness**（`spawn` 子 agent、选模型、选 worktree），按任务定制编排而非固定 SDK 脚本。
    - 模式库：classify-and-act、fan-out-and-synthesize、adversarial verification、tournament、loop-until-done；触发词 **`ultracode`** 或自然语言请求。
    - 对抗 agentic laziness、自偏好与 goal drift；可保存至 `~/.claude/workflows` 或 skill 分发；适合迁移、深度研究、大规模分拣（token 成本高）。

- **JetBrains focal model：大模型 + 专用小模型编排**
  - 来源：**JetBrains**
  - 时间：`260601`
  - 正文：~**540** tok
  - URL：https://huggingface.co/blog/JetBrains/mellum2-launch
  - 类型：新模式
  - 要点：
    - 高延迟敏感步骤（路由、检索摘要、规划校验）用 **Mellum2** 专模，前沿大模型处理复杂推理，降低 token 成本与尾延迟。
    - MoE 仅 2.5B 激活/token，适合高频子代理与本地私有部署；代表 VibeCoding 规模化下的「协调层」而非单模堆叠。
    - 与 IDE / RAG / agent pipeline 解耦，可自托管 fine-tune，填补生产 AI 的吞吐瓶颈层。

- **Copilot agentic 计费：从席位到 token 预算**
  - 来源：**GitHub**
  - 时间：`260601`
  - 正文：~**480** tok
  - URL：https://docs.github.com/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises
  - 类型：新模式
  - 要点：
    - Chat、CLI、**Copilot cloud agent**、Spaces、Spark 等均消耗 AI credits；补全类功能除外。
    - 组织 **池化 credits** + 企业/成本中心/用户预算；耗尽后需显式开启超额计费而非静默降级模型。
    - 倒逼团队为长时 agent 会话建立用量可见性与成本归因（VibeCoding 规模化前提）。

- **OpenClaw Skill Workshop：可审查的技能演化**
  - 来源：**OpenClaw**
  - 时间：`260601 02:04`
  - 正文：~**560** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.31-beta.4
  - 类型：新模式
  - 要点：
    - 技能变更以 **proposal** 提交：扫描/哈希/回滚/隔离（quarantine），Gateway 与 Control UI 人工审查后再 apply。
    - `skill_workshop` agent 工具与 Codex app-server 提示联动，把「写 skill」纳入治理而非直接落盘。
    - 对应 VibeCoding 中「AI 改仓库能力需审计轨迹」的治理范式，与 Salt Code 等外部策略层形成互补。

- **Copilot Canvas + worktree：Agent Experience（AX）**
  - 来源：**GitHub**
  - 时间：`260602`
  - 正文：~**620** tok
  - URL：https://github.blog/news-insights/product-news/github-copilot-app-the-agent-native-desktop-experience/
  - 类型：新模式
  - 要点：
    - **Chat 负责意图与歧义**，**Canvas 负责可检视的执行态**（计划、PR、终端、浏览器）；人与 agent 在同一表面编辑/重排/批准。
    - 每 agent 会话绑定独立 **worktree**，并行多 initiative 互不踩分支；**Agent Merge** 把「生成代码」延伸到 CI/审查/合并闭环。
    - 标志 IDE 从「写代码」转向「指挥多 agent 流水线」的 AX 范式，与 Claude dynamic workflows、MiniMax Agent Team 同向竞争。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
