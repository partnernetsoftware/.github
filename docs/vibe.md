# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260602 07:02` UTC → `260604 07:02` UTC（48h，cron 触发 `2026-06-04T07:02Z`） |
| 本文件更新 | `260604 07:02` UTC |
| 条目数 | 16 |
| 新模型 / 新产品 / 新模式 | 16（新模型 5 · 新产品 8 · 新模式 3） |
| main 合并 commit | `4359263` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Building a hill-climbing machine: Launching seven new MAI models**
  - 来源：**MS AI**
  - 时间：`260602`
  - 正文：~**1080** tok
  - URL：https://microsoft.ai/news/building-a-hillclimbing-machine-launching-seven-new-mai-models/
  - 类型：新模型
  - 要点：
    - 微软自研 **MAI** 家族 **7** 款：**MAI-Thinking-1**（旗舰推理，~35B 激活 / 128K 上下文，零蒸馏自训）、**MAI-Code-1-Flash**（**5B** agentic coding，深度绑定 Copilot/VS）、**MAI-Image-2.5**、**MAI-Transcribe-1.5**、**MAI-Voice-2** 等。
    - 分发：**Foundry**、OpenRouter、Fireworks、Baseten；开发者**首次可调权重** fine-tune。
    - 与 Mayo Clinic 共建医疗前沿模型（Mayo 拥有权，验证后经 Azure Foundry 对外）。

- **Introducing Gemma 4 12B: a unified, encoder-free multimodal model**
  - 来源：**Google**
  - 时间：`260603`
  - 正文：~**920** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/
  - 类型：新模型
  - 要点：
    - **12B** 统一架构：**无独立 vision/audio encoder**，图/音直接进 LLM backbone；**Apache 2.0**，Hugging Face / Kaggle 权重。
    - 消费级 **16GB** 本机可跑 agentic 多模态；性能接近 **Gemma 4 26B MoE**，内存约一半；内置 **MTP** drafter 降延迟。
    - 配套 **Gemma Skills** 官方仓库，供 coding agent 生成 Gemma 应用；可上 Gemini Enterprise Model Garden / Cloud Run。

- **Dnotitia Releases DNA 3.0, an Enterprise-Ready AI Language Model Family**
  - 来源：**Dnotitia**
  - 时间：`260604`
  - 正文：~**780** tok
  - URL：https://www.prnewswire.com/news-releases/dnotitia-releases-dna-3-0--an-enterprise-ready-ai-language-model-family-302787871.html
  - 类型：新模型
  - 要点：
    - 开源权重家族 **0.8B–122B-A10B**（含 MoE **35B-A3B**、**122B-A10B**），面向企业 agent/RAG，已上 Hugging Face。
    - 与 **Seahorse Cloud** 集成：企业文档→语义检索→上下文回答→agent 工作流，强调组织数据微调而非裸 base。
    - 延续 DNA 1.0/2.0 韩文与 agent 路线，3.0 强化企业一致性与产品化部署档位。

- **SAR updates its first homegrown AI model**
  - 来源：**ChinaDaily**
  - 时间：`260604`
  - 正文：~**720** tok
  - URL：https://www.chinadaily.com.cn/a/202606/04/WS6a20d570a310d6866eb4c5cc.html
  - 类型：新模型
  - 要点：
    - 香港 **HKGAI V3**：token 压缩效率 **>10×**、agent 连续运行 **~100×**（对比上代）；**Agent Workshop** 单会话最长 **28h**。
    - 面向港府/企业垂直场景（HKChat、HKPilot）；同步以 **ClawNet** 名称开源，便于定制 agent。
    - 代表亚太区域「主权/本地化 agent 平台」与全球 frontier 模型并行迭代。

- **Aion 1.0 Instruct and Aion 1.0 Plan — on-device Windows SLMs**
  - 来源：**Microsoft**
  - 时间：`260603`
  - 正文：~**860** tok
  - URL：https://news.microsoft.com/build-2026-live-blog/microsoft-build-2026-live/
  - 类型：新模型
  - 要点：
    - **Aion 1.0 Instruct**：更小更快 on-device SLM，摘要/改写/意图/无障碍；Edge Insider 预览，**7 月** Hugging Face 开放权重。
    - **Aion 1.0 Plan**：**14B** 推理+工具调用、**32K** 上下文，将随 Windows 内置，支持本地文件/子 agent 编排。
    - 与 **Windows AI APIs**（CPU/NPU）协同，标志微软「云 frontier + 端侧 agent」双轨。

