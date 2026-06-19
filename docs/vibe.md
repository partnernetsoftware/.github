# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260617 07:00` UTC → `260619 07:00` UTC（48h，cron 触发 `2026-06-19T07:00Z`） |
| 本文件更新 | `260619 07:00` UTC |
| 条目数 | 14 |
| 新模型 / 新产品 / 新模式 | 14（新模型 1 · 新产品 8 · 新模式 5） |
| main 合并 commit | `ae08d5c` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Fable 5 / Mythos 5 global suspension — Seoul signals restoration within days**
  - 来源：**Anthropic**
  - 时间：`260618`
  - 正文：~**980** tok
  - URL：https://www.anthropic.com/news/seoul-office-partnerships-korean-ai-ecosystem
  - 类型：新模型
  - 要点：
    - **6/12** 美国商务部出口管制令要求切断外国国民对 **Claude Fable 5**（`claude-fable-5`）与 **Mythos 5** 的访问；Anthropic 为全球合规**全量下线**两模型（非仅 SK Telecom），API 现返回不可用错误。
    - **6/17–18** 首尔办公室开幕记者会上，国际业务负责人 Chris Ciauri 称「**未来数日内**非常有信心恢复可用」；同日与韩国科学技术信息通信部签 MOU，共建韩语安全评测与网络威胁情报交换渠道。
    - **6/18** 白宫与 Anthropic 转向共建「越狱严重度分级」技术框架（POLITICO/BI 报道），谈判自对抗性「修复或下架」转向可量化安全基准；与 OpenRouter 按自主度分层计费、Google 消费级 Antigravity 硬切形成「前沿模型政府召回」先例。

### 新产品

- **Amazon Bedrock AgentCore harness is now generally available**
  - 来源：**AWS**
  - 时间：`260617`
  - 正文：~**1020** tok
  - URL：https://aws.amazon.com/about-aws/whats-new/2026/06/amazon-bedrock-agentcore-harness-generally-available/
  - 类型：新产品
  - 要点：
    - **6/17** **AgentCore harness** 全区域 GA：两 API 调用（`CreateHarness` / `InvokeHarness`）或 CLI/控制台即可起产级 agent，无需手写编排循环或自建容器。
    - 托管能力含：隔离文件系统+Shell、跨会话记忆、AWS 精选 **Skills** 目录、Gateway/MCP 工具、**Web Search**（GA）、多模型 mid-session 切换（LiteLLM + Bedrock Mantle 含 GPT-5.5/5.4）、CloudWatch 全链路追踪。
    - 配置即运营：`agentcore harness export` 一键导出 **Strands** 代码（Claude Agent SDK 导出即将上线）；同批 GA 还有 AgentCore CLI、Gateway MCP 三方可 OAuth（3LO）、Policy 集成 Bedrock Guardrails。

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

- **Meet the new Google Home Speaker, built for Gemini**
  - 来源：**Google**
  - 时间：`260617`
  - 正文：~**880** tok
  - URL：https://blog.google/products-and-platforms/devices/google-nest/google-home-speaker-gemini-features/
  - 类型：新产品
  - 要点：
    - **6/17** 六年来首款新智能音箱 **Google Home Speaker** 开启预售 **$99.99**，**6/25** 全球 18 国上架；首款为 **Gemini for Home** 原生设计的音频硬件（非仅 Nest 固件升级）。
    - 语音：10 种自然音色、多指令并行、句中自我纠正、**Continued Conversation** 免重复唤醒；本地模型做降噪/回声消除/声源分离以提升远场识别。
    - 硬件：58mm 驱动 360° 音效、Matter 控制器 + Thread Border Router；购机赠 6 个月 **Google Home Premium**（含 Gemini Live、摄像头历史搜索、Home Briefs）。

- **Anthropic opens Seoul office and announces new partnerships across the Korean AI ecosystem**
  - 来源：**Anthropic**
  - 时间：`260617`
  - 正文：~**1050** tok
  - URL：https://www.anthropic.com/news/seoul-office-partnerships-korean-ai-ecosystem
  - 类型：新产品
  - 要点：
    - **6/17** 首尔办公室正式开幕（亚太第三站，继东京/班加罗尔）；代表理事 KiYoung Choi 领衔，当日宣布韩国企业级最大规模 Claude 部署浪潮。
    - 工程侧：**NAVER** 全组织上线 **Claude Code**（数千工程师）；**Nexon** 用于 live-service 游戏工程；**Samsung SDS** 部署 Cowork+Code 至三星电子；**LG CNS** 扩至整个 LG 集团；**Hanwha Solutions** 经 AWS Bedrock 满足数据驻留。
    - 生态：与 **MSIT** 签 AI 安全 MOU；向 **NAIRL**（KAIST/高丽/延世/POSTECH 等）提供最多 60 名研究员 Claude 额度；**Channel Corp** 以 Claude 驱动 23 万+ 企业客服 AI。

