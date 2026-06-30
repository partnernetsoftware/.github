# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260628 07:02` UTC → `260630 07:02` UTC（48h，cron 触发 `2026-06-30T07:02Z`） |
| 本文件更新 | `260630 07:02` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 4 · 新产品 3 · 新模式 5） |
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

- **Meituan open-sources LongCat-2.0 — 1.6T MoE agentic coding model (Owl Alpha unmasked)**
  - 来源：**VB**
  - 时间：`260630`
  - 正文：~**920** tok
  - URL：https://venturebeat.com/technology/meituan-open-sources-longcat-2-0-the-1-6t-near-frontier-agentic-coding-model-thats-been-leading-openrouter-trained-entirely-on-chinese-chips
  - 类型：新模型
  - 要点：
    - **6/29–30** 美团正式开源 **LongCat-2.0**：**1.6T** MoE（每 token 激活 **33B–56B**）、原生 **1M** 上下文（LSA sparse attention）、**MIT** 许可；GitHub + Hugging Face + LongCat API 同步上线。
    - 基准：**SWE-bench Pro 59.5**（超 GPT-5.5 **58.6**）、**Terminal-Bench 2.1 70.8**；匿名 stealth 模型 **Owl Alpha** 两个月居 OpenRouter 调用量全球前三，日均 **559B** tokens。
    - 定价：标准 **$0.75/$2.95** per 1M in/out，限时 promo **$0.30/$1.20**；**context cache hit 免费**；全程在 **50K** 国产 ASIC 集群上训练，无 Nvidia GPU 依赖。

- **Gemini 3.5 Pro misses June GA — Polymarket closes 97% no-release; July target unchanged**
  - 来源：**BFwAI**
  - 时间：`260630`
  - 正文：~**780** tok
  - URL：https://www.buildfastwithai.com/blogs/ai-news-today-june-30-2026
  - 类型：新模型
  - 要点：
    - **6/30** 截止时刻 **Gemini 3.5 Pro** 仍未公开 GA；Polymarket「6/30 前发布」合约以 **97% No** 收盘（**$229K** 成交量），为连续第二次 major delivery miss。
    - 规格未变：承诺 **2M** token 上下文、**Deep Think** 推理（Ultra **$250/mo**）、全模态；延迟主因仍为长上下文 agentic 任务 **token 效率**与 **6/21–27** 四位 senior researcher 离职（Shazeer/Jumper/Adler/Pritzel）。
    - 竞争窗口：OpenAI **GPT-5.6** 政府门控预览中；**Gemini 3.5 Pro** 若 **7 月**再 miss，frontier reasoning 叙事将进一步让位；当前仍 confined 于 Vertex AI 窄名单 enterprise preview。

- **GPT-5.6 Sol/Terra/Luna preview unchanged through June 30 — no GA, no ChatGPT rollout**
  - 来源：**OpenAI**
  - 时间：`260629`
  - 正文：~**560** tok
  - URL：https://openai.com/index/previewing-gpt-5-6-sol/
  - 类型：新模型
  - 要点：
    - **6/29–30** 触发时刻：**GPT-5.6** 三档仍仅限约 **20** 家政府知情 trusted partners 经 API/Codex 预览；ChatGPT Free/Plus/Pro、自服务 API signup **均未开放**。
    - 定价/能力 SSOT 未变：Sol **$5/$30**、Terra **$2.50/$15**、Luna **$1/$6** per 1M tokens；Sol CTF **96.7%**、Terminal-Bench 2.1 **88.8%**；**7 月** Cerebras **750 tok/s** Sol 仍计划限量上线。
    - OpenAI 官方称不接受此流程长期化，但 **6/30** 仍无扩大名单公告；与 Anthropic **Fable 5** 全面 offline 并列，frontier cyber 模型空窗进入第四日。

- **Claude Fable 5 Day 18 — still offline; Axios reports imminent restore pending Pentagon/NSA sign-off**
  - 来源：**TechTimes**
  - 时间：`260629`
  - 正文：~**640** tok
  - URL：https://www.techtimes.com/articles/319318/20260629/gemini-35-pro-cleared-july-launch-fable-5-nears-return-gpt-56-stays-locked.htm
  - 类型：新模型
  - 要点：
    - **6/29** **Fable 5** 自 **6/12** Commerce 指令起第 **18** 日仍对 general users/API/Claude Code **全面 offline**；**Mythos 5** 部分恢复（**~100** 美关键基础设施组织）状态未变。
    - **6/27** Axios 引知情人士：白宫接近解除 Fable 5 限制，**Pentagon + NSA** 签批仍 pending；**7/8** Anthropic ID verification 或为 domestic 恢复路径。
    - 非对称格局持续：最强 cyber 档（Mythos）先放、消费级 cyber 档（Fable）仍禁；agent 开发者短期依赖 **Opus 4.8**、开源 **LongCat-2.0/GLM-5.2** 或 orchestration 层。

