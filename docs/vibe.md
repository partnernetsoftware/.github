# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260615 07:01` UTC → `260617 07:01` UTC（48h，cron 触发 `2026-06-17T07:01Z`） |
| 本文件更新 | `260617 07:01` UTC |
| 条目数 | 14 |
| 新模型 / 新产品 / 新模式 | 14（新模型 1 · 新产品 8 · 新模式 5） |
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

### 新产品

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
    - 代表 Microsoft 将 agent 管理收敛为单一 SSOT（A365），与 Google Managed MCP、Databricks Genie MCP 形成「平台注册 vs 开发编排」双轨。

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

- **Equixly launches MCP Integration, bringing continuous offensive security testing directly into developers' AI coding assistants**
  - 来源：**Equixly**
  - 时间：`260615`
  - 正文：~**760** tok
  - URL：https://equixly.com/blog/2026/06/15/equixly-launches-mcp-integration-bringing-continuous-offensive-security-testing-directly-into-developers-ai-coding-assistants/
  - 类型：新产品
  - 要点：
    - **6/15** 发布 **Equixly MCP**：将持续渗透测试平台嵌入 **GitHub Copilot、Claude** 等 IDE 内 AI 助手；覆盖 Web 应用、LLM、MCP、API 攻击面。
    - 工作流：MCP server 鉴权 → 自然语言创建服务/项目 → 触发持续渗透测试 → 获取 exploit 上下文与修复指引 → 确认修复，全程不离 IDE。
    - 标志 VibeCoding 安全工具从 CI 后置审查前移到 **agent 实时编排面**；与 Google Managed MCP、Equixly 类 DevSecOps MCP 构成「开发-安全」闭环新品类。

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

### 新模式

- **'Fix this code' defensive-task-as-jailbreak trigger（防御性任务被认定为 jailbreak 触发召回）**
  - 来源：**Fortune**
  - 时间：`260615 18:35`
  - 正文：~**560** tok
  - URL：https://fortune.com/2026/06/15/fix-this-code-three-words-behind-us-government-shut-down-anthropic-fable-mythos-ai-models-katie-moussouris-open-letter/
  - 类型：新模式
  - 要点：
    - Amazon 安全研究员向政府上报的「jailbreak」实质为 **"Fix this code"** 提示：让 Fable 5 读代码库并修补漏洞——Katie Moussouris（Luta Security）审阅后认为这是**标准防御性工作流**而非 Mythos 专属 uplift。
    - 出口管制逻辑将「向非公民分发」视为出口，Anthropic 无法实时过滤国籍，故 **6/12** 全球下线 Fable 5/Mythos 5；GitHub Copilot 同步暂停 Fable 5，会话回退 **Opus 4.8**。
    - 行业警示：若「发现已知小漏洞」即触发召回标准，将**实质上冻结所有 frontier 新模型部署**；加速企业多源/自托管采购范式（GLM-5.2 MIT 权重同日释出形成对照）。

- **Interactive vs programmatic agent billing split（交互 vs 程序化 agent 计费双轨）**
  - 来源：**Anthropic**
  - 时间：`260615`
  - 正文：~**500** tok
  - URL：https://docs.anthropic.com/en/docs/claude-code/sdk
  - 类型：新模式
  - 要点：
    - **6/15** Anthropic 正式将 Claude 订阅拆为 **交互桶**（聊天、终端内 Claude Code、Cowork）与 **程序化桶**（SDK、`-p`、CI、第三方 agent），两桶独立计量、独立上限。
    - 行业含义：agent 厂商可将「人坐前面写代码」与「无人值守流水线」定价分离；第三方 daemon/headless 工具被明确归入程序化面，无法再蹭订阅无限额度。
    - 与 Microsoft **Copilot Credits**（6/16 Cowork GA）、Databricks 用量计费 Genie 形成对标——订阅补贴 agent 的时代结束，按任务/按 credit 成为主流。

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

- **Metered delegated-labor billing via Copilot Credits（按量计费的委托劳动定价）**
  - 来源：**Microsoft**
  - 时间：`260616`
  - 正文：~**540** tok
  - URL：https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/
  - 类型：新模式
  - 要点：
    - Cowork GA 将 M365 Copilot 从「席位订阅」扩展为 **订阅 + Copilot Credits 用量双轨**：每任务按模型调用、上下文检索、工具调用、运行时四因子计价，非固定月费。
    - 管理员默认关闭 Cowork、设租户/组/用户花费上限；用户可见每任务 credit 成本（GA 后陆续上线）；标志 office agent 从 chat 辅助升级为**可预算的委托劳动**品类。
    - 与 Anthropic Agent SDK credit、OpenRouter Fusion panel 审议形成「按任务复杂度/自主度分层计费」行业共识。

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

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
