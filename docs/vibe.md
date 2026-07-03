# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260701 07:02` UTC → `260703 07:02` UTC（48h，cron 触发 `2026-07-03T07:02Z`） |
| 本文件更新 | `260703 07:02` UTC |
| 条目数 | 15 |
| 新模型 / 新产品 / 新模式 | 15（新模型 4 · 新产品 6 · 新模式 5） |
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

- **Claude Fable 5 and Mythos 5 redeployed — global access restored July 1**
  - 来源：**Anthropic**
  - 时间：`260701`
  - 正文：~**1120** tok
  - URL：https://www.anthropic.com/news/redeploying-fable-5
  - 类型：新模型
  - 要点：
    - **7/1** Commerce 解除 export controls 后，**Fable 5** 全球恢复于 Claude.ai、Claude Code、Cowork、API；AWS/GCP/Microsoft Foundry 将陆续重开；**Mythos 5** 限 Glasswing 伙伴。
    - 新 classifier 阻断 Amazon 报告 jailbreak 技术 **>99%**；被拦请求 fallback **Opus 4.8**；Pro/Max/Team/部分 Enterprise 至 **7/7** Fable 5 计入周用量上限 **50%**，之后走 usage credits。
    - 同日发布 **Glasswing jailbreak severity** 四轴共识框架（见「新模式」），标志 frontier cyber 模型经历 **18 日** 全球下架后首次 consumer 级恢复。

- **NVIDIA Nemotron-Labs-TwoTower — open-weight diffusion LM on frozen AR backbone**
  - 来源：**NVIDIA**
  - 时间：`260701`
  - 正文：~**780** tok
  - URL：https://www.marktechpost.com/2026/07/01/nvidia-releases-nemotron-labs-twotower/
  - 类型：新模型
  - 要点：
    - **7/1** NVIDIA 开源 **Nemotron-Labs-TwoTower**：双塔 block-wise AR diffusion，基于冻结 **Nemotron-3-Nano-30B-A3B**（Mamba-2 + Attention + MoE 混合骨干）；denoiser 仅训 **~2.1T** tokens。
    - 单 checkpoint 支持 diffusion / mock-AR / AR 三种解码；默认工作点保留 AR 质量 **98.7%**、吞吐 **2.42×**；**NVIDIA Nemotron Open Model License**，可商用。
    - 对 agent 基础设施意义：高吞吐文本生成不必全量重训 AR 模型——frozen backbone + diffusion denoiser 成为新效率范式，适合 RAG/工具循环中的 bulk generation。

- **Pulpie: Pareto-Optimal Models for Cleaning the Web**
  - 来源：**Feyn**
  - 时间：`260701`
  - 正文：~**820** tok
  - URL：https://huggingface.co/blog/feyninc/pulpie
  - 类型：新模型
  - 要点：
    - **7/1** Feyn 发布 **Pulpie** 开源 HTML 主内容抽取模型族（**210M / 610M / 2.1B**，基于 EuroBERT）：单 forward pass 标注每 block 为 content/boilerplate，无需截图或多模态。
    - **Orange Small**（210M）ROUGE-5 F1 **0.862**，逼近 Dripper 0.6B（0.864）；L4 吞吐 **13.7 pages/sec** vs Dripper **0.68**；清 10 亿页成本约 **$7,900** vs **$159,000**。
    - agent/RAG 场景：web 清洗从「每站启发式/大模型」转向 **encoder 级 foundation extractor**——预训练语料与 agent 上下文管理均可插即用 `pip install pulpie`。

- **Kimi K2.7 Code is generally available in GitHub Copilot**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**640** tok
  - URL：https://github.blog/changelog/2026-07-01-kimi-k2-7-is-now-available-in-github-copilot/
  - 类型：新模型
  - 要点：
    - **7/1** Moonshot **Kimi K2.7 Code**（开源权重，**~1T** MoE / **32B** active、**256K** ctx、原生多模态）在 GitHub Copilot model picker **GA**——Copilot 史上首个可选 **open-weight** 模型；Azure 托管，按 provider list pricing 计费。
    - 逐步 rollout 至 Pro/Pro+/Max；VS Code **1.127+**、Copilot CLI、cloud agent、Mobile、JetBrains 等全表面可选；Business/Enterprise 默认关闭，须 admin 显式开启 policy。
    - 与 **7/1** Copilot browser tools / vision GA 并列：主流 IDE agent 同日接入 closed + open 双轨 frontier coding 模型。

