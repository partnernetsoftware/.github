# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260618 07:00` UTC → `260620 07:00` UTC（48h，cron 触发 `2026-06-20T07:00Z`） |
| 本文件更新 | `260620 07:00` UTC |
| 条目数 | 14 |
| 新模型 / 新产品 / 新模式 | 14（新模型 4 · 新产品 6 · 新模式 4） |
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

- **Poolside releases Laguna M.1 open weights — 225B-A23B MoE, 256K context**
  - 来源：**Poolside**
  - 时间：`260618`
  - 正文：~**920** tok
  - URL：https://huggingface.co/collections/poolside/laguna-m1
  - 类型：新模型
  - 要点：
    - **6/18** Poolside 在 Hugging Face 开源 **Laguna M.1** base + post-trained 权重（**Apache 2.0**）；**225B** 总参、**23B** active/token MoE，**256K** 上下文，面向 agentic 编码与工具调用。
    - 同批在 OpenRouter 上线付费端点；**XS.2** 与 **Laguna M.1** 免费 API 仍可用，标志 Poolside「开源权重为默认」策略。
    - 与 GLM-5.2、Nemotron 3 Ultra 同期进入 Hermes Agent 等开源 harness 模型列表，强化「编码 agent 模型多极」格局。

- **Bosun v1.1 — programmable relational judge with directional edges**
  - 来源：**Hanno**
  - 时间：`260618`
  - 正文：~**780** tok
  - URL：https://huggingface.co/blog/Hanno-Labs/bosun-1-1
  - 类型：新模型
  - 要点：
    - **6/18** **Bosun v1.1** 发布：**Bosun-4B**（0.6B XS 同步）：用自然语言规则 + 事实对 → 校准分数 **[0,1]**，服务 agent 记忆图谱去重与冲突检测。
    - 新增**有向边**判断（supersedes / depends-on / supports / contradicts）；PAWS 上 AUROC **0.91** 超 gemini-3.1-flash-lite（0.81）；WarrantBench 可编程性 **0.945** vs LLM **0.575**。
    - **Apache 2.0**；GGUF 本地 CPU/Apple Silicon 推理；填补「agent 记忆 judgment layer」而非通用 chat 模型空白。

- **Embodied-Reasoner: ZJU/CAS/Alibaba open-source embodied reasoning model**
  - 来源：**ZJU**
  - 时间：`260618`
  - 正文：~**850** tok
  - URL：https://github.com/zwq2018/embodied_reasoner
  - 类型：新模型
  - 要点：
    - 浙大+中科院软件所+阿里达摩院联合开源 **Embodied-Reasoner**（**2B/7B**）：多模态具身推理，AI2-THOR 任务成功率 **80.96%**，超 OpenAI o1（71.73%）与 Claude-3.7（67.70%）。
    - 能力：视觉搜索、空间推理、自我纠错；完整训练数据与代码公开（arXiv:2503.21696）。
    - 将 o1 式深度思考引入**交互式物理任务**，区别于纯文本 coding agent 模型赛道。

- **Fable 5 / Mythos 5 remain offline — Seoul signals restoration, refund deadline June 20**
  - 来源：**Anthropic**
  - 时间：`260618`
  - 正文：~**1050** tok
  - URL：https://www.anthropic.com/news/seoul-office-partnerships-korean-ai-ecosystem
  - 类型：新模型
  - 要点：
    - **6/12** 美国商务部出口管制令要求切断外国国民对 **Claude Fable 5**（`claude-fable-5`）与 **Mythos 5** 的访问；Anthropic 为全球合规**全量下线**两模型，API 现返回不可用错误。
    - **6/18** 首尔办公室开幕：国际业务负责人 Chris Ciauri 称「**未来数日内**非常有信心恢复可用」；同日与韩国科学技术信息通信部签 MOU。
    - **6/20** 为 **6/9–14** 订阅用户退款截止日；与 OpenRouter 按自主度分层计费、Google 消费级 Antigravity 硬切形成「前沿模型政府召回」先例。

### 新产品