### 新产品

- **Introducing Microsoft Scout: Your always-on personal agent**
  - 来源：**Microsoft**
  - 时间：`260602`
  - 正文：~**680** tok
  - URL：https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/02/introducing-microsoft-scout-your-always-on-personal-agent/
  - 类型：新产品
  - 要点：
    - 首款 **Autopilot** 类 M365 agent：云/桌面/浏览器常驻，Teams 交互，连 Outlook/OneDrive/SharePoint 与 **MCP** 扩展。
    - 基于 **OpenClaw** 开源栈 + **Entra** 身份、Purview DLP、签名供应链与 zero-trust 运行时；策略合规将 **upstream** 贡献 OpenClaw。
    - **Frontier** 实验发布，需 Intune 策略 + GitHub Copilot 许可；对标 Google Gemini Spark 的工作场景 24/7 agent。

- **GitHub Copilot app: The agent-native desktop experience**
  - 来源：**GitHub**
  - 时间：`260602`
  - 正文：~**1180** tok
  - URL：https://github.blog/news-insights/product-news/github-copilot-app-the-agent-native-desktop-experience/
  - 类型：新产品
  - 要点：
    - **Copilot app** 技术预览：**My Work** 并行多仓库 agent 会话；每会话独立 **git worktree**。
    - **Canvas** 双向工作面（计划/PR/终端/浏览器）；**Agent Merge** 自动推进 CI/审查/合并；云/本地 **sandbox**。
    - **Copilot SDK** GA、CLI TUI/语音/`/every` 定时任务；伙伴 **agent apps**（LaunchDarkly、PagerDuty、Miro 等）。

- **Copilot SDK is now generally available**
  - 来源：**GitHub**
  - 时间：`260602`
  - 正文：~**950** tok
  - URL：https://github.blog/changelog/2026-06-02-copilot-sdk-is-now-generally-available/
  - 类型：新产品
  - 要点：
    - **GA**：Node/Python/Go/.NET/**Rust**/**Java** 六语言；稳定 API，嵌入与 Copilot 相同的 agent runtime（规划、工具、多轮、流式）。
    - 自定义工具 + **MCP**、系统提示分段编辑、**OpenTelemetry**、OAuth/GitHub App/BYOK；多客户端共享会话与权限。
    - 订阅用户含 Copilot Free；非订阅者可 BYOK 接入 OpenAI/Foundry/Anthropic 等。

- **Announcing the new Work IQ APIs**
  - 来源：**Microsoft**
  - 时间：`260602`
  - 正文：~**1020** tok
  - URL：https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/02/announcing-the-new-work-iq-apis/
  - 类型：新产品
  - 要点：
    - **6/16 GA**：Chat / Context / Tools / **Workspaces** 四域 API，供外部 agent 以 M365 语义索引、记忆、技能访问邮件/会议/文件/LOB。
    - **10** 个通用 Tools + **MCP** 渐进披露，替代数百细粒度 Graph 工具；按 **Copilot Credits** 计费，admin 成本仪表盘首发。
    - 取代实验性 Copilot Chat API 的生产路径；预览已在 GitHub 开放。

- **Crossmint Launches Agentic Cards API Using Visa Intelligent Commerce and Basis Theory**
  - 来源：**Crossmint**
  - 时间：`260602`
  - 正文：~**820** tok
  - URL：https://www.crossmint.com/announcement/agentic-cards-api-launch-visa-basistheory
  - 类型：新产品
  - 要点：
    - 公开 **agentic card payments API**：美国 Visa 借记/信用持卡人可在 **OpenClaw、Claude Code、Hermes、Zo Computer** 等 agent 内授权支付。
    - **Visa Intelligent Commerce** + **Basis Theory** 保险库；**lobster.cash** 可作为工具安装到现有 agent 平台。
    - 文档：https://docs.crossmint.com/agents/overview — agentic 商务从 demo 进入可集成产品层。

