# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260702 07:02` UTC → `260704 07:02` UTC（48h，cron 触发 `2026-07-04T07:02Z`） |
| 本文件更新 | `260704 07:02` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 1 · 新产品 7 · 新模式 4） |
| main 合并 commit | `c25c682` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Leanstral 1.5: Proof Abundance for All**
  - 来源：**Mistral**
  - 时间：`260702`
  - 正文：~**920** tok
  - URL：https://mistral.ai/news/leanstral-1-5/
  - 类型：新模型
  - 要点：
    - **7/2** Mistral 发布 **Leanstral 1.5**（**Apache 2.0**）：**119B** MoE / **6B** active，专攻 **Lean 4** 形式化证明与 agentic proof engineering；免费 API 端点 `leanstral-1-5`，权重上 Hugging Face。
    - 基准：miniF2F **100%**；PutnamBench **587/672**；FATE-H **87%** / FATE-X **34%** SOTA；**57** 个开源仓库自动验证发现 **5** 个此前未报告 bug。
    - VibeCoding 信号：首个面向 **定理证明 agent** 的开源 frontier 模型——`vibe --agent lean` + `/leanstall` 一键接入 Mistral Vibe CLI，标志形式验证从研究工具进入日常代码 agent 工作流。

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

- **ClickHouse Agents is now available for Managed Postgres**
  - 来源：**ClickHouse**
  - 时间：`260702`
  - 正文：~**800** tok
  - URL：https://clickhouse.com/blog/clickhouse-agents-managed-postgres
  - 类型：新产品
  - 要点：
    - **7/2** ClickHouse Agents（**6 月** OpenHouse beta，Claude 驱动、基于 LibreChat）扩展至 **Managed Postgres**：英文自然语言查 OLTP 数据、跨 Postgres+ClickHouse 联合查询、性能监控与迁移辅助。
    - 工具面：`run_postgres_select_query`、`get_postgres_metrics`、`list_postgres_slow_query_patterns`；默认 **read-only**；内置 Postgres→ClickHouse 迁移 **skill**（schema 设计、ClickPipes CDC、验证闭环）。
    - 数据 agent 范式：统一 OLTP+OLAP agent 平面——运维/分析 agent 不必分别接两套 SQL 工具链；与 Atlassian Rovo MCP（Jira 写回）同构的 **enterprise data agent** 交付趋势。

- **Copilot agent session streaming is now in public preview**
  - 来源：**GitHub**
  - 时间：`260702`
  - 正文：~**720** tok
  - URL：https://github.blog/changelog/2026-07-02-copilot-agent-session-streaming-is-now-in-public-preview/
  - 类型：新产品
  - 要点：
    - **7/2** GitHub Enterprise Cloud（enterprise managed users）可跨 **VS Code / CLI / cloud agent / JetBrains / Eclipse** 等全 Copilot 客户端流式获取 agent session 数据：prompt、response、tool call。
    - 交付：**SIEM streaming endpoint**（含 **Microsoft Purview** public preview）或 REST `GET /enterprises/{enterprise}/copilot/usage-records`（近 **48h** on-demand）；AI Controls 一键启用。
    - 企业 VibeCoding 可观测性里程碑：agent 循环从「黑盒 token 账单」升级为 **prompt/tool-call 级审计流**——与 Anthropic Enterprise Analytics API（7/2）形成 agent 治理双轨。

- **Giving admins more visibility and control over Claude spend**
  - 来源：**Anthropic**
  - 时间：`260702`
  - 正文：~**860** tok
  - URL：https://claude.com/blog/giving-admins-more-visibility-and-control-over-claude-usage-and-spend
  - 类型：新产品
  - 要点：
    - **7/2** Claude **Enterprise** 新增：按 **SCIM 组/用户** 的 usage+cost 仪表盘（artifacts、files edited、skills/connectors 与成本并列）；**model defaults & entitlements** 控制 Chat/Cowork/Code 默认模型。
    - Claude Code 管理台新增 **Usage** + **Value** 标签（productivity lift、cost per commit，公式可调）；**Analytics API** 对接 Datadog/CloudZero；**75%/90%** spend-threshold 告警 + 用户 **75%/95%** 自助提额。
    - agent 成本治理：长程 agentic 工作 token 不可预测——从 seat 订阅转向 **per-group spend cap + model tier 路由 + 可编程 Admin API**，标志 enterprise agent 部署进入 FinOps 标配阶段。

- **Alibaba Page Agent — in-page DOM GUI agent (MIT)**
  - 来源：**Alibaba**
  - 时间：`260703`
  - 正文：~**740** tok
  - URL：https://github.com/alibaba/page-agent
  - 类型：新产品
  - 要点：
    - **7/3** 阿里开源 **Page Agent**（TypeScript，`npm install page-agent`，**MIT**；**v1.11.0** release）：纯 JavaScript **页内** GUI agent，通过 **DOM dehydration** 将页面压缩为 **FlatDomTree** 文本，无需截图/headless browser/多模态模型。
    - **Bring-your-own-LLM**（任意 OpenAI-compatible endpoint）；内置 human-in-the-loop UI；可选 Chrome extension（多标签）与 **MCP Server**（Beta）从外部驱动。
    - 与 Copilot browser tools（外部 Playwright 驱动）形成 **in-page vs out-of-page** 双轨——SaaS 内嵌 copilot 将 20-click ERP/CRM 流程变一句自然语言。

