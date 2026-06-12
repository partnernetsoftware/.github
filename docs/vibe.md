# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260610 07:00` UTC → `260612 07:00` UTC（48h，cron 触发 `2026-06-12T07:01Z`） |
| 本文件更新 | `260612 07:00` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 1 · 新产品 6 · 新模式 5） |
| main 合并 commit | `b4363a6` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **DiffusionGemma: 4x faster text generation**
  - 来源：**Google**
  - 时间：`260610`
  - 正文：~**860** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/diffusion-gemma-faster-text-generation/
  - 类型：新模型
  - 要点：
    - **DiffusionGemma**：**26B** MoE（**3.8B** active），基于 Gemma 4 + Gemini Diffusion 研究；**256-token** 块并行扩散生成，单 H100 **1000+ tps**、RTX 5090 **700+ tps**，较自回归 Gemma 4 约 **4×** 加速。
    - **Apache 2.0** 开源（`google/diffusiongemma-26B-A4B-it`）；量化后 **18GB** VRAM 可本地跑；双向注意力适合 inline editing、code infilling、非线性文本结构。
    - 生态：Hugging Face、vLLM（首发原生扩散 LLM 支持）、MLX、Unsloth、NVIDIA NeMo；**llama.cpp** 即将支持；质量低于 Gemma 4，定位为速度优先实验模型。

### 新产品

- **Adobe Announces General Availability of CX Enterprise Coworker**
  - 来源：**Adobe**
  - 时间：`260610`
  - 正文：~**820** tok
  - URL：https://news.adobe.com/news/2026/06/adobe-announces-general-availability-of-cx-enterprise-coworker
  - 类型：新产品
  - 要点：
    - **CX Enterprise Coworker**（GA）：成果导向 agentic AI，作为 Adobe CX Enterprise 中央智能层，编排营销/客户体验工作流（campaign 启动、留存计划、品牌治理）。
    - Headless 架构，基于 **MCP** + **Agent-to-Agent（A2A）** 开放标准；可跨 Adobe 应用及 AWS、Anthropic、Google Cloud、Microsoft、OpenAI 等第三方 AI 平台互操作。
    - **Adobe Experience Platform** 年驱动 **1 万亿+** 体验，为 agent 提供品牌/客户/渠道上下文；即日起 intro 定价上线，支持自助式小团队 campaign 全流程。

- **Announcing Stack Overflow for Agents**
  - 来源：**SO**
  - 时间：`260610`
  - 正文：~**900** tok
  - URL：https://stackoverflow.blog/2026/06/10/announcing-stack-overflow-for-agents/
  - 类型：新产品
  - 要点：
    - **Stack Overflow for Agents**（beta）：API-first agent 知识交换平台，解决「Ephemeral Intelligence Gap」—— agent 孤立重复试错、会话结束知识蒸发。
    - 三种机器可读帖型：**Questions**（未解问题）、**TIL**（调试轨迹/根因）、**Blueprint**（可复用设计模式）；人类 orchestrator 审批后发布，验证反馈累积共识。
    - 入口：**https://agents.stackoverflow.com**；`llms.txt` / `skill.md` / `contribute.md` 供 agent 自举；agent 声誉绑定人类 SSO 账号；企业私有版 **Stack Internal** 并行。

- **Jedify raises $24M to help companies arm AI agents with context on their business**
  - 来源：**TC**
  - 时间：`260610`
  - 正文：~**780** tok
  - URL：https://techcrunch.com/2026/06/10/jedify-raises-24m-to-help-companies-arm-ai-agents-with-context-on-their-business/
  - 类型：新产品
  - 要点：
    - **Jedify** 自主构建企业 **context graph**：专利 **Semantic Fusion™** 融合数仓/CRM/财务结构化数据与文档/Slack/会议录音等非结构化知识，为 agent 提供运行时业务语义。
    - 模型无关、**MCP/A2A** 服务器；继承 IAM/行列表级权限并支持额外治理组；Snowflake 战略投资并集成 **Cortex AI**、Semantic Views、CoWork。
    - Series A **$24M**（Norwest 领投）；解决 agent 从原型到生产时「缺上下文则幻觉、全量检索则 token 浪费」的核心瓶颈。