### 新产品

- **Cursor for iOS — public beta on all paid plans (cloud agents, Remote Control, Live Activities)**
  - 来源：**Cursor**
  - 时间：`260629`
  - 正文：~**720** tok
  - URL：https://cursor.com/changelog
  - 类型：新产品
  - 要点：
    - **6/29** Cursor **3.9** 发布 **iOS** 公测（全部付费计划）：从手机启动 **cloud agents**（隔离 VM + 完整 dev env）、**Remote Control** 本地桌面 agent、语音输入与 slash commands。
    - **Live Activities** + push 通知：锁屏追踪 agent 状态；可从手机审阅 demos/screenshots/diffs/logs 并 **直接 merge PR**。
    - 标志 VibeCoding 从桌面独占转向 **mobile-first agent supervision**——与 OpenAI **Codex Remote GA**（6/25）、Claude mobile→Claude Code 远程构成三强并列的「手机管 agent」产品矩阵。

- **GitHub Copilot deprecates Opus 4.6 (fast) — migration to Opus 4.8 (fast) effective June 29**
  - 来源：**GitHub**
  - 时间：`260629`
  - 正文：~**420** tok
  - URL：https://github.blog/changelog/2026-06-18-upcoming-deprecation-of-opus-4-6-fast/
  - 类型：新产品
  - 要点：
    - **6/29** **Opus 4.6 (fast)** 在 Copilot Chat、inline edits、ask/agent modes、completions **全面下线**；官方替代为 **Opus 4.8 (fast)**。
    - 背景：Anthropic **Fable 5** 自 **6/12** 在 Copilot 全平台 suspended；Opus 4.8 成为 enterprise 可用的最强 Anthropic 档，Enterprise admin 须在 Copilot model policy 显式启用。
    - 与 **6/1** 启用的 **GitHub AI Credits** 计量计费叠加：agent 模式按 token 消耗 credits，power user 账单较 flat-rate 时代 **10x–50x**。

- **LongCat-2.0 API billing live — Token Pack flash sales + zero-cost cache hits**
  - 来源：**LongCat**
  - 时间：`260630`
  - 正文：~**480** tok
  - URL：https://longcat.chat/platform/docs/ChangeLog.html
  - 类型：新产品
  - 要点：
    - **6/30** LongCat 平台 changelog 确认 **LongCat-2.0** 正式计费上线；深度兼容 **Claude Code、Hermes、OpenClaw、OpenCode、Kilo Code**。
    - 商业化创新：**Token Pack** 限量闪购（每日 **10:00/16:00/21:00/23:00** 北京时间四轮）、**30 天**有效；**cache hit 输入零计费**——长循环 agent 反复读同一 repo 时成本结构根本改变。
    - 与 OpenRouter/Hugging Face 开源权重并行：企业可自托管 MIT 权重或走 API，形成「开源权重 + 激进 cache 定价」双轨交付。

### 新模式

- **End of flat-rate AI for developers — GitHub Copilot first full metered billing cycle closes June 30**
  - 来源：**GitHub**
  - 时间：`260630`
  - 正文：~**680** tok
  - URL：https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
  - 类型：新模式
  - 要点：
    - **6/30** 为 Copilot **6/1** 切换 **GitHub AI Credits**（**1 credit = $0.01**）后首个完整账期截止日；社区反馈 power user 月费从 **$29→$750**、**$50→$3,000** 级跳涨。
    - 机制：agent mode、premium frontier models、multi-step autonomous tasks、code review **按 token 计费**；耗尽 included credits 后 premium 功能 **停止**（旧版会 fallback 便宜模型）。
    - 行业 implication：**Cursor**（2025/6）、**Windsurf**（2026/3）已走用量计费；**~$20 Pro + ~$200 power tier** 成为新常态——VibeCoding 从「无限 token 对话」转向 **per-agent-session 成本可见化**。