### 新产品

- **Z.ai launches ZCode — Agentic Development Environment for GLM-5.2**
  - 来源：**VB**
  - 时间：`260702`
  - 正文：~**880** tok
  - URL：https://venturebeat.com/technology/z-ai-launches-zcode-to-challenge-cursor-claude-code-and-github-copilot-in-ai-coding
  - 类型：新产品
  - 要点：
    - **7/2** 智谱系 **Z.ai** 发布免费桌面 **ZCode**（macOS/Windows/Linux）：为 **GLM-5.2**（**1M** ctx、长程 agentic coding）定制的 **Agentic Development Environment**，非「IDE + 侧边栏 chat」。
    - 支持 **BYOK** 接入 Claude Code、Codex、Gemini、OpenCode；桌面 + 移动端 Remote + 飞书/微信 Bot 跨设备续跑同一 workspace task；敏感命令须人工确认。
    - 至 **7/31** Coding Plan 订阅享 **1.5×** 配额 bonus、低谷 **0.67×** 系数——中国 frontier 模型首次以专用 ADE 正面挑战 Cursor/Claude Code/Copilot 分发。

- **Browser tools for GitHub Copilot in VS Code are generally available**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**680** tok
  - URL：https://github.blog/changelog/2026-07-01-browser-tools-for-github-copilot-in-vs-code-are-generally-available/
  - 类型：新产品
  - 要点：
    - **7/1** Copilot agent 可在 VS Code 内驱动**真实浏览器**：导航、点击、输入、读 DOM、截屏、跑脚本流；DevTools 内嵌工具栏可人工介入调试。
    - 隐私模型：用户标签须手动 **Share with Agent**；agent 自建标签隔离 session/cookie；camera/mic/location 等敏感权限须逐站人工批准；企业可关 `workbench.browser.enableChatTools` + `chat.agent.allowedNetworkDomains` 域名白名单。
    - 标志 IDE agent 从「读代码」扩展到 **live web app 测试闭环**——与 Cursor computer use、OpenAI computer use 构成 VibeCoding 三大 browser-agent 交付面。

- **Copilot vision is generally available**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**520** tok
  - URL：https://github.blog/changelog/2026-07-01-copilot-vision-is-generally-available/
  - 类型：新产品
  - 要点：
    - **7/1** Copilot **vision** GA：chat 可直接附 **JPEG/PNG/GIF/WebP/PDF**；覆盖 VS Code（ask/plan/agent 模式）、github.com Copilot Chat、Copilot CLI。
    - 全计划默认开启（含 Business/Enterprise），不再需 Editor Preview Features policy；Business/Enterprise 附件保留约 **24h** 用于推理。
    - agent 多模态 harness 标配化：UI mockup、架构图、PDF spec 可直接喂入 agent 循环，降低「截图→描述→代码」摩擦。

- **Introducing new MCP capabilities that turn context into action — Atlassian Rovo MCP**
  - 来源：**Atlassian**
  - 时间：`260701`
  - 正文：~**860** tok
  - URL：https://www.atlassian.com/blog/jira/mcp-enhancements
  - 类型：新产品
  - 要点：
    - **7/1** Atlassian Rovo MCP 日调用 **5M+** tool calls；新增 Jira **写回**：创建 work item、编辑 comment、读 development panel（branch/PR/commit/diff）、Jira Product Discovery 追溯、worklog 捕获（update 本月 rollout）。
    - Teamwork Graph 上下文 shaping：agent 获 **44%** 更准确答案、**48%** 更少 token；支持 Codex/Claude Code/Cursor 等从 IDE/terminal 完成「编码→Jira 闭环」。
    - 标志 enterprise agent 集成从 read-only context 升级为 **system-of-record write-back**——Jira 成为 agentic SDLC 持久状态层。