- **Claude Code v2.1.200 — background agent reliability & permission mode rename**
  - 来源：**Anthropic**
  - 时间：`260703 16:52`
  - 正文：~**680** tok
  - URL：https://github.com/anthropics/claude-code/releases/tag/v2.1.200
  - 类型：新产品
  - 要点：
    - **7/3** Claude Code **v2.1.200**：默认 permission mode 统一为 **Manual**（原 default）；`AskUserQuestion` 不再自动继续，须 `/config` 设 idle timeout。
    - 修复 background session 在 sleep/wake、stall respawn、**daemon.lock** PID 复用、socket auth token 剥离等导致 agent 静默中断的 **7+** 类 bug；tmux 3.4+ 同步终端输出消除闪烁。
    - VibeCoding harness 稳定性：长程 unattended agent 的痛点从「模型能力」转向 **daemon 生命周期与权限 UX**——与 Dynamic Workflows 并行 subagent 编排形成互补。

- **Copilot CLI no longer needs a personal access token in GitHub Actions**
  - 来源：**GitHub**
  - 时间：`260702`
  - 正文：~**560** tok
  - URL：https://github.blog/changelog/2026-07-02-copilot-cli-no-longer-needs-a-personal-access-token-in-github-actions/
  - 类型：新产品
  - 要点：
    - **7/2** Copilot CLI 在 GitHub Actions 可直接用内置 **`GITHUB_TOKEN`**（`copilot-requests: write`），无需长期 **PAT**；AI credits 直接计入组织账单（须启用 org policy）。
    - 成本控制：配合 **cost centers**、billing dashboard、**session limit**（`--max-ai-credits`）约束 workflow 级 spend。
    - CI agent 范式：VibeCoding 从本地 terminal agent 扩展到 **零密钥 GitHub Actions agent loop**——降低企业规模化部署 agent 自动化的运维摩擦。

### 新模式

- **Claude Code Dynamic Workflows GA — Pro users spawn parallel subagents**
  - 来源：**Anthropic**
  - 时间：`260702`
  - 正文：~**900** tok
  - URL：https://code.claude.com/docs/en/workflows
  - 类型：新模式
  - 要点：
    - **7/2** Dynamic Workflows **扩展至 Pro**（v2.1.154+，`/config` 开启）：Claude 动态编写 JavaScript orchestration 脚本，单 run 协调 **数十至数百** 并行 subagent（上限 **1000**），含 adversarial verification；`ultracode` 关键字或 `/effort ultracode` 触发。
    - 内置 **`/deep-research`** bundled workflow：多角 web 搜索→交叉验证→引用报告；脚本可保存至 `.claude/workflows/` 复用；`/workflows` 面板实时查看 phase/agent 进度。
    - 编排竞赛信号：plan 从 LLM context 移入 **可 rerun 脚本**（`agent()` + `pipeline()`）——与 OpenAI Codex cloud sandbox 并行、Google ADK Go 2.0 graph workflow 同构的三方 harness 分化。

- **NVIDIA ASPIRE — agentic skill programming for continual robotics learning**
  - 来源：**NVIDIA**
  - 时间：`260703`
  - 正文：~**780** tok
  - URL：https://arxiv.org/html/2607.00272v1
  - 类型：新模式
  - 要点：
    - **7/3** NVIDIA 联合密歇根/UIUC/伯克利/CMU 发布 **ASPIRE**（Agentic Skill Programming through Iterative Robot Exploration）：code-as-policy agent 自主编写/调试机器人控制程序，将验证通过的修复蒸馏为可复用 **skill library**。
    - 闭环：细粒度 multimodal traces（感知 overlay、grasp 候选、轨迹、碰撞反馈）→ agent 定位失败→进化搜索探索多样修复；LIBERO-Pro 扰动下较基线最高 **+77pt**；零样本 LIBERO-Pro Long **~31%** vs 先验 **~4%**。
    - 跨域 agent 范式：从 VibeCoding 的「软件 agent 写代码」扩展到 **物理世界 agent 写控制策略并累积技能库**——与 CaP-Agent0 等 coding-agent baseline 形成软件/具身双轨。

- **Enterprise agent observability — SIEM streaming for Copilot + Analytics API for Claude**
  - 来源：**GitHub**
  - 时间：`260702`
  - 正文：~**640** tok
  - URL：https://github.blog/changelog/2026-07-02-copilot-agent-session-streaming-is-now-in-public-preview/
  - 类型：新模式
  - 要点：
    - **7/2** 同日 GitHub（Copilot Usage Records streaming）与 Anthropic（Enterprise Analytics API + spend alerts）双双上线 **agent session 级可观测性与成本门禁**。
    - 模式转变：enterprise agent 部署从「开通模型 API」升级为 **SIEM/FinOps 一体化**——prompt、tool call、model tier、group spend 可导出至现有合规栈（Purview、Datadog、CloudZero）。
    - 与 Copilot **managed-settings.json**（7/1）、Claude **model entitlements** 同构：VibeCoding 企业落地三板斧——**策略（模型/插件）+ 可观测（session 流）+ 预算（spend cap/session limit）**。

- **In-page embed copilot vs external browser agent — dual-track web automation**
  - 来源：**Alibaba**
  - 时间：`260703`
  - 正文：~**600** tok
  - URL：https://github.com/alibaba/page-agent
  - 类型：新模式
  - 要点：
    - **7/3** Page Agent 代表 **in-page embed** 路线：DOM dehydration + 纯文本 LLM 推理，在宿主 SaaS 内直接操控 UI，无需 Playwright/截图多模态。
    - 对比 **7/1** Copilot browser tools（VS Code 外置浏览器驱动）与 Gemini Spark macOS（本地文件夹权限）：web agent 三分法——**页内嵌入 / IDE 外驱 / 桌面 OS 级**。
    - 产品架构信号：B2B SaaS 将把 agent 作为 **可嵌入 SDK**（`page-agent` MIT + MCP Beta）而非强迫用户切换 IDE——降低 agentic 自动化的集成门槛。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
