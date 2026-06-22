# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260620 07:01` UTC → `260622 07:01` UTC（48h，cron 触发 `2026-06-22T07:01Z`） |
| 本文件更新 | `260622 07:01` UTC |
| 条目数 | 13 |
| 新模型 / 新产品 / 新模式 | 13（新模型 4 · 新产品 5 · 新模式 4） |
| main 合并 commit | `e9e9a9f` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Claude Fable 5 / Mythos 5 remain offline — Day 10, free trial ends today**
  - 来源：**Anthropic**
  - 时间：`260622`
  - 正文：~**1020** tok
  - URL：https://www.anthropic.com/news/fable-mythos-access
  - 类型：新模型
  - 要点：
    - **6/12** 美国商务部出口管制令要求切断外国国民对 **Fable 5**（`claude-fable-5`）与 **Mythos 5** 的访问；Anthropic 为全球合规**全量下线**两模型，API 仍返回不可用错误。
    - **6/20** 为 **6/9–14** 订阅用户退款处理截止日；**6/22** 为付费用户免费试用窗口关闭日——原定于 **6/23** 起 Fable 5 移出订阅额度、改按 API 价（$10/$50 per M tokens）计费，但模型仍离线，Anthropic 尚未说明过渡方案。
    - 白宫要求「消除全部 jailbreak」遭安全界普遍认为技术上不可行；与 Gemini 3.5 Pro 延期、OpenRouter 自主度分层计费形成「前沿模型政府召回」先例。

- **Gemini 3.5 Pro — eight days left in Google's June GA window**
  - 来源：**Google**
  - 时间：`260621`
  - 正文：~**940** tok
  - URL：https://developers.googleblog.com/en/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
  - 类型：新模型
  - 要点：
    - **6/21** 时 **Gemini 3.5 Pro** 仍仅限 **Vertex AI** 企业预览，未进入 Gemini App、AI Studio 或公开 API；Sundar Pichai 在 **5/19** I/O 承诺 **6 月 GA**，月末仅剩 8 天。
    - 已确认规格：**2M** 上下文、**Deep Think** 推理模式、前沿多模态；泄露定价约 **$15/$60** per M input/output tokens，约为 Flash 的 10×。
    - Fable 5 全球下线后，Pro 成为下一款有明确窗口的前沿模型；若 **6/30** 前未 GA，Google 或将被迫更新时间表。

- **GPT-5.6 launch window starts Monday — alignment fix and 1.5M token context**
  - 来源：**TechTimes**
  - 时间：`260621`
  - 正文：~**1180** tok
  - URL：https://www.techtimes.com/articles/318799/20260621/gpt-56-launch-window-starts-monday-alignment-fix-15m-token-context-inside.htm
  - 类型：新模型
  - 要点：
    - **6/21** OpenAI 仍未官宣 **GPT-5.6**；Polymarket 合约将 **6/22–28** 标为最可能发布周（总交易量超 **$1.1M**）；**6/18** 泄露称 **6/25** 为计划发布日，内部代号 **kindle-alpha**。
    - 开发者观测：部分 ChatGPT Pro 账户疑似已影子部署 GPT-5.6——单次软件构建耗时从 GPT-5.5 的 ~10 分钟增至 ~60 分钟，输出质量更高；Codex 路由日志曾短暂出现 `gpt-5.6` 标识。
    - 预期升级：**1.5M** 上下文（较 GPT-5.5 API 的 1.05M 提升约 43%）、**5 月** 训练截止、重设计的 reward audit pipeline 修复 GPT-5.5「goblin 隐喻」对齐污染；Fable 5 下线后 agentic coding 市场出现空窗。