- **Build agentic full-stack apps with Genkit — Agents API**
  - 来源：**Google**
  - 时间：`260701`
  - 正文：~**760** tok
  - URL：https://developers.googleblog.com/en/build-agentic-full-stack-apps-with-genkit/
  - 类型：新产品
  - 要点：
    - **7/1** Google 发布 **Genkit Agents API**（Beta）：将 message history、tool loop、streaming、persistence、interrupts 打包为单一 **transport-agnostic** 接口；`defineAgent` + `remoteAgent()` 使 server 与 browser 共用同一 `chat()` API。
    - 配套 **FirestoreSessionStore**、**Vercel AI SDK `GenkitChatTransport`**（`useChat` 直连 Genkit agent，原生 HITL interrupts）；v1.39.0 同步引入 `delegate_to_*` 多 agent 编排 middleware。
    - VibeCoding 全栈范式：conversational agent 的重复 plumbing（历史、流式、持久化、前端协议）从「每项目手写」变为 **configure-not-rebuild**——对标 OpenAI Agents SDK harness，但强调 browser↔server 零自定义协议。

- **Enterprise managed-settings.json is generally available**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**600** tok
  - URL：https://github.blog/changelog/2026-07-01-enterprise-managed-settings-json-is-generally-available/
  - 类型：新产品
  - 要点：
    - **7/1** GitHub Enterprise Cloud 可通过 `.github-private` 仓库 `copilot/managed-settings.json` **集中治理** Copilot 客户端：覆盖 `model`、`enabledPlugins`、`extraKnownMarketplaces`、`strictKnownMarketplaces`、`disableBypassPermissionsMode` 等键。
    - 配置在用户认证时拉取、内存缓存、**每小时**刷新；**优先于**用户本地 file-based 配置；当前强制 VS Code + Copilot CLI，Copilot SDK 全客户端扩展中。
    - 与 Cursor **Team MCP marketplaces**（6/30）同构：VibeCoding 企业部署从个人 `mcp.json` / settings 升级为 **admin-curated server-side policy**——agent 模型、插件、市场三路统一门禁。

- **Alibaba Page Agent — in-page DOM GUI agent (MIT)**
  - 来源：**Alibaba**
  - 时间：`260703`
  - 正文：~**740** tok
  - URL：https://github.com/alibaba/page-agent
  - 类型：新产品
  - 要点：
    - **7/3** 阿里开源 **Page Agent**（TypeScript，`npm install page-agent`，**MIT**）：纯 JavaScript **页内** GUI agent，通过 **DOM dehydration** 将页面压缩为 **FlatDomTree** 文本，无需截图/headless browser/多模态模型。
    - **Bring-your-own-LLM**（任意 OpenAI-compatible endpoint）；内置 human-in-the-loop UI；可选 Chrome extension（多标签）与 **MCP Server**（Beta）从外部驱动；衍生自 browser-use 的 DOM 处理与 prompt。
    - 新模式意义：browser automation 从「外部 Playwright/Selenium 控制」转向 **embed copilot in your SaaS**——20-click ERP/CRM 流程变一句自然语言；与 Copilot browser tools（外部驱动）形成 **in-page vs out-of-page** 双轨。

### 新模式

- **ADK Go 2.0 — graph-based workflow engine with built-in HITL**
  - 来源：**Google**
  - 时间：`260701`
  - 正文：~**920** tok
  - URL：https://developers.googleblog.com/why-we-built-adk-20/
  - 类型：新模式
  - 要点：
    - **7/1** Google **ADK Go 2.0** GA：graph-based workflow engine 将 multi-agent 应用建模为 **nodes + edges**（sequential / conditional / fan-out/fan-in / loops）；`LlmAgent` 与 workflow graph 共享统一 node runtime。
    - 内置 **Human-in-the-loop** primitive：任意 node 可 `NewRequestInputEvent` 暂停图执行，跨进程/跨 runtime **durable resume**（与 Python ADK 共享 interrupt 格式）；dynamic nodes 用 plain Go `RunNode()` 做运行时编排。
    - agent 架构信号：从「单 agent + ad-hoc control flow」转向 **deterministic graph + probabilistic LLM steps 混编**——与 Anthropic Dynamic Workflows（脚本编排 subagent）、OpenAI Agents SDK sandbox harness 同构的三方编排竞赛。

