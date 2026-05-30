# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260528 05:51` UTC → `260530 05:51` UTC（48h，cron 触发） |
| 本文件更新 | `260530 05:51` UTC |
| 分支 | 已合并 **`origin/main`**（`27eaf3c`，`docs/vibe.md` 在 main） |
| 条目数 | 18 |
| token 估算 | 正文约 **字符数÷4**（英文为主）或 **÷1.8**（中文为主），取整 |

---

## 资讯树

```text
vibe-48h/
├── 资本市场 · IPO
├── 旗舰模型 · 产品
├── 智能体 · 编排 · 工具
├── VibeCoding · AI 编程
├── 安全 · 监管 · 地缘
└── 中国产业 · 开源
```

### 资本市场 · IPO

- **Anthropic 完成 650 亿美元 H 轮融资，投后估值 9650 亿美元**
  - 来源：**Anthropic**
  - 时间：`260528`（官方稿，具体时刻未标注）
  - 正文：~**420** tok
  - URL：https://www.anthropic.com/news/series-h
  - 要点：领投 Altimeter / Dragoneer / Greenoaks / 红杉；年化收入 run-rate 超 470 亿美元；含亚马逊等超大规模厂商此前承诺的 150 亿美元。

- **Anthropic 估值 9650 亿美元，超越 OpenAI**
  - 来源：**印经**
  - 时间：`260529 07:46`
  - 正文：~**380** tok
  - URL：https://www.business-standard.com/technology/tech-news/anthropic-valued-at-965-bn-after-latest-funding-round-eclipsing-openai-126052900081_1.html
  - 要点：Google 数亿美元跟投；OpenAI 3 月轮估值 8520 亿；双方均瞄准 2026 秋 IPO。

- **Anthropic bests OpenAI in valuation race, hitting $965B with Series H**
  - 来源：**PitchBook**
  - 时间：`260529`（文内标注，无具体时分）
  - 正文：~**520** tok
  - URL：https://pitchbook.com/news/articles/anthropic-bests-openai-in-valuation-race-hitting-965b-with-series-h
  - 要点：距 G 轮仅三个月再融 650 亿；算力侧与 AWS、Google/Broadcom、SpaceX Colossus 等签多 GW 级协议。

- **Anthropic raises further US$65bn to eclipse OpenAI**
  - 来源：**台北时报**
  - 时间：`260530`（纸媒日期，无具体时分）
  - 正文：~**450** tok
  - URL：https://www.taipeitimes.com/News/biz/archives/2026/05/30/2003858212
  - 要点：Micron、三星、SK 海力士首次同现 AI 公司 cap table；轮次数周凑齐。

- **Anthropic hits $965 billion valuation… HBM giants join cap table**
  - 来源：**BigGo**
  - 时间：`260529 06:06`
  - 正文：~**680** tok
  - URL：https://finance.biggo.com/news/notXcp4BoicNoOgCj55z
  - 要点：企业采用率首次超 OpenAI；Q2 有望首季运营盈利；OpenAI 或数日内秘密递交 SEC。

- **大模型周刊 第 32 期：上市、融资与梵蒂冈警告**（综合）
  - 来源：**80aj**
  - 时间：`260530`（周刊发布日）
  - 正文：~**2 400** tok
  - URL：https://www.80aj.com/2026/05/30/ai-week-32-warning/
  - 要点：OpenAI 5/22 秘密递表目标万亿估值；5/28 Anthropic 同日发 Opus 4.8 + 融资；教皇通谕《Magnifica…》83 页谈 AI 伦理。

### 旗舰模型 · 产品

- **Introducing Claude Opus 4.8**
  - 来源：**Anthropic**
  - 时间：`260528`（官方稿）
  - 正文：~**1 850** tok
  - URL：https://www.anthropic.com/news/claude-opus-4-8
  - 要点：同价升级；Effort 五档；Fast 模式降价 3×；预告 Mythos 级模型数周内面向客户（Glasswing 网络安全试点）。

- **Anthropic 计划解禁 Mythos 级模型**
  - 来源：**Prompt语宙**
  - 时间：`260528`（转载 5/28 宣布）
  - 正文：~**720** tok
  - URL：https://paooo.com/aigc-news/18242/
  - 要点：更强安全防护后几周内全量开放；同日 Opus 4.8 加量不加价。

- **OpenAI GPT-5.6 传下月发布：150 万上下文**
  - 来源：**T客邦**（转凤凰网）
  - 时间：`260529 14:00`
  - 正文：~**580** tok
  - URL：https://www.techbang.com/posts/129756-gpt-5-6-1-5m-context
  - 要点：Codex 日志现内部代号 iris-alpha / ember-alpha；90 万 token 实测仍流畅；6 月或与 Claude Sonnet 4.8、Gemini 3.5 Pro、Grok 5 撞档。

- **Keye-VL-2.0-30B-A3B：快手开源 30B 多模态**
  - 来源：**AI铺子**
  - 时间：`260529`
  - 正文：~**950** tok
  - URL：https://www.aipuzi.cn/ai-news/keye-vl-2-0-30b-a3b.html
  - 要点：Apache-2.0；DSA 稀疏注意力；256K 上下文；原生 Code/Tool/Search Agent；推荐/广告已量产。

### 智能体 · 编排 · 工具

