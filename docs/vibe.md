# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260619 07:02` UTC → `260621 07:02` UTC（48h，cron 触发 `2026-06-21T07:02Z`） |
| 本文件更新 | `260621 07:02` UTC |
| 条目数 | 13 |
| 新模型 / 新产品 / 新模式 | 13（新模型 3 · 新产品 5 · 新模式 5） |
| main 合并 commit | `d9cab9c` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Claude Fable 5 / Mythos 5 remain offline — Day 9, refund window closed**
  - 来源：**Anthropic**
  - 时间：`260621`
  - 正文：~**980** tok
  - URL：https://www.anthropic.com/news/fable-mythos-access
  - 类型：新模型
  - 要点：
    - **6/12** 美国商务部出口管制令要求切断外国国民对 **Fable 5**（`claude-fable-5`）与 **Mythos 5** 的访问；Anthropic 为全球合规**全量下线**两模型，API 仍返回不可用错误。
    - **6/20** 为 **6/9–14** 订阅用户退款处理截止日；**6/21** 进入禁令第 9 日，Chris Ciauri **6/18** 首尔称「数日内恢复」但尚未兑现；**6/22** 为付费用户免费试用窗口关闭日。
    - 白宫要求「消除全部 jailbreak」遭安全界普遍认为技术上不可行；与 Gemini 3.5 Pro 延期、OpenRouter 自主度分层计费形成「前沿模型政府召回」先例。

- **Gemini 3.5 Pro — nine days left in Google's June GA window**
  - 来源：**Google**
  - 时间：`260621`
  - 正文：~**920** tok
  - URL：https://developers.googleblog.com/en/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
  - 类型：新模型
  - 要点：
    - **6/21** 时 **Gemini 3.5 Pro** 仍仅限 **Vertex AI** 企业预览，未进入 Gemini App、AI Studio 或公开 API；Sundar Pichai 在 **5/19** I/O 承诺 **6 月 GA**，月末仅剩 9 天。
    - 已确认规格：**2M** 上下文、**Deep Think** 推理模式、前沿多模态；泄露定价约 **$15/$60** per M input/output tokens，约为 Flash 的 10×。
    - Fable 5 全球下线后，Pro 成为下一款有明确窗口的前沿模型；若 **6/30** 前未 GA，Google 或将被迫更新时间表。

- **Ministral-3-14B-Instruct now on Amazon SageMaker JumpStart**
  - 来源：**AWS**
  - 时间：`260619`
  - 正文：~**780** tok
  - URL：https://insideai.news/news/agentic-ai/aws-debuts-mistrals-ministral-3-14b-instruct-for-multimodal-agentic-ai-in-sagemaker/1677/
  - 类型：新模型
  - 要点：
    - **6/19** AWS 将 Mistral **Ministral-3-14B-Instruct-2512** 加入 **SageMaker JumpStart**，一键部署 **14B** 多模态 instruct 模型，支持视觉+文本与 **function calling**。
    - 面向边缘/本地 agent 场景：比 Mistral Large 3（675B MoE）更轻，适合企业私有云内嵌 agent 工具调用。
    - 与 Mistral 3 家族（Large 3 + Ministral 3B/8B/14B，**Apache 2.0**）在 Bedrock、OpenRouter 等渠道形成「云端大模型 + JumpStart 边缘模型」双轨。

### 新产品

- **Temporary Cloudflare Accounts for AI agents**
  - 来源：**Cloudflare**
  - 时间：`260619`
  - 正文：~**950** tok
  - URL：https://blog.cloudflare.com/temporary-accounts/
  - 类型：新产品
  - 要点：
    - **6/19** Cloudflare 发布 **Temporary Accounts**：agent 执行 `wrangler deploy --temporary` 即可**无需人类注册/OAuth** 获得临时账号与 API token，秒级部署 Worker。
    - 部署后返回 **claim URL**；人类 **60 分钟内**认领则账号永久化（含 D1 等 binding）；超时自动删除全部资源。
    - Wrangler 在认证失败时主动提示 `--temporary` 标志，让 LLM 自主发现该能力；与 Stripe 联合 agent 开户协议、WorkOS **auth.md** 构成「无摩擦 agent 部署」产品栈。

