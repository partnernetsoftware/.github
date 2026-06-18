# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260616 07:02` UTC → `260618 07:02` UTC（48h，cron 触发 `2026-06-18T07:02Z`） |
| 本文件更新 | `260618 07:02` UTC |
| 条目数 | 17 |
| 新模型 / 新产品 / 新模式 | 17（新模型 3 · 新产品 9 · 新模式 5） |
| main 合并 commit | `a2102dd` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **GLM-5.2: Built for Long-Horizon Tasks**
  - 来源：**智谱**
  - 时间：`260616`
  - 正文：~**1050** tok
  - URL：https://z.ai/blog/glm-5.2
  - 类型：新模型
  - 要点：
    - **GLM-5.2**：**753B** MoE、**1M** token 稳定上下文；**IndexShare** DSA 稀疏注意力在 1M 上下文降 per-token FLOPs **2.9×**；MTP speculative decoding 接受长度 +**20%**。
    - **6/16** 权重同步上线 Hugging Face（`zai-org/GLM-5.2`）与 ModelScope，**MIT** 开源、无地域限制；Coding Plan 全档可用，Claude Code 用 `GLM-5.2[1m]` 后缀启用 1M。
    - 长程编码基准：FrontierSWE 仅落后 Opus 4.8 **1%**、领先 GPT-5.5 **1%**；Terminal-Bench 2.1 **81.0**（开源 SOTA）；High/Max 双思考档位可调延迟与成本。

- **VibeThinker-3B: Exploring the Frontier of Verifiable Reasoning in Small Language Models**
  - 来源：**WeiboAI**
  - 时间：`260616`
  - 正文：~**920** tok
  - URL：https://arxiv.org/abs/2606.16140
  - 类型：新模型
  - 要点：
    - **3B** 稠密推理模型（基于 **Qwen2.5-Coder-3B**），**MIT** 开源；权重 Hugging Face `WeiboAI/VibeThinker-3B`、代码 GitHub `WeiboAI/VibeThinker`。
    - **Spectrum-to-Signal** 后训练管线：AIME26 **94.3**（Claim-Level TTS **97.1**）、LiveCodeBench v6 Pass@1 **80.2**、IFEval **93.4**；宣称对齐 DeepSeek V3.2 / GLM-5 / Gemini 3 Pro 量级旗舰。
    - 定位「可验证推理」小模型：数学/竞赛编程/STEM 强，非通用知识覆盖；训练成本远低于 frontier 规模，挑战「参数压缩-覆盖」假说。

- **Grok Imagine Video 1.5**
  - 来源：**xAI**
  - 时间：`260616`
  - 正文：~**780** tok
  - URL：https://x.ai/news/grok-imagine-video-1-5
  - 类型：新模型
  - 要点：
    - 图生视频 **GA**：同步生成音效/环境音/对白；运动与物理一致性升级；**1.5 Fast** 生成 6s **720p** 约 **25s**（上一代 **40s+**）。
    - API 模型名 **`grok-imagine-video-1.5`** 脱离 preview；同步上线 grok.com/imagine、iOS/Android；配套 **Projects**、并行多 agent、库内搜索。
    - Image-to-Video Arena 盲测 #1（xAI 宣称）；宽发布由 Musk **6/17** 推文推动，官方博客 **6/16** 标记 GA。

### 新产品

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

- **Copilot Cowork is now generally available**
  - 来源：**Microsoft**
  - 时间：`260616`
  - 正文：~**980** tok
  - URL：https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/
  - 类型：新产品
  - 要点：
    - **6/16** **Copilot Cowork** 全球 GA：多工具、长时程 agentic 任务系统，基于 **Work IQ** 在 M365 信任边界内端到端执行（发邮件、排会、建文档、Teams 发帖等），非仅草稿/建议。
    - 需 M365 Copilot USL；实际用量按 **Copilot Credits** 计量（**$0.01/credit** PayGo 或 P3 预付折扣）；Frontier 预览租户延至 **7/1** 前免计费。
    - GA 新增：9 个 partner **plugins**（Enosix/Harvey/Miro/monday.com 等）、**Edge 浏览器**任务、多模型选择（Opus 4.8/Sonnet 4.6，Cowork 1 自研模型即将上线）；租户/组/用户三级花费上限与用量报表。

