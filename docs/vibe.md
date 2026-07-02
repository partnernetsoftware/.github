# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260630 07:00` UTC → `260702 07:01` UTC（48h，cron 触发 `2026-07-02T07:01Z`） |
| 本文件更新 | `260702 07:01` UTC |
| 条目数 | 15 |
| 新模型 / 新产品 / 新模式 | 15（新模型 6 · 新产品 6 · 新模式 3） |
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

- **Introducing Claude Sonnet 5**
  - 来源：**Anthropic**
  - 时间：`260630`
  - 正文：~**980** tok
  - URL：https://www.anthropic.com/news/claude-sonnet-5
  - 类型：新模型
  - 要点：
    - **6/30** Anthropic 发布 **Claude Sonnet 5**（API：`claude-sonnet-5`）：迄今最 agentic 的 Sonnet 档，性能逼近 **Opus 4.8**，较 **Sonnet 4.6** 在 reasoning/tool use/coding/knowledge work 全面提升；Free/Pro 默认模型，Claude Code 与 Platform 同步上线。
    - 定价：首发至 **8/31** **$2/$10** per 1M in/out，之后 **$3/$15**（约为 Opus 4.8 **$5/$25** 的一半）；effort 可调，BrowseComp/OSWorld-Verified 成本曲线部分任务可匹配 Opus 4.8。
    - **6/30** GitHub Copilot 同步 GA Sonnet 5 至 model picker（ZDR）；与 Fable 5 **7/1** 全球恢复并列，标志 Anthropic 双轨（日常 Sonnet + frontier cyber）重新齐备。

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

- **Meituan open-sources LongCat-2.0 — 1.6T MoE agentic coding model**
  - 来源：**VB**
  - 时间：`260630`
  - 正文：~**920** tok
  - URL：https://venturebeat.com/technology/meituan-open-sources-longcat-2-0-the-1-6t-near-frontier-agentic-coding-model-thats-been-leading-openrouter-trained-entirely-on-chinese-chips
  - 类型：新模型
  - 要点：
    - **6/30** 美团开源 **LongCat-2.0**：**1.6T** MoE（每 token 激活 **33B–56B**）、原生 **1M** 上下文、**MIT** 许可；GitHub + Hugging Face + LongCat API 同步上线。
    - 基准：**SWE-bench Pro 59.5**（超 GPT-5.5 **58.6**）、**Terminal-Bench 2.1 70.8**；stealth 模型 **Owl Alpha** 两个月居 OpenRouter 调用量全球前三。
    - 全程在 **50K** 国产 ASIC 集群训练，无 Nvidia GPU 依赖；标准 **$0.75/$2.95** per 1M，promo **$0.30/$1.20**，**cache hit 免费**。

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

- **Introducing TabFM — zero-shot foundation model for tabular data**
  - 来源：**Google**
  - 时间：`260630`
  - 正文：~**720** tok
  - URL：https://research.google/blog/introducing-tabfm-a-zero-shot-foundation-model-for-tabular-data/
  - 类型：新模型
  - 要点：
    - **6/30** Google Research 发布 **TabFM v1.0.0**：将表格分类/回归 reframing 为 ICL 问题，**单次 forward pass** 零样本预测，无需 per-dataset 训练或超参搜索；Hugging Face + GitHub 开源。
    - **TabFM-Ensemble** 变体叠加 cross/SVD features + **32-way** NNLS 集成 + Platt scaling；数周内接入 **BigQuery** `AI.PREDICT` SQL 命令。
    - agent 场景：数据分析 agent 可直接对未见表格做预测，绕过传统 AutoML pipeline——tabular 从「每表训模型」转向 foundation model 即插即用。

- **Kimi K2.7 Code is generally available in GitHub Copilot**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**640** tok
  - URL：https://github.blog/changelog/2026-07-01-kimi-k2-7-is-now-available-in-github-copilot/
  - 类型：新模型
  - 要点：
    - **7/1** Moonshot **Kimi K2.7 Code**（开源权重，**~1T** MoE / **32B** active、**256K** ctx、原生多模态）在 GitHub Copilot model picker **GA**——Copilot 史上首个可选 **open-weight** 模型；Azure 托管，按 provider list pricing 计费。
    - 逐步 rollout 至 Pro/Pro+/Max；VS Code **1.127+**、Copilot CLI、cloud agent、Mobile、JetBrains 等全表面可选；Business/Enterprise 默认关闭，须 admin 显式开启 policy。
    - 与 **6/30** Claude Sonnet 5 Copilot GA 并列：主流 IDE agent 同日接入 closed + open 双轨 frontier coding 模型，呼应 Washington cyber 门控下的开源替代潮。

### 新产品

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

- **Build agents even faster with Gemini Enterprise Agent Platform's remote MCP server**
  - 来源：**Google**
  - 时间：`260630`
  - 正文：~**740** tok
  - URL：https://cloud.google.com/blog/products/ai-machine-learning/gemini-enterprise-agent-platform-remote-mcp-server
  - 类型：新产品
  - 要点：
    - **6/30** Google Cloud 发布 **Gemini Enterprise Agent Platform remote MCP server**：启用 Agent Platform API 即自动开通；外部 agent（Antigravity CLI、Claude Code 等）经 MCP 调用 Model Garden、prompt templates、Colab notebooks 等 **9 类 toolset**。
    - 开放 MCP 标准 + Cloud IAM Deny 治理；**Agent Registry** 集中 catalog skills/tools；IDE 内不离开编辑器即可操作 GCP AI 资源。
    - 与同日 **Nano Banana 2 Lite / Omni Flash** GA 并列：Google 同时推 consumer 多模态模型 + enterprise agent 远程 MCP 桥，形成「云内 Agent Platform ↔ 外部 IDE agent」双端架构。