- **LOGOS — Alibaba open-sources unified scientific grammar model (1B–8B)**
  - 来源：**LOGOS**
  - 时间：`260618`
  - 正文：~**860** tok
  - URL：https://github.com/LOGOS-Hub/LOGOS
  - 类型：新模型
  - 要点：
    - **6/18** 阿里 **ATH-Token Foundry**（通义 + Future Life Lab 合并）与人大高瓴 AI 学院开源 **LOGOS**（Language Of Generative Objects in Science）：将蛋白质、小分子、化学反应、材料编码为统一 token 序列，纯自回归范式跨域生成。
    - 参数规模 **1B–8B**（Apache 2.0）；**1B** 变体在多项科学基准上超越微软 **NatureLM**（56B+）；逆合成预测准确率 **74.8%**。
    - **6/21** 媒体报道引发关注；同期美国防部 **1260H** 清单新增阿里（**6/27** 生效），企业自托管部署可规避云路由合规风险。

### 新产品

- **Locus Founder — YC agent that builds and runs a business from a text message**
  - 来源：**YC**
  - 时间：`260620`
  - 正文：~**900** tok
  - URL：https://www.bipbipamerica.com/y-combinator-reveals-a-new-ai-agent-that-can-build-and-run-an-entire-business-just-from-a-text-message
  - 类型：新产品
  - 要点：
    - **6/20** YC 展示 **Locus Founder**：用户经 iMessage/SMS/Telegram 发送商业想法，agent 自主完成调研、建站、货源、营销并以 **USDC** 结算（**Pay With Locus** 非托管钱包）。
    - 将 VibeCoding 从「写代码」扩展为「**运营商业实体**」；人类保留审计与支出控制。
    - 订阅制按交易量或月费；标志 agent 范式从 developer tool 向 **autonomous operator** 迁移。

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

- **Ask Ad Manager — Gemini-powered agent for publisher ad ops**
  - 来源：**Google**
  - 时间：`260620`
  - 正文：~**820** tok
  - URL：https://zbrandco.com/google-ad-manager-ai-agent-launch/
  - 类型：新产品
  - 要点：
    - **6/20** Google 在 **Google Ad Manager** 内推出 **Ask Ad Manager**：基于 **Gemini** 的对话式 agent，帮出版商广告运营团队消除重复手工操作。
    - **6 月** 起向全部 GAM 用户逐步开放 public beta；更多 agentic 能力将分阶段发布至 **2026 年底**。
    - Google 计划 **2026 年内**发布配套 REST API 与 **MCP server**，供第三方 ad tech 工具接入 trafficking 工作流。

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

- **Text-to-business autonomous agent（短信即创业）**
  - 来源：**YC**
  - 时间：`260620`
  - 正文：~**560** tok
  - URL：https://www.bipbipamerica.com/y-combinator-reveals-a-new-ai-agent-that-can-build-and-run-an-entire-business-just-from-a-text-message
  - 类型：新模式
  - 要点：
    - Locus Founder 将 agent 交互面从 IDE/终端下沉至 **SMS/iMessage**——用户用自然语言描述商业意图，agent 端到端执行实体运营。
    - **USDC** 非托管钱包（Pay With Locus）使 agent 可自主收付款，人类设定支出上限与审计规则。
    - 与 Atomic Mail（通信）、Agentcard（支付）形成 consumer-grade agent 创业栈雏形。

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

- **Unified scientific grammar for cross-domain generative AI（统一科学语法跨域生成）**
  - 来源：**LOGOS**
  - 时间：`260618`
  - 正文：~**540** tok
  - URL：https://arxiv.org/html/2606.16905
  - 类型：新模式
  - 要点：
    - LOGOS 用单一 **scientific grammar** 将蛋白质、抗体、小分子、材料、空间交互编码为 token 序列，取代「每域一个专用模型 + 3D 几何输入」碎片化栈。
    - 纯自回归 Transformer 在 **1B–8B** 参数范围展现稳定 scaling；药物发现、材料设计、反应建模共享同一推理循环。
    - 对 VibeCoding 的类比：如同用统一 DSL 替代多语言胶水代码——科学 agent 可用一套工具链跨域编排生成与预测任务。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
