# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260611 07:00` UTC → `260613 07:00` UTC（48h，cron 触发 `2026-06-13T07:00Z`） |
| 本文件更新 | `260613 07:00` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 4 · 新产品 5 · 新模式 3） |
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

- **Kimi K2.7-Code: coding-focused agentic model**
  - 来源：**Moonshot**
  - 时间：`260612`
  - 正文：~**920** tok
  - URL：https://huggingface.co/moonshotai/Kimi-K2.7-Code
  - 类型：新模型
  - 要点：
    - **Kimi K2.7-Code**：基于 K2.6 的 **1T** MoE 编程 agent 模型；相对 K2.6 推理 token 约 **−30%**，Kimi Code Bench v2 **+21.8%**、Program Bench **+11%**、MLS Bench Lite **+31.5%**。
    - **Modified MIT** 开源权重（~595GB）；API 模型串 `kimi-k2.7-code`（OpenAI 兼容），强制 thinking 模式、温度固定 **1.0**；支持 vLLM/SGLang/KTransformers 自托管。
    - 同步发布 **Kimi Code** 终端 agent 与会员计划（$19/月起）；与 K2.6 同架构可热切换，面向长程软件工程与 agent 工作流降本。

- **MiniMax M3: open weights on Hugging Face**
  - 来源：**MiniMax**
  - 时间：`260612`
  - 正文：~**880** tok
  - URL：https://www.minimax.io/blog/minimax-m3
  - 类型：新模型
  - 要点：
    - **MiniMax M3**：**428B** MoE（**23B** active），**MSA** 稀疏注意力实现 **1M** token 上下文；原生多模态（图文视频）+ 桌面操作（OSWorld-Verified **70.06%**）。
    - 编码/agent 基准：SWE-Bench Pro **59.0%**、Terminal Bench 2.1 **66.0%**、MCP Atlas **74.2%**；API 定价约 **$0.30/M** input、**$1.20/M** output（缓存命中），Token Plan **$20/月起**。
    - **6/1** API 上线后 **~10 日**于 Hugging Face 释出完整权重（`MiniMaxAI/MiniMax-M3`）；首个将前沿编码、百万上下文、原生多模态三能力合一的开放权重模型。

- **Zamba2-VL: Hybrid Mamba2–Transformer vision-language models**
  - 来源：**Zyphra**
  - 时间：`260612`
  - 正文：~**760** tok
  - URL：https://arxiv.org/html/2606.00390
  - 类型：新模型
  - 要点：
    - **Zamba2-VL**：**1.2B / 2.7B / 7B** 三档开源 VLM，基于 Zamba2 混合 **Mamba2 SSM + 少量共享 Transformer** 骨干；**Apache 2.0** 权重与推理代码公开。
    - 与同规模 Transformer VLM（Molmo2、Qwen3-VL、InternVL3.5）竞争力相当，TTFT 约低 **1 个数量级**；视觉计数与文档理解强项，知识推理略弱。
    - 需 Zyphra `transformers` fork（v4.57.1）+ CUDA Mamba2 内核；面向边缘/设备端多模态 agent 的低延迟首 token 场景。

- **Claude Fable 5 and Claude Mythos 5 — access suspended**
  - 来源：**Anthropic**
  - 时间：`260612`
  - 正文：~**840** tok
  - URL：https://www.anthropic.com/news/claude-fable-5-mythos-5
  - 类型：新模型
  - 要点：
    - **6/9** 发布的 **Fable 5**（Mythos-class 加安全护栏）与受限版 **Mythos 5** 定价 **$10/M** input、**$50/M** output；FrontierCode、Hebbia Finance、视觉与长程自主任务 SOTA 级表现。
    - **6/12 17:21 ET** 美国政府以国家安全/出口管制为由，要求禁止外籍人士访问两模型；Anthropic 无法实时区分用户国籍，遂**全球下线**全部客户访问。
    - 官方称关切源于窄域 jailbreak 演示（识别已知小漏洞），能力与其他公开模型相当；事件标志 frontier 模型「发布—召回」监管新范式，其他 Anthropic 模型不受影响。

### 新产品

- **Google AI Mode starts rolling out information agents**
  - 来源：**Google**
  - 时间：`260612`
  - 正文：~**720** tok
  - URL：https://blog.google/products-and-platforms/products/search/search-io-2026/
  - 类型：新产品
  - 要点：
    - **Information agents**：Search **AI Mode** 内 **7×24** 后台监控主题（博客/新闻/社交 + 实时财经/购物/体育），合成推送可行动更新；提示词含「keep me updated on」「alert me when」触发。
    - 首批面向 **Google AI Ultra**（$99.99–$199.99/月）全语言与市场；今夏扩展至 **AI Pro**，与 I/O 宣布的 agentic booking、Antigravity 自定义 Search 体验形成 agent 产品矩阵。
    - 代表 Google 从「单次查询」到「持久后台 agent」的 Search 交付形态；与同日 Kimi/MiniMax 开源模型形成「消费端 agent 服务 vs 开发者自托管」双轨。

- **GitHub Agentic Workflows is now in public preview**
  - 来源：**GitHub**
  - 时间：`260611`
  - 正文：~**800** tok
  - URL：https://github.blog/changelog/2026-06-11-github-agentic-workflows-is-now-in-public-preview/
  - 类型：新产品
  - 要点：
    - **Agentic Workflows**：在 **GitHub Actions** 内用 coding agent 自动化 issue 分流、CI 失败分析、文档更新等推理型任务；自然语言 **Markdown** 定义，编译为标准 Actions YAML。
    - 安全栈：默认只读权限、**Agent Workflow Firewall** 沙盒、integrity filter、safe outputs 校验、威胁检测 job 扫描变更后再应用；复用现有 runner 组与策略。
    - 公测起 agentic workflow **不再需要 PAT**；预置模板见 `githubnext/agentics`；Carvana、M&S、Hud.io 等已用于跨仓工程自动化。