- **Hermes Agent v0.17.0 — iMessage, Raft network, Cursor Composer via xAI OAuth**
  - 来源：**Nous**
  - 时间：`260619`
  - 正文：~**1020** tok
  - URL：https://github.com/NousResearch/hermes-agent/releases/tag/v2026.6.19
  - 类型：新产品
  - 要点：
    - **6/19** 开源 **Hermes Agent v0.17.0**（The Reach Release）：新增 **iMessage** 通道（Photon）、**Raft** agent 网络、桌面端 agent builder 与安全登录。
    - **Cursor Composer**（`grok-composer-2.5-fast`）经 **xAI Grok OAuth** 直连，无需单独 API key；新模型支持 `glm-5.2`、`laguna-m.1`、`nemotron-3-ultra`、`claude-fable-5`。
    - `memory` 工具支持原子批量编辑；curator 默认关闭 aux-model 合并以省 token；~1,475 commits / 300+ issues closed。

- **Atomic Mail — email service where AI agents register their own inboxes**
  - 来源：**Atomic**
  - 时间：`260620`
  - 正文：~**880** tok
  - URL：https://shanghaimirror.com/atomic-mail-releases-email-service-that-lets-ai-agents-register-their-own-inboxes-with-no-human-involvement/
  - 类型：新产品
  - 要点：
    - **6/20** 爱沙尼亚 **Atomic Mail** 开放 alpha：agent 可**自行注册并运营**邮箱，无需人类先建账号再移交凭据；基于开放 **JMAP** 标准。
    - 用 **Proof-of-Work** + 信誉评分反垃圾；alpha 期全部 `@atomicmail.ai` 域名、免费；后续迁移至付费产品免费层。
    - 标志 agent 基础设施从「人类代建身份」演进为「**机器自持通信端点**」，适用于 outreach、工单、跨组织 agent 协作。

- **Agentcard — virtual credit card for AI agents, DoorDash integration**
  - 来源：**Agentcard**
  - 时间：`260620`
  - 正文：~**850** tok
  - URL：https://ainews.cool/article/20260620-agentcard-ai-agent-payments
  - 类型：新产品
  - 要点：
    - **6/20** **Agentcard** 发布面向 agent 的**可编程虚拟信用卡**，已集成 **DoorDash** 自主下单支付，解决 agent「能推理不能结账」的最后一公里。
    - 处理非人类身份验证、欺诈防控与消费限额；定位「**Stripe for AI agents**」，按交易费或订阅 monetize。
    - 解锁 agent 从推荐到**自主执行真实世界采购**的闭环，餐饮配送为 PoC，可扩展至 B2B 供应链等场景。

- **Qubitz AI — agentic platform from former AWS specialists**
  - 来源：**Cloud202**
  - 时间：`260620`
  - 正文：~**820** tok
  - URL：https://markets.businessinsider.com/news/stocks/former-aws-specialists-launch-platform-designed-to-turn-ai-ideas-into-production-ready-applications-and-save-80-in-costs-1036263611
  - 类型：新产品
  - 要点：
    - **6/20** 前 AWS 专家创立的 **Cloud202** 发布 **Qubitz AI**：从业务问题反推（Working Backwards），自动生成多 agent 架构、实现计划与**生产级全栈应用**。
    - 内置 **Test Bed** 按企业预期验收输出；可先部署于 Qubitz AWS 环境再迁移至客户自有云；宣称节省最高 **80%** 成本。
    - 前 1,000 家合格组织获 1 个月免费 + 500 万 token；标志「agent 平台即交付物生成器」企业化。

### 新模式