- **SnapLogic MCP Builder — GA, pipelines to MCP servers in one step**
  - 来源：**SnapLogic**
  - 时间：`260701`
  - 正文：~**620** tok
  - URL：https://sdtimes.com/integration/snaplogic-launches-mcp-builder-simplifying-mcp-creation/
  - 类型：新产品
  - 要点：
    - **7/1** SnapLogic **MCP Builder** GA：从现有 integration pipelines、OpenAPI spec、API Management 服务**一键生成** ready-to-run MCP Server，无需手写 MCP 实现。
    - 配套 Enterprise MCP：Trusted Agent Identity（身份传播+审计）、AI Gateway（流量治理）、**1000+** connectors、deterministic pipeline 执行。
    - 企业 agent 落地瓶颈从「写 MCP」转向「把已有集成暴露为 tool」——integration-iPaaS 厂商正式入场 MCP 供应链。

- **Team MCPs in team marketplaces — Cursor**
  - 来源：**Cursor**
  - 时间：`260630`
  - 正文：~**480** tok
  - URL：https://cursor.com/changelog
  - 类型：新产品
  - 要点：
    - **6/30** Cursor 扩展 **Team Marketplaces**：admin 一次配置 **Team MCP servers**，分发至 cloud agents、Agents Window、IDE、CLI；成员从 Dashboard → Integrations & MCP 一键安装已批准集成。
    - 新增 **organization groups** 细粒度 marketplace 访问控制（叠加 SCIM directory groups）；与 **6/29** iOS cloud agents 公测形成「移动端监督 + 企业 MCP 治理」组合。
    - VibeCoding 企业部署范式：MCP 从个人 `mcp.json` 配置升级为 **admin-curated team marketplace**——对标 GitHub Copilot managed-settings.json（**7/1** GA）。

### 新模式

- **Glasswing jailbreak severity framework — four-axis scoring replaces ad-hoc shutdowns**
  - 来源：**Anthropic**
  - 时间：`260630`
  - 正文：~**680** tok
  - URL：https://www.anthropic.com/news/redeploying-fable-5
  - 类型：新模式
  - 要点：
    - **6/30** Anthropic 联合 **Amazon、Microsoft、Google** 等 Glasswing 伙伴起草 **jailbreak severity** 共识框架，拟替代 Fable 5 事件中「无标准即全球下架」的 ad-hoc 流程。
    - 四轴评分：**Capability gain**（相对现有工具增量）、**Breadth**（单 technique 覆盖多少 offensive task）、**Ease of weaponization**（prompt 复杂度/重试次数）、**Discoverability**（技术传播难度）。
    - 最 severe 级 jailbreak 将触发 **24/7 monitoring** + 即时 preliminary mitigations；同步启动 **HackerOne** Fable 5 cyber jailbreak 赏金——标志 frontier 模型发布从「能力竞赛」进入 **可量化安全 triage** 时代。

- **Copilot CLI auto model selection + AI credit session limits — agent cost governance**
  - 来源：**GitHub**
  - 时间：`260701`
  - 正文：~**720** tok
  - URL：https://github.blog/changelog/2026-07-01-copilot-cli-auto-model-selection-routes-based-on-task/
  - 类型：新模式
  - 要点：
    - **7/1** Copilot CLI **Auto** 按任务复杂度（reasoning/code gen/bug diagnosis/tool orchestration）+ 实时模型健康度路由最优模型；付费用户 Auto 享 **10%** AI credits 折扣；尊重 admin model policy。
    - 同日 **session limits**（`/limits` 或 `--max-ai-credits`）：单 session 软顶 AI credits（含 subagent/compaction），达限自动收尾——专为无人值守 automation 设计；CLI **1.0.66+** / SDK **1.0.5+**。
    - VibeCoding 成本范式进化：从 **6/30** 首个 Copilot 全量 metered 账期（见上轮）到 **per-session budget + auto routing**——agent harness 须内置 spend cap 与 model tier 策略。

- **Cascade sunset July 1 — Devin Local becomes sole local agent; ACP multi-agent IDE**
  - 来源：**Devin**
  - 时间：`260701`
  - 正文：~**560** tok
  - URL：https://blog.vibecoder.me/windsurf-becomes-devin-desktop-what-changes
  - 类型：新模式
  - 要点：
    - **7/1** Cognition **Cascade** 正式下线；**Devin Local** 成为 Devin Desktop（原 Windsurf）唯一本地 agent；旧 Cascade 配置/CI 脚本须迁移，非默认选项可能静默失效。
    - Devin Desktop 以 **Agent Command Center**（Kanban 管理 local+cloud agent）为默认面；**ACP**（Agent Client Protocol）支持 Codex、Claude Agent、OpenCode 等任意 ACP agent 同 IDE 运行。
    - 行业信号：VibeCoding IDE 竞争从「单 agent 能力」转向 **multi-agent orchestration layer + 开放协议（ACP/MCP）**——与 Cursor multi-agent、Canopy orchestrator 同构。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