- **Introducing Genie One, Genie Agents, and Genie Ontology**
  - 来源：**Databricks**
  - 时间：`260616`
  - 正文：~**1020** tok
  - URL：https://www.databricks.com/blog/introducing-genie-one-genie-ontology-and-genie-agents
  - 类型：新产品
  - 要点：
    - **Genie One**：面向业务用户的 data-smart AI coworker（Web/iOS/Android），连接 Lakehouse、Gmail/Slack/Teams 及 **MCP** 助手；超越对话分析，可生成文档、设告警、调度任务、写外部系统。
    - **Genie Agents**：将 Genie Space 升级为可共享自治 agent；单 prompt 创建、基准测试、团队复用；**Genie Ontology** 自动抽取表/查询/仪表盘/工单知识为 living graph，内部基准首答准确率 **84.5%** vs 最强通用编码 agent **52.4%**。
    - 无席位定价，每用户每月 **$10** 免费额度；**Genie One / Agents / Genie Code** 已 GA；**Genie App Builder / ZeroOps** 即将 private preview。

- **GitHits Public Beta 0.9 — Open-source code as context for AI coding agents**
  - 来源：**GitHits**
  - 时间：`260616`
  - 正文：~**840** tok
  - URL：https://githits.com/
  - 类型：新产品
  - 要点：
    - **6/16** 公测 **GitHits CLI + 本地 MCP server**（`npx githits@latest init`）：为编码 agent 提供版本感知开源代码索引，工具含 `search`/`code_read`/`code_grep`/`pkg_info`/`pkg_vulns`/`get_example`。
    - 从私测「示例生成」扩展为依赖级源码导航：查 API 实现、读 changelog、审漏洞、比对包版本；自动检测 Cursor/Claude Code 等并配置 MCP。
    - 定位「代码 Google」补位而非替代 Codex/Claude Code；同日完成 **$1.75M** pre-seed（Vendep/Trind/Jerry Liu 等），计划索引全部公开开源仓库。

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

- **Metered delegated-labor billing via Copilot Credits（按量计费的委托劳动定价）**
  - 来源：**Microsoft**
  - 时间：`260616`
  - 正文：~**540** tok
  - URL：https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/
  - 类型：新模式
  - 要点：
    - Cowork GA 将 M365 Copilot 从「席位订阅」扩展为 **订阅 + Copilot Credits 用量双轨**：每任务按模型调用、上下文检索、工具调用、运行时四因子计价，非固定月费。
    - 管理员默认关闭 Cowork、设租户/组/用户花费上限；用户可见每任务 credit 成本（GA 后陆续上线）；标志 office agent 从 chat 辅助升级为**可预算的委托劳动**品类。
    - 与 Anthropic Agent SDK credit（6/15）、OpenRouter Fusion panel 审议形成「按任务复杂度/自主度分层计费」行业共识。

- **Genie Ontology as living business context graph（业务本体活图驱动 data-smart coworker）**
  - 来源：**Databricks**
  - 时间：`260616`
  - 正文：~**580** tok
  - URL：https://www.databricks.com/blog/introducing-genie-one-genie-ontology-and-genie-agents
  - 类型：新模式
  - 要点：
    - **Genie Ontology** 自动从表/查询/仪表盘/工单/文档抽取知识，以类 **PageRank** 权威度排序定义来源，无需手工维护独立知识库或权限系统。
    - 将「通用编码 agent 猜数据」转为「data-smart coworker 查可信源」：内部 28 题企业数据分析基准首答 **84.5%** vs 匿名最强编码 agent **52.4%**，且延迟 **2×** 更快。
    - VibeCoding 启示：业务 agent 竞争力从 prompt 技巧转向**可治理的企业上下文层**；与 Google Agentic Data Cloud、MCP 数据库服务器形成 data-agent 基础设施三角。

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