- **Anthropic ships major Claude Design overhaul with design system imports, code round-trips, and a fix for its token-burning problem**
  - 来源：**VB**
  - 时间：`260617 19:00`
  - 正文：~**1100** tok
  - URL：https://venturebeat.com/technology/anthropic-ships-major-claude-design-overhaul-with-design-system-imports-code-round-trips-and-a-fix-for-its-token-burning-problem
  - 类型：新产品
  - 要点：
    - **Claude Design** 大改版：从 GitHub/设计文件/上传导入**设计系统**，生成前自动校验并纠错；管理员可锁定企业标准组件库，输出强制 on-brand。
    - **Claude Code ↔ Design 双向**：`/design-sync` 导入代码库设计系统；设计稿一键 handoff 至 Code 续写；Code 内 `/design` 命令不离终端编辑设计项目。
    - Token 经济学修复：与 Chat/Cowork/Code **共享订阅额度**（非独立小池）；单轮消耗优化；导出至 Adobe/Canva/Gamma/Lovable/Miro/Replit/Vercel/Wix 等 **9** 家伙伴。

- **Introducing eve, an open-source agent framework**
  - 来源：**Vercel**
  - 时间：`260617`
  - 正文：~**880** tok
  - URL：https://vercel.com/changelog/introducing-eve-an-open-source-agent-framework
  - 类型：新产品
  - 要点：
    - **eve** 公测：filesystem-first TypeScript agent 框架；agent = 目录（`agent.ts` + `instructions.md` + `tools/`/`skills/`/`subagents/`/`channels/`/`schedules/`）。
    - 内置 durable execution、沙箱、human-in-the-loop approvals、subagents、evals；`npx eve@latest init` 一分钟本地起 agent；`vercel deploy` 原样上生产。
    - 任意模型 + 任意 MCP + Slack/Discord/GitHub 等 channel；Vercel 自用内部 agent 的同框架开源（`github.com/vercel/eve`）。

- **Bringing more agent harnesses and frameworks to Cloudflare, starting with Flue**
  - 来源：**Cloudflare**
  - 时间：`260617`
  - 正文：~**1050** tok
  - URL：https://blog.cloudflare.com/agents-platform-flue-sdk/
  - 类型：新产品
  - 要点：
    - **Agents SDK** 向第三方 harness 开放 Project Think 级原语：**runFiber** 崩溃恢复、**@cloudflare/codemode** 动态代码执行、**@cloudflare/shell** 持久虚拟文件系统、**@cloudflare/dynamic-workflows** 运行时写 workflow。
    - **Flue 1.0 Beta**（Astro 团队）为首框架：声明式定义 agent 上下文（model/skills/sandbox/instructions），基于 **Pi** harness；Cloudflare 部署时每 agent 一 Durable Object。
    - 三层栈范式：Framework（Flue）→ Harness（Pi/Think）→ Runtime（Agents SDK）；Flue 支持 Slack/GitHub/Linear/Discord channel 与 `@flue/react` 前端流式 UI。

- **Agent finder for GitHub Copilot now available**
  - 来源：**GitHub**
  - 时间：`260617`
  - 正文：~**720** tok
  - URL：https://github.blog/changelog/2026-06-17-agent-finder-for-github-copilot-now-available/
  - 类型：新产品
  - 要点：
    - **Agent finder**：自然语言描述任务 → 搜索已索引 MCP/skills/canvas/agent/tool → 按相关性排序按需加载，避免预装全量工具塞满 context。
    - 实现开放 **ARD（Agentic Resource Discovery）** 规范；可指向 GitHub 公共目录或企业私有 registry；企业 managed settings 控制可发现资源；**不自动安装**。
    - 全 Copilot 计划可用；同日 Google 发布 ARD 规范、Hugging Face 推出 Discover Tool 参考实现。

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

### 新模式