- **Disposable temporary cloud accounts for agent deploy（一次性临时云账号部署）**
  - 来源：**Cloudflare**
  - 时间：`260619`
  - 正文：~**580** tok
  - URL：https://blog.cloudflare.com/temporary-accounts/
  - 类型：新模式
  - 要点：
    - 将 agent 部署范式从「阻塞等人类 OAuth」翻转为「**先部署、后认领**」：60 分钟窗口内无限次迭代 write→deploy→curl 验证。
    - 未认领资源自动销毁，降低 agent 试错成本；与人类在环的 claim 步骤保留合规审计点。
    - VibeCoding 启示：云厂商开始为**后台无人值守 agent** 重设身份与计费边界，而非仅 retrofit OAuth。

- **Agent-native payment rails（Agent 原生支付轨）**
  - 来源：**Agentcard**
  - 时间：`260620`
  - 正文：~**520** tok
  - URL：https://ainews.cool/article/20260620-agentcard-ai-agent-payments
  - 类型：新模式
  - 要点：
    - Agentcard 将支付从「人类持卡代付」变为「**机器持有可编程额度**」：限额、商户白名单、交易审计内建于虚拟卡。
    - 与 MCP 工具调用互补：模型决定买什么，支付层决定能不能付、付多少。
    - 预示 **M2M commerce** 栈成型，Stripe 等 incumbent 预计 6–9 个月内跟进类似产品。

- **Agent-owned email identity（Agent 自持邮箱身份）**
  - 来源：**Atomic**
  - 时间：`260620`
  - 正文：~**500** tok
  - URL：https://shanghaimirror.com/atomic-mail-releases-email-service-that-lets-ai-agents-register-their-own-inboxes-with-no-human-involvement/
  - 类型：新模式
  - 要点：
    - Atomic Mail 打破「人类建号→把密码塞给 agent」反模式；agent 成为邮箱**法律与技术主体**。
    - JMAP + PoW 反垃圾使机器注册可行；与 Cloudflare 临时账号、Agentcard 支付形成 agent **身份-通信-支付** 三件套。
    - 企业 agent 落地需重新定义 IAM：何时允许 agent 对外通信、如何吊销机器身份。

- **Text-to-business autonomous agent（短信即创业）**
  - 来源：**YC**
  - 时间：`260620`
  - 正文：~**560** tok
  - URL：https://www.bipbipamerica.com/y-combinator-reveals-a-new-ai-agent-that-can-build-and-run-an-entire-business-just-from-a-text-message
  - 类型：新模式
  - 要点：
    - YC 展示 **Locus Founder**：用户经 iMessage/SMS/Telegram 发送商业想法，agent 自主完成调研、建站、货源、营销并以 **USDC** 结算（**Pay With Locus** 非托管钱包）。
    - 将 VibeCoding 从「写代码」扩展为「**运营商业实体**」；人类保留审计与支出控制。
    - 订阅制按交易量或月费；标志 agent 范式从 developer tool 向 **autonomous operator** 迁移。

- **Usage-metered enterprise agent + open-model backend option（按量计费企业 agent + 开源后端选项）**
  - 来源：**Microsoft**
  - 时间：`260619`
  - 正文：~**540** tok
  - URL：https://www.techoper.com/microsoft-copilot-cowork-generally-available-usage-pricing-deepseek-june-2026
  - 类型：新模式
  - 要点：
    - **6/16** **Copilot Cowork** GA 后，**6/19** 媒体报道确认转向 **Copilot Credits** 按量计费（长时后台 agent 任务无法被 flat licence 覆盖）。
    - 微软同步探索在 Azure 托管微调 **DeepSeek V4** 或其他开源模型作为 Cowork 低成本后端——尚未定案，数周内公布。
    - 与 Anthropic 合建 Cowork、但推理层可切换开源，标志大厂 agent 栈进入「**多模型路由 + 用量计量**」运营阶段。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