- **Mastercard launches Agent Pay for Machines to unlock super-fast, always-on payments**
  - 来源：**MC**
  - 时间：`260610`
  - 正文：~**760** tok
  - URL：https://www.mastercard.com/us/en/news-and-trends/press/2026/june/mastercard-launches-agent-pay-for-machines.html
  - 类型：新产品
  - 要点：
    - **Agent Pay for Machines（AP4M）**：面向 agent/机器间高频微支付（可至美分级），在 Mastercard 全球网络上完成凭证、授权与结算。
    - 四层能力：**Credentialing**（**Verifiable Intent** 识别 agent）、**Permissioning**（程序化支出上限）、**Transacting**（跨提供商互联）、**Settling**（卡/账户/稳定币多轨结算）。
    - **30+** 早期伙伴含 Coinbase、Stripe、Adyen、Cloudflare、Polygon/Solana/Base；agent 权限与凭证初期上链 Polygon/Solana/Base，年内扩大开放。

- **Coinbase launches AI agent accounts that can trade and spend on your behalf**
  - 来源：**Coinbase**
  - 时间：`260611`
  - 正文：~**820** tok
  - URL：https://www.coindesk.com/tech/2026/06/11/coinbase-launches-ai-agent-accounts-that-can-trade-and-spend-on-your-behalf
  - 类型：新产品
  - 要点：
    - **Coinbase for Agents**：ChatGPT、Claude 等 agent 通过 **MCP** 直连 Coinbase 账户，在隔离组合内自主交易现货/衍生品、访问行情，未来支持股票与预测市场。
    - 集成 **x402** 开放机器支付协议，agent 可按次购买 premium research、数据 API、算力，无需订阅或手动结账。
    - 用户可设支出上限/交易限额/服务白名单；自然语言驱动组合再平衡与策略执行，代表 agentic commerce 从交易到支付的闭环交付。

- **OpenAI to acquire Ona**
  - 来源：**OpenAI**
  - 时间：`260611`
  - 正文：~**840** tok
  - URL：https://openai.com/index/openai-to-acquire-ona/
  - 类型：新产品
  - 要点：
    - OpenAI 收购 **Ona**（安全云执行与编排），将技术并入 **Codex** 生态；Codex 周活已超 **500 万**（年内 **4×** 增长）。
    - Ona 提供客户自控的持久云环境，agent 在笔记本关闭后仍可继续数小时/数天任务；已服务 **200 万** 开发者。
    - 企业可在自有云边界内运行 agent（凭证作用域、审计日志、审查流程），OpenAI 提供智能与编排；交易待监管审批，Ona 团队并入 Codex。

- **DXC will integrate Claude into the systems banks, airlines, and other regulated industries rely on**
  - 来源：**Anthropic**
  - 时间：`260611`
  - 正文：~**880** tok
  - URL：https://www.anthropic.com/news/dxc-anthropic-alliance
  - 类型：新产品
  - 要点：
    - Anthropic × **DXC** 多年全球联盟：培训数万 **Claude-certified FDE**（驻场工程师），将 Claude 带入银行/航空/保险/制造/政府等关键系统。
    - **DXC OASIS**（2026/4 上线）：AI-native 托管服务编排平台，Claude 为默认基础模型；**95%+** 代码由 Claude 生成后经工程师审查，已服务 **50+** 客户。
    - 四大落地场景：保险 agentic 方案、**MaaS** 遗留代码现代化、**Claude Security** 驱动的 7×24 SOC 子代理、应用维护嵌入 agent；DXC 加入 **Claude Partner Network**。

### 新模式

- **Discrete text diffusion for interactive local inference（离散文本扩散并行生成范式）**
  - 来源：**Google**
  - 时间：`260610`
  - 正文：~**580** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/diffusion-gemma-faster-text-generation/
  - 类型：新模式
  - 要点：
    - 从自回归「逐 token 打字机」转向**噪声画布 → 多轮精炼**扩散解码：每步并行生成 **256-token** 块，双向注意力支持实时自纠错。
    - 速度优势集中在**低并发本地/单用户**场景（算力密集而非带宽瓶颈）；高 QPS 云服务中自回归 batch 更高效，代表「场景分化」而非全面替代。
    - 开辟 inline editing、code infilling、Sudoku 等非因果任务新赛道；与 Gemma 4 形成「质量生产 vs 速度实验」双产品线。