- **Karpathy ten-rule CLAUDE.md — loop self-check protocol beyond four-rule community template**
  - 来源：**TechTimes**
  - 时间：`260628`
  - 正文：~**740** tok
  - URL：https://www.techtimes.com/articles/319214/20260628/karpathy-claudemd-grows-ten-rules-new-self-check-protocol-ai-coding-loops.htm
  - 类型：新模式
  - 要点：
    - **6/28** 流传版 **Karpathy CLAUDE.md** 从社区四规则扩展为 **十规则**，副标题「Earned by Watching the Same Mistakes Twice」；新增 **Verification**（先写复现测试再修 bug）、**Debugging**（单变量变更）、**Common Failure Modes**（Kitchen Sink / Wrong Abstraction / Optimistic Path / Runaway Refactor 命名后 **立即停止**）。
    - 与 Boris Cherny「我不再 prompt，我写 loops」叙事对齐：四规则管 **turn-by-turn**，六新增管 **loop-level 自监控**——无人工每步审查时，named stop condition 是唯一刹车。
    - 技术机制：CLAUDE.md 以 **project context** 注入（非 system prompt）；`/goal`（2.1.139+）用独立 verifier model 判定完成条件——标志 VibeCoding 从 prompt engineering 转向 **可版本化的 loop harness 设计**。

- **De facto cyber-capability licensing — undefined Terminal-Bench/CTF threshold gates frontier releases**
  - 来源：**TechTimes**
  - 时间：`260629`
  - 正文：~**600** tok
  - URL：https://www.techtimes.com/articles/319318/20260629/gemini-35-pro-cleared-july-launch-fable-5-nears-return-gpt-56-stays-locked.htm
  - 类型：新模式
  - 要点：
    - **6/29** 分析指出：美国政府从未公布正式 cyber 能力阈值，但 **GPT-5.6 Sol CTF 96.7%** 触发门控、**Gemini 3.1 Pro Terminal-Bench 70.7%**（低 Sol **18+** pp）暂未触发——形成 **未定义 benchmark 驱动的 de facto involuntary licensing**（Dean Ball 语）。
    - **6/2** 网络安全 EO 要求 voluntary pre-release review，但无 appeals、无 published methodology、无 advance notice——frontier 模型可用性成为 **policy variable** 而非纯 commercial decision。
    - VibeCoding 影响：跨境 agent 产品须假设模型 API 可能因 export control **瞬间全球下架**；model routing 须内置合规地域检测 + 开源 fallback（LongCat/GLM 等）。

- **Domestic ASIC frontier training — LongCat-2.0 proves trillion-param scale without Nvidia GPUs**
  - 来源：**VB**
  - 时间：`260630`
  - 正文：~**520** tok
  - URL：https://venturebeat.com/technology/meituan-open-sources-longcat-2-0-the-1-6t-near-frontier-agentic-coding-model-thats-been-leading-openrouter-trained-entirely-on-chinese-chips
  - 类型：新模式
  - 要点：
    - **6/30** LongCat-2.0 在 **50K** 国产 ASIC 上端到端训练 **1.6T** MoE + **30T+** tokens pretrain，证明 near-frontier agentic coding 可不依赖 Nvidia GPU 集群规模化。
    - 与 Washington 限制西方 closed-source cyber 模型形成对照：regulatory lockdown → 全球开发者转向 **affordable open-weight 亚太替代**；OpenRouter 中国开源模型占比已达 **~60%**。
    - agent 成本模型双轨：OpenAI **Cerebras 750 tok/s** 硬件独占速度 vs LongCat **cache-zero + promo API** 算法/商业路线——自托管/agent 平台更倾向后者。

- **Mobile-first agent supervision — three-way race (Cursor iOS, Codex Remote, Claude mobile)**
  - 来源：**Sources**
  - 时间：`260630`
  - 正文：~**440** tok
  - URL：https://sources.news/p/why-cursor-made-an-iphone-app
  - 类型：新模式
  - 要点：
    - **6/30** Alex Heath 报道：工程师「边走边 review agent 产出」已成常态；Cursor 赌注 **专用 app > chatbot 外挂**（对比 Codex in ChatGPT、Claude mobile→desktop）。
    - Boris Cherny 公开称「大部分 coding 在手机上」——审批 PR、会议间隙 course-correct，而非逐行编辑；agent 须能 **长时 autonomous run + 周期性 human checkpoint**。
    - 工作流范式：从「盯着 IDE 看 agent 写代码」转向 **design loops + mobile approve**——VibeCoding 核心技能变为 loop harness 与 completion criteria 设计，而非 typing speed。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