- **Jira as agent orchestration plane（工单系统即 agent 编排平面）**
  - 来源：**Atlassian**
  - 时间：`260618`
  - 正文：~**560** tok
  - URL：https://www.atlassian.com/blog/company-news/claude-agent-for-jira
  - 类型：新模式
  - 要点：
    - Atlassian 将 Jira 从「任务跟踪」升级为 **agent 指派与审计平面**：工单 = agent 输入契约（验收标准+仓库+规范），PR = 输出工件，全程在 Jira 工作流内可见。
    - 与 Cursor in Jira、Rovo Dev 形成「多 agent IDE」竞争轴；核心差异是 Anthropic **Managed Agents** 托管沙箱+凭据，用户无需本地起 agent。
    - VibeCoding 启示：企业 agent 落地瓶颈从「模型能力」转向「**现有 PM 工具与代码仓库的原生接线**」，减少 90% AI 采用仍仅 10–15% 生产力增益的上下文搬运损耗。

- **Managed agent harness as config-not-code（配置即产级 harness，非脚手架）**
  - 来源：**AWS**
  - 时间：`260617`
  - 正文：~**580** tok
  - URL：https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-harness-is-now-generally-available-go-from-idea-to-production-grade-agent-in-minutes/
  - 类型：新模式
  - 要点：
    - AWS 将 agent「大脑 vs 身体」显式商品化：**harness = 编排循环+工具执行+上下文管理+故障恢复+会话隔离**；客户用 YAML/控制台定义，同一配置从 POC 扩至千级会话。
    - **Harness 与模型解耦**：mid-session 换模型（规划用 A、编码用 B）不丢上下文；需要定制时再 `export` 至 Strands，而非推倒重来。
    - 与 Vercel eve（filesystem-first）、Cloudflare SDK（harness 分层）、Microsoft Cowork credits 形成「**平台托管 agent 运行时**」四极，开发者默认不再自建 orchestration loop。

- **ARD federated discovery layer over MCP/A2A（MCP 之上的联邦能力发现层）**
  - 来源：**Google**
  - 时间：`260617`
  - 正文：~**680** tok
  - URL：https://developers.googleblog.com/announcing-the-agentic-resource-discovery-specification/
  - 类型：新模式
  - 要点：
    - **ARD v0.9**：域名托管 `/.well-known/ai-catalog.json` 静态清单 + 联邦 registry REST API；发现 MCP/A2A/Skills/API 后由原生协议直连执行，ARD 不介入运行时。
    - 发布方一次描述、多 registry 索引；GitHub Agent finder、Hugging Face Discover、Google Agent Platform 同日落地；Apache 2.0，基于 Linux Foundation **AI Catalog** 数据模型。
    - 逆转「每个平台重复注册」：agent 运行时按需发现工具，替代预装全量 MCP 塞 context——与 Copilot Agent finder「find not install」一致。

- **Design-code round-trip as single-agent workflow（设计-代码单 agent 闭环）**
  - 来源：**VB**
  - 时间：`260617`
  - 正文：~**620** tok
  - URL：https://venturebeat.com/technology/anthropic-ships-major-claude-design-overhaul-with-design-system-imports-code-round-trips-and-a-fix-for-its-token-burning-problem
  - 类型：新模式
  - 要点：
    - Anthropic 押注「同一 AI 既设计又编码」消除 Figma→Dev 损耗：共享组件库后 Design 输出与 Code 实现不再经 lossy handoff，而是**同一系统延续**。
    - 与 Anthropic 研究（~40 万 Claude Code 会话：领域专长而非编程技能决定成败）呼应——设计师借 agent 跨模态成功靠业务理解，非学语法。
    - 对标 Figma Dev Mode/Zeplin 规格传递范式；防御开源 **Open Design**（57k+ stars）靠 Adobe/Canva/Vercel 等**集成生态**而非自托管。

- **Open-source terminal agent sunset to closed multi-agent platform（开源终端 agent 退役→闭源多 agent 平台）**
  - 来源：**Google**
  - 时间：`260618`
  - 正文：~**560** tok
  - URL：https://developers.googleblog.com/en/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
  - 类型：新模式
  - 要点：
    - Google 将 **Apache 2.0 Gemini CLI**（10 万+ stars）在消费级硬切至**闭源 Go Antigravity CLI**，理由：工作流已演进为「多 agent 共享统一后端」，单 TUI 不足承载。
    - 迁移窗口约 30 天（I/O **5/19** 公告 → **6/18** 截止）；`gemini` 命令 CI/CD 脚本将静默失败；企业/API 用户双轨保留形成「tier 分裂」。
    - 行业对照：Anthropic 拆交互/程序化计费、Microsoft Cowork credits、Cloudflare 将 harness 与 runtime 分层——大厂将 VibeCoding 从社区开源工具收编为**可计量商业 agent 平台**。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