- **Copilot CLI auto model selection + AI credit session limits — agent cost governance**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**720** tok
  - URL：https://github.blog/changelog/2026-07-01-copilot-cli-auto-model-selection-routes-based-on-task/
  - 类型：新模式
  - 要点：
    - **7/1** Copilot CLI **Auto** 按任务复杂度（reasoning/code gen/bug diagnosis/tool orchestration）+ 实时模型健康度路由最优模型；付费用户 Auto 享 **10%** AI credits 折扣；尊重 admin model policy。
    - 同日 **session limits**（`/limits` 或 `--max-ai-credits`）：单 session 软顶 AI credits（含 subagent/compaction），达限自动收尾——专为无人值守 automation 设计；CLI **1.0.66+** / SDK **1.0.5+**。
    - VibeCoding 成本范式进化：从 metered 账期到 **per-session budget + auto routing**——agent harness 须内置 spend cap 与 model tier 策略；**7/2** 进一步推出 Copilot agent session streaming（enterprise SIEM 可观测性）。

- **Claude Code Dynamic Workflows GA — Pro users spawn parallel subagents**
  - 来源：**Anthropic**
  - 时间：`260702`
  - 正文：~**840** tok
  - URL：https://claude.com/blog/introducing-dynamic-workflows-in-claude-code
  - 类型：新模式
  - 要点：
    - **7/2** Dynamic Workflows **GA 扩展至 Pro**（原 Max+）：Claude 动态编写 orchestration 脚本，单 session 协调 **数十至数百** 并行 subagent，含 adversarial verification 层；`ultracode` 关键字或 `/config` 启用。
    - 示范案例：Bun **Zig→Rust** 迁移 **96 万行**、**99.8%** 测试通过、**11 天** merge——季度级工程任务压缩至天级；Pro 默认关闭须 `/config` 开启，Enterprise 须 admin 批准。
    - 与 OpenAI Codex（独立 cloud sandbox 并行）对比：Dynamic Workflows 强调 **subagent 共享发现 + 对抗性复核收敛**——适合 migration/audit 等需交叉验证的长程任务，标志 VibeCoding 从「单 agent 循环」进入 **自写 harness 编排** 时代。

- **Cascade sunset July 1 — Devin Local becomes sole local agent; ACP multi-agent IDE**
  - 来源：**Devin**
  - 时间：`260701`
  - 正文：~**560** tok
  - URL：https://blog.vibecoder.me/windsurf-becomes-devin-desktop-what-changes
  - 类型：新模式
  - 要点：
    - **7/1** Cognition **Cascade** 正式下线；**Devin Local** 成为 Devin Desktop（原 Windsurf）唯一本地 agent；旧 Cascade 配置/CI 脚本须迁移，非默认选项可能静默失效。
    - Devin Desktop 以 **Agent Command Center**（Kanban 管理 local+cloud agent）为默认面；**ACP**（Agent Client Protocol）支持 Codex、Claude Agent、OpenCode 等任意 ACP agent 同 IDE 运行。
    - 行业信号：VibeCoding IDE 竞争从「单 agent 能力」转向 **multi-agent orchestration layer + 开放协议（ACP/MCP）**——与 Cursor multi-agent、GitHub Copilot JetBrains native agent（6/30）同构。

- **Glasswing jailbreak severity framework — four-axis scoring replaces ad-hoc shutdowns**
  - 来源：**Anthropic**
  - 时间：`260701`
  - 正文：~**680** tok
  - URL：https://www.anthropic.com/news/redeploying-fable-5
  - 类型：新模式
  - 要点：
    - **7/1** Anthropic 联合 **Amazon、Microsoft、Google** 等 Glasswing 伙伴起草 **jailbreak severity** 共识框架，拟替代 Fable 5 事件中「无标准即全球下架」的 ad-hoc 流程。
    - 四轴评分：**Capability gain**（相对现有工具增量）、**Breadth**（单 technique 覆盖多少 offensive task）、**Ease of weaponization**（prompt 复杂度/重试次数）、**Discoverability**（技术传播难度）。
    - 最 severe 级 jailbreak 将触发 **24/7 monitoring** + 即时 preliminary mitigations；同步启动 **HackerOne** Fable 5 cyber jailbreak 赏金——标志 frontier 模型发布从「能力竞赛」进入 **可量化安全 triage** 时代。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