- **Enterprise-Managed Authorization for MCP is now stable**
  - 来源：**MCP**
  - 时间：`260618`
  - 正文：~**980** tok
  - URL：https://blog.modelcontextprotocol.io/posts/enterprise-managed-auth/
  - 类型：新产品
  - 要点：
    - **6/18** MCP **EMA（Enterprise-Managed Authorization）** 扩展达 **stable**：组织经 IdP 集中授权 MCP 服务器，员工 SSO 后**零触控**获得已批准连接器，无需逐服务器 OAuth 同意。
    - 底层 **ID-JAG**（Identity Assertion JWT Authorization Grant）；首发 IdP **Okta**（Cross App Access）；客户端 **Claude/Code/Cowork**、**VS Code**；服务端 Asana/Atlassian/Canva/Figma/Granola/Linear/Supabase。
    - 撤销在 IdP 层一次生效，解决企业部署 MCP「identity dark matter」痛点。

- **Claude Code Artifacts (beta) — live shareable pages from agent sessions**
  - 来源：**Anthropic**
  - 时间：`260618`
  - 正文：~**950** tok
  - URL：https://code.claude.com/docs/en/artifacts
  - 类型：新产品
  - 要点：
    - **6/18** **Claude Code Artifacts** beta：**Team/Enterprise** 可将 CLI/桌面端 coding session 发布为**实时更新**的托管 HTML 页（PR walkthrough、incident dashboard、架构图等），同 URL 版本历史可回滚。
    - 聚合 session 上下文（代码库、连接器、对话）；严格 **CSP** 禁止外网请求，单页上限 **16 MiB**——「工作捕获」非可部署应用。
    - 对标 OpenAI Codex **Sites**；将 VibeCoding 产出从终端 scrollback 解放为组织内可分享工件。

- **Introducing Claude Agent for Jira**
  - 来源：**Atlassian**
  - 时间：`260618`
  - 正文：~**920** tok
  - URL：https://www.atlassian.com/blog/company-news/claude-agent-for-jira
  - 类型：新产品
  - 要点：
    - **6/18** **Claude Agent for Jira** 上架 Atlassian Marketplace：基于 Anthropic **Claude Managed Agents** 基础设施，可将 Jira 工单直接**指派给 Claude**。
    - 闭环：读取验收标准/目标仓库/工程规范 → Anthropic 隔离沙箱克隆代码库、独立分支实现 → 自动开 **GitHub draft PR** 并流式回写 Jira 工单状态；人工保留 review/merge 控制权。
    - 适用 Jira Cloud Standard/Premium/Enterprise + **Rovo**；本地 IDE 侧可接 Atlassian **MCP server** 或 Teamwork Graph CLI 双向同步 Confluence 规格。

- **Docusign Launches Slack App — agreement intelligence via MCP**
  - 来源：**Docusign**
  - 时间：`260618`
  - 正文：~**880** tok
  - URL：https://www.docusign.com/company/news-center/docusign-launches-slack-app-to-bring-agreement-intelligence-and-agentic-contract-workflows-to-every-team
  - 类型：新产品
  - 要点：
    - **6/18** Docusign **Slackbot** 应用上架 Slack Marketplace：经 **MCP** 连接 **Docusign IAM** 平台，由 **Iris AI** 引擎驱动。
    - 自然语言查询合同义务/续约/风险条款；在 Slack 内触发审批、签署、跟进；与 Salesforce 数据联动生成协议。
    - 标志「协议智能」从独立 SaaS 迁入**对话界面 + MCP 标准接线**的 agentic 工作流。

- **An important update: Transitioning Gemini CLI to Antigravity CLI**
  - 来源：**Google**
  - 时间：`260618`
  - 正文：~**900** tok
  - URL：https://developers.googleblog.com/en/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
  - 类型：新产品
  - 要点：
    - **6/18** 起 **Gemini CLI** 与 Gemini Code Assist IDE 扩展对 Pro/Ultra/免费个人用户**停止服务**；GitHub Code Assist 同日禁新装、数周内停请求。
    - 继任者 **Antigravity CLI**（`agy`，Go 闭源单二进制）：与 Antigravity 2.0 共享 agent harness；保留 Skills/Hooks/Subagents/Extensions（改 Antigravity plugins）；支持 `agy plugin import gemini` 迁移。
    - 企业 **Code Assist Standard/Enterprise** 与 GCP GitHub 许可**保留 Gemini CLI**；API key 用户仍可用；标志 Google 将消费级 VibeCoding 终端收敛至闭源多 agent 平台。