- **Coinbase launches AI agent accounts that can trade and spend on your behalf**
  - 来源：**Coinbase**
  - 时间：`260611`
  - 正文：~**780** tok
  - URL：https://www.coindesk.com/tech/2026/06/11/coinbase-launches-ai-agent-accounts-that-can-trade-and-spend-on-your-behalf
  - 类型：新产品
  - 要点：
    - **Coinbase for Agents**：ChatGPT、Claude 等通过 **MCP** 直连 Coinbase 账户，在隔离组合内自主交易现货/衍生品、访问行情；未来支持股票与预测市场。
    - 集成 **x402** 开放机器支付协议，agent 可按次购买 premium research、数据 API、算力，无需订阅或手动结账。
    - 用户可设支出上限/交易限额/服务白名单；自然语言驱动组合再平衡与策略执行，代表 agentic commerce 从交易到支付的闭环交付。

- **OpenAI to acquire Ona**
  - 来源：**OpenAI**
  - 时间：`260611`
  - 正文：~**820** tok
  - URL：https://openai.com/index/openai-to-acquire-ona/
  - 类型：新产品
  - 要点：
    - OpenAI 收购 **Ona**（安全云执行与编排），将技术并入 **Codex** 生态；Codex 周活已超 **500 万**（年内 **4×** 增长）。
    - Ona 提供客户自控的持久云环境，agent 在笔记本关闭后仍可继续数小时/数天任务；已服务 **200 万** 开发者。
    - 企业可在自有云边界内运行 agent（凭证作用域、审计日志、审查流程），OpenAI 提供智能与编排；交易待监管审批，Ona 团队并入 Codex。

- **DXC will integrate Claude into the systems banks, airlines, and other regulated industries rely on**
  - 来源：**Anthropic**
  - 时间：`260611`
  - 正文：~**860** tok
  - URL：https://www.anthropic.com/news/dxc-anthropic-alliance
  - 类型：新产品
  - 要点：
    - Anthropic × **DXC** 多年全球联盟：培训数万 **Claude-certified FDE**（驻场工程师），将 Claude 带入银行/航空/保险/制造/政府等关键系统。
    - **DXC OASIS**（2026/4 上线）：AI-native 托管服务编排平台，Claude 为默认基础模型；**95%+** 代码由 Claude 生成后经工程师审查，已服务 **50+** 客户。
    - 四大落地场景：保险 agentic 方案、**MaaS** 遗留代码现代化、**Claude Security** 驱动的 7×24 SOC 子代理、应用维护嵌入 agent；DXC 加入 **Claude Partner Network**。

### 新模式

- **Investing in multi-agent AI safety research（百万 agent 交互安全研究范式）**
  - 来源：**DeepMind**
  - 时间：`260611`
  - 正文：~**560** tok
  - URL：https://deepmind.google/blog/investing-in-multi-agent-ai-safety-research/
  - 类型：新模式
  - 要点：
    - Google DeepMind 联合 Schmidt Sciences、ARIA、Cooperative AI Foundation、Google.org 设立 **$10M** 全球研究基金，截止日期 **8/8/2026**。
    - 核心论点：单 agent 或小群体研究无法预测百万级跨组织 agent 交互涌现风险；需沙盒仿真观察集体行为（含非理性决策）。
    - 四大方向：多 agent 沙盒/testbed、集体能力涌现与失效、跨平台身份/声誉协议、部署种群监控与缓解；代表行业从「造 agent」转向**系统性多 agent 安全**新学科。

- **Customer-controlled persistent cloud execution for long-running Codex agents**
  - 来源：**OpenAI**
  - 时间：`260611`
  - 正文：~**540** tok
  - URL：https://openai.com/index/openai-to-acquire-ona/
  - 类型：新模式
  - 要点：
    - Codex 高价值任务从「分钟级会话」转向「小时/天级委托」：agent 需在客户云内持久运行，人类可随时检查进度、注入方向、审批结果。
    - **Ona 模式**：智能与编排由 OpenAI 提供，执行环境/数据/安全边界由客户自控——区别于纯 SaaS agent 或纯自托管。
    - 代表 VibeCoding/agent 从「IDE 内交互工具」到「生产级后台自治工作流」的架构升级，与 GitHub Copilot 桌面多 worktree 并行形成对标。

- **Natural-language Markdown compiles to sandboxed agentic CI（NL → Agentic Actions 工作流）**
  - 来源：**GitHub**
  - 时间：`260611`
  - 正文：~**500** tok
  - URL：https://github.blog/changelog/2026-06-11-github-agentic-workflows-is-now-in-public-preview/
  - 类型：新模式
  - 要点：
    - 开发者用自然语言 **Markdown** 描述自动化意图，平台编译为标准 **Actions YAML** 并在沙盒内执行——降低 agentic CI 门槛同时保留策略约束。
    - 默认只读 + 多层防火墙/威胁扫描，解决「agent 能开 PR」到「agent 改动能被信任合并」的信任鸿沟。
    - 与 Cursor `/review`、Copilot Agent Merge 呼应，形成 **Spec-lite → 编译 → 沙盒执行 → 人工/自动审查** 的 VibeCoding 运维闭环。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