- **Introducing dynamic workflows in Claude Code**
  - 来源：**Anthropic**
  - 时间：`260528`（官方稿）
  - 正文：~**680** tok
  - URL：https://claude.com/blog/introducing-dynamic-workflows-in-claude-code
  - 要点：单会话数十至数百并行子代理；对抗验证后汇总；Max/Team/Enterprise 研究预览；建议开 auto 权限避免审批卡住。

- **Orchestrate subagents at scale with dynamic workflows**
  - 来源：**Claude Code Docs**
  - 时间：`260528`（文档随功能上线）
  - 正文：~**1 100** tok
  - URL：https://code.claude.com/docs/en/workflows
  - 要点：需 v2.1.154+；prompt 含 `workflow` 或 `/effort ultracode`；JS 编排脚本 + 后台 runtime；`disableWorkflows` 可关。

- **Anthropic Ships Opus 4.8 with Multi-Agent Workflows**
  - 来源：**AwesomeAgents**
  - 时间：`260528`
  - 正文：~**900** tok
  - URL：https://awesomeagents.ai/news/claude-opus-48-dynamic-workflows/
  - 要点：SWE-bench Pro 69.2%；单 run 最多约 1000 agent、16 并发；五档 effort；Fast Mode 降价。

- **Cloud Agents | Cursor Docs**
  - 来源：**Cursor**
  - 时间：`260530`（文档持续更新，属产品 SSOT）
  - 正文：~**850** tok
  - URL：https://cursor.com/docs/cloud-agent
  - 要点：云端隔离 VM；GitHub/Slack/Linear/API 触发；`.cursor/environment.json` 配环境；企业可自托管 K8s worker。

- **AI Weekly: Cheaper Coding Models, Custom Chips, and a Stateless MCP**（节选 Cursor）
  - 来源：**Substack**
  - 时间：`260528`
  - 正文：~**1 200** tok（全文更长）
  - URL：https://amdatalakehouse.substack.com/p/ai-weekly-cheaper-coding-models-custom
  - 要点：综述 Composer 2.5 定价与 Cursor 3.3/3.5 并行 agent；48h 内行业周报入口。

### VibeCoding · AI 编程

- **Vibe Coding for Enterprise: A 2026 Practitioner's Guide**
  - 来源：**Tembo**
  - 时间：`260528`
  - 正文：~**1 600** tok
  - URL：https://www.tembo.io/blog/vibe-coding-for-enterprise
  - 要点：企业需沙箱、强制 PR、审计、凭据作用域；Karpathy 梗变预算线；无护栏则不适合生产。

- **From Human Coders to Autonomous AI Engineers**（Spec-Driven vs Vibe）
  - 来源：**Medium**
  - 时间：`260528`（文内无精确时分）
  - 正文：~**1 100** tok
  - URL：https://medium.com/@shuaib_18577/from-human-coders-to-autonomous-ai-engineers-the-future-of-software-development-db82ea2083b3
  - 要点：批判纯 Vibe 缺乏确定性；推 Spec-Driven Development（规格→计划→原子任务→实现）。

### 安全 · 监管 · 地缘

- **National cyber shield could be ready in five years**
  - 来源：**ComputerWeekly**
  - 时间：`260528 17:08`
  - 正文：~**520** tok
  - URL：https://www.computerweekly.com/news/366643734/National-cyber-shield-could-be-ready-in-five-years
  - 要点：GCHQ 局长 Keast-Butler 宣布国家级 agentic AI 网盾蓝图；五年内部署；覆盖能源、医疗、金融等 CNI。

- **GCHQ Chief Urges Action as AI Reshapes Cyber Threats**
  - 来源：**Infosecurity**
  - 时间：`260527`（Bletchley 演讲次日报道）
  - 正文：~**480** tok
  - URL：https://www.infosecurity-magazine.com/news/gchq-keast-butler-cyber-action-ai/
  - 要点：AI 为「不可阻挡之力」；呼吁企业把网安紧迫度提 10 倍；量子迁移与 passkey。

- **UK spy chief labels AI 'unstoppable force'…**
  - 来源：**CyberScoop**
  - 时间：`260528`（周三演讲）
  - 正文：~**420** tok
  - URL：https://cyberscoop.com/gchq-warns-ai-cyber-warfare-threats/
  - 要点：前沿模型快速暴露社会依赖软件的漏洞；俄 hybrid 战升级。

### 中国产业 · 开源

- **李开复、王小川双双战略大撤退…**
  - 来源：**BigGo TW**
  - 时间：`260529 01:58`
  - 正文：~**1 100** tok
  - URL：https://finance.biggo.com.tw/news/_t10cZ4BrAZSr0oSM00c
  - 要点：零一万物对标 Palantir、2026 盈利目标；百川 All in 医疗 M4；豆包付费争议、DeepSeek 降价、六小虎分化。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)（含「合并到 `origin/main`」必做步骤，避免只在 feature 分支收尾）。
- **upsert 规则**：新 cron 轮次在对应分类下追加/更新条目；超 48h 的叶子可移至文末 `## 归档`（尚未启用）。
- **去重**：同一官方事件（如 Anthropic 5/28 融资+模型）保留多源时，以 **Anthropic 官方** 为 SSOT，媒体稿仅补独家细节。
- **token 列**：为正文可读篇幅估算，非 API `usage` 计费值。