- **Hermes Agent v0.17.0 — iMessage, Raft network, Cursor Composer via xAI OAuth**
  - 来源：**Nous**
  - 时间：`260619`
  - 正文：~**1020** tok
  - URL：https://github.com/NousResearch/hermes-agent/releases/tag/v2026.6.19
  - 类型：新产品
  - 要点：
    - **6/19** 开源 **Hermes Agent v0.17.0**：新增 **iMessage** 通道、**Raft** agent 网络（后台多 agent 协作）、桌面端 agent builder 与安全登录。
    - **Cursor Composer**（`grok-composer-2.5-fast`）经 **xAI Grok OAuth** 直连，无需单独 API key；新模型支持 `glm-5.2`、`laguna-m.1`、`nemotron-3-ultra`、`claude-fable-5`。
    - 新增 `memory` 工具与多 provider 路由；198k+ stars 社区 harness 快速吸收当周前沿模型与通道生态。

### 新模式

- **IdP as centralized MCP governance plane（IdP 即 MCP 治理平面）**
  - 来源：**MCP**
  - 时间：`260618`
  - 正文：~**620** tok
  - URL：https://modelcontextprotocol.io/extensions/auth/enterprise-managed-authorization
  - 类型：新模式
  - 要点：
    - EMA 将 MCP 授权从「每用户每服务器 OAuth」翻转为「**IT 在 IdP 定义策略 → 员工 SSO 自动继承**」；ID-JAG 短时令牌交换 MCP access token，用户不见逐服同意屏。
    - 与 ARD（6/17 能力发现）、Copilot Agent finder 形成「发现 → 授权 → 执行」企业 agent 栈三层。
    - VibeCoding 启示：agent 工具接入瓶颈从「写 MCP server」转向「**IAM 与合规可审计的批量开通**」。

- **Jira as agent orchestration plane（工单系统即 agent 编排平面）**
  - 来源：**Atlassian**
  - 时间：`260618`
  - 正文：~**560** tok
  - URL：https://www.atlassian.com/blog/company-news/claude-agent-for-jira
  - 类型：新模式
  - 要点：
    - Atlassian 将 Jira 从「任务跟踪」升级为 **agent 指派与审计平面**：工单 = agent 输入契约（验收标准+仓库+规范），PR = 输出工件，全程在 Jira 工作流内可见。
    - 与 Cursor in Jira、Rovo Dev 形成「多 agent IDE」竞争轴；核心差异是 Anthropic **Managed Agents** 托管沙箱+凭据，用户无需本地起 agent。
    - 企业 agent 落地瓶颈从「模型能力」转向「**现有 PM 工具与代码仓库的原生接线**」。

- **Session-to-shareable-artifact as VibeCoding output（Session 即可分享工件）**
  - 来源：**Anthropic**
  - 时间：`260618`
  - 正文：~**580** tok
  - URL：https://venturebeat.com/data/anthropics-claude-code-artifacts-update-brings-live-shared-dashboards-and-interactive-workspaces-to-enterprises
  - 类型：新模式
  - 要点：
    - Claude Code Artifacts 将 agent 产出范式从「终端 diff / PR」扩展为「**实时托管页 + 同 URL 增量发布**」，非技术干系人无需装 CLI 即可旁观 agent 进展。
    - 与 OpenAI Codex Sites 对标，均限 Enterprise/Business 层；CSP 硬隔离定义「可分享捕获」vs「可部署应用」边界。
    - VibeCoding 协作从「同步看终端」变为「**异步订阅 agent 工件流**」，降低 90% AI 采用仍仅 10–15% 生产力增益的可见性损耗。

- **Open-source terminal agent sunset to closed multi-agent platform（开源终端 agent 退役→闭源多 agent 平台）**
  - 来源：**Google**
  - 时间：`260618`
  - 正文：~**560** tok
  - URL：https://developers.googleblog.com/en/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
  - 类型：新模式
  - 要点：
    - Google 将 **Apache 2.0 Gemini CLI**（10 万+ stars）在消费级硬切至**闭源 Go Antigravity CLI**，理由：工作流已演进为「多 agent 共享统一后端」，单 TUI 不足承载。
    - 迁移窗口约 30 天（I/O **5/19** 公告 → **6/18** 截止）；`gemini` 命令 CI/CD 脚本将静默失败；企业/API 用户双轨保留形成「tier 分裂」。
    - 行业对照：Anthropic 拆交互/程序化计费、Microsoft Cowork credits、Cloudflare harness 分层——大厂将 VibeCoding 从社区开源工具收编为**可计量商业 agent 平台**。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