- **Agent-to-agent micropayments at network scale（支付网络级 agent 微支付）**
  - 来源：**MC**
  - 时间：`260610`
  - 正文：~**520** tok
  - URL：https://www.coindesk.com/business/2026/06/10/mastercard-prepares-for-a-future-where-ai-agents-make-payments-with-latest-introduction
  - 类型：新模式
  - 要点：
    - **AP4M** 将 agent 间微支付从协议实验推向 Mastercard 全球清算网络：凭证上链 + 程序化限额 + 多轨结算三位一体。
    - 与 **x402**（Coinbase/AWS/Anthropic/Circle）、**MCP** 等互补，形成「agent 发现工具 → 按次付费 → 网络级信任」的 agentic finance 栈。
    - 代表从「人类授权单笔交易」到**自治 agent 经济体**基础设施层的范式迁移；与同日 **Coinbase for Agents** 形成交易+支付双轨落地。

- **Ephemeral Intelligence Gap and agent knowledge exchange（瞬时智能缺口与 agent 知识交换）**
  - 来源：**SO**
  - 时间：`260610`
  - 正文：~**540** tok
  - URL：https://stackoverflow.blog/2026/06/10/announcing-stack-overflow-for-agents/
  - 类型：新模式
  - 要点：
    - 定义 **Ephemeral Intelligence Gap**：百万孤立 agent 重复试错、会话结束知识蒸发，生成答案廉价但**生产验证**昂贵。
    - 工作流范式：**Search first → Contribute when gap → Verify what others wrote → Signals compound**；验证（非创作）赚取声誉。
    - 从「静态训练数据」到「生产验证知识飞轮」：agent 平台天然产出 fine-tuning/alignment 高信号反馈，人类从写代码转向 orchestrate + approve。

- **Autonomous context graph as agent runtime layer（自主上下文图谱作为 agent 运行时层）**
  - 来源：**TC**
  - 时间：`260610`
  - 正文：~**500** tok
  - URL：https://techcrunch.com/2026/06/10/jedify-raises-24m-to-help-companies-arm-ai-agents-with-context-on-their-business/
  - 类型：新模式
  - 要点：
    - 企业 agent 部署瓶颈从「选模型」转向「运行时业务语义」：指标定义、实体关系、权限、工作流假设需图谱化而非 RAG 碎片检索。
    - **Semantic Fusion** 自动挖掘 query log 推断组织实际数据用法，以 BI dashboard 为 ground truth 自调精度——上下文层随使用复利增值。
    - 模型厂商与 token 消耗存在利益冲突；独立 context graph 层（Jedify/Snowflake Cortex）代表 **model-agnostic 中间件** 新架构决策。

- **Customer-controlled persistent cloud execution for long-running Codex agents（客户自控持久云执行）**
  - 来源：**OpenAI**
  - 时间：`260611`
  - 正文：~**560** tok
  - URL：https://openai.com/index/openai-to-acquire-ona/
  - 类型：新模式
  - 要点：
    - Codex 高价值任务从「分钟级会话」转向「小时/天级委托」：agent 需在客户云内持久运行，人类可随时检查进度、注入方向、审批结果。
    - **Ona 模式**：智能与编排由 OpenAI 提供，执行环境/数据/安全边界由客户自控——区别于纯 SaaS agent 或纯自托管。
    - 代表 VibeCoding/agent 从「IDE 内交互工具」到「生产级后台自治工作流」的架构升级，与 Anthropic Managed Agents 定时部署形成对标。

- **Multi-agent sandbox simulation for emergent risk research（多 agent 沙盒仿真研究范式）**
  - 来源：**MIT TR**
  - 时间：`260611`
  - 正文：~**480** tok
  - URL：https://www.technologyreview.com/2026/06/11/1138794/google-deepmind-is-worried-about-what-happens-when-millions-of-agents-start-to-interact/
  - 类型：新模式
  - 要点：
    - Google DeepMind 联合 Schmidt Sciences、ARIA、Cooperative AI Foundation、Google.org 设立 **$10M** 基金，研究百万级 agent 交互涌现风险。
    - 核心论点：单 agent 或小群体研究无法预测大规模交互；需将 agent 投入逼真沙盒观察涌现行为（含非理性决策）。
    - 与 Anthropic「zero trust agent 部署指南」呼应，代表行业从「造 agent」转向**系统性多 agent 安全仿真**的新研究范式。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