- **Zip Launches AI Superagents and MCP for Procurement**
  - 来源：**Zip**
  - 时间：`260602`
  - 正文：~**920** tok
  - URL：https://www.businesswire.com/news/home/20260602279324/en/Zip-Launches-AI-Superagents-and-Procurement-Native-MCP-Delivering-the-First-Governed-AI-Platform-for-Finance-and-Procurement
  - 类型：新产品
  - 要点：
    - **Zip Superagents** 嵌入采购编排：审合同、解阻塞审批、发票编码、供应商调研；动作在 Zip 内审计。
    - **Zip MCP**（OAuth）把 spend/合同/供应商数据接入 Claude、ChatGPT 等；员工对话内发起采购。
    - 五类 Superagent（Procurement/Contract/AP/Config/Intake）；模型无关 MCP，beta 今夏 GA。

- **Introducing the LogRocket MCP: Take the blindfold off your AI agents**
  - 来源：**LogRocket**
  - 时间：`260602`
  - 正文：~**880** tok
  - URL：https://blog.logrocket.com/introducing-the-logrocket-mcp/
  - 类型：新产品
  - 要点：
    - 托管 MCP **`mcp.logrocket.com/mcp`**（OAuth），注入 **Galileo AI** 会话回放/客服/工单洞察到 Cursor、Claude Code、Codex 等。
    - agent 自动发现 UX/技术问题并路由 coding agent 修复；缩短「观察→PR」闭环。
    - 将「人看 LogRocket」改为 agent 侧 push 诊断与修复建议。

- **Workday Launches New Tools for Developers to Build, Connect, and Verify AI Agents For HR, Finance, and IT**
  - 来源：**Workday**
  - 时间：`260602`
  - 正文：~**980** tok
  - URL：https://newsroom.workday.com/2026-06-02-Workday-Launches-New-Tools-for-Developers-to-Build,-Connect,-and-Verify-AI-Agents-For-HR,-Finance,-and-IT
  - 类型：新产品
  - 要点：
    - **Developer Agent**：在 Claude Code/Cursor/Codex/Antigravity 等环境用自然语言生成跑在 Workday 上的 agent（**AgentSkills**）。
    - **Agent-Ready Tools**：经 **MCP** 暴露 HR/财务业务动作（检索、更新福利、触发审批），继承 Workday 安全/委托/审计。
    - **Agent Passport**：对照 OWASP LLM Top 10、NIST AI RMF、MITRE ATLAS 等发可验证 stamp；**Cisco** 为首 attestation 伙伴；H2 2026 EA/GA。

### 新模式

- **A harness for every task: dynamic workflows in Claude Code**
  - 来源：**Anthropic**
  - 时间：`260602`
  - 正文：~**980** tok
  - URL：https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code
  - 类型：新模式
  - 要点：
    - Claude Code **现场编写 JavaScript harness**（`spawn` 子 agent、选模型、选 worktree），按任务定制编排。
    - 模式库：classify-and-act、fan-out-and-synthesize、adversarial verification、tournament、loop-until-done；触发 **`ultracode`** 或自然语言。
    - 可保存 `~/.claude/workflows` 或 skill 分发；对抗 agentic laziness、自偏好与 goal drift。

- **Expanding Project Glasswing**
  - 来源：**Anthropic**
  - 时间：`260602`
  - 正文：~**900** tok
  - URL：https://www.anthropic.com/news/expanding-project-glasswing
  - 类型：新模式
  - 要点：
    - **Claude Mythos Preview** 网络安全合作从 ~50 扩至 **~200** 机构、**15+** 国，覆盖电力/水务/医疗/通信/硬件等关键基础设施与开源维护者。
    - 伙伴已发现 **>10,000** 高/严重漏洞；强调在 Mythos 级能力广泛扩散前完成修补与披露流程规模化。
    - 代表「高能力 cyber 模型 gated 发布 + 行业联盟」范式，与消费级 Opus 4.8 动态工作流形成互补。

- **OpenClaw enterprise Autopilot（Microsoft Scout）**
  - 来源：**Microsoft**
  - 时间：`260602`
  - 正文：~**620** tok
  - URL：https://commandline.microsoft.com/project-lobster-openclaw-personal-ai-assistant-enterprise-secure/
  - 类型：新模式
  - 要点：
    - 个人 **OpenClaw** 经验产品化为 M365 **Autopilot**：独立 Entra 身份、后台自治、跨 Teams/桌面/浏览器。
    - 容器视为不可信，身份/令牌/策略在 Microsoft 控制面外置；**Agent 365** 统一治理，Purview 延续 DLP 信号。
    - VibeCoding 生态从「本机龙虾」走向「企业可审计的 24/7 工作 agent」，与 Crossmint 支付、Zip 采购 MCP 等同属 agent 基础设施层。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
