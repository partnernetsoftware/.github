# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260629 07:00` UTC → `260701 07:00` UTC（48h，cron 触发 `2026-07-01T07:00Z`） |
| 本文件更新 | `260701 07:00` UTC |
| 条目数 | 14 |
| 新模型 / 新产品 / 新模式 | 14（新模型 5 · 新产品 4 · 新模式 5） |
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

- **Introducing Claude Sonnet 5**
  - 来源：**Anthropic**
  - 时间：`260630`
  - 正文：~**980** tok
  - URL：https://www.anthropic.com/news/claude-sonnet-5
  - 类型：新模型
  - 要点：
    - **6/30** Anthropic 发布 **Claude Sonnet 5**（API：`claude-sonnet-5`）：迄今最 agentic 的 Sonnet 档，性能逼近 **Opus 4.8**，较 **Sonnet 4.6** 在 reasoning/tool use/coding/knowledge work 全面提升；Free/Pro 默认模型，Claude Code 与 Platform 同步上线。
    - 定价：首发至 **8/31** **$2/$10** per 1M in/out，之后 **$3/$15**（约为 Opus 4.8 **$5/$25** 的一半）；effort 可调，BrowseComp/OSWorld-Verified 成本曲线部分任务可匹配 Opus 4.8。
    - 安全：默认启用 cyber safeguards（弱于 Fable 5）；纳入 **Cyber Verification Program**；同日博文编辑区确认 **Fable 5 将于 7/1 全球恢复**。

- **Redeploying Fable 5 — export controls lifted, global return July 1**
  - 来源：**Anthropic**
  - 时间：`260630`
  - 正文：~**1120** tok
  - URL：https://www.anthropic.com/news/redeploying-fable-5
  - 类型：新模型
  - 要点：
    - **6/30** Commerce 解除 **Fable 5 / Mythos 5** export controls；**7/1** 起 **Fable 5** 全球恢复于 Claude.ai、Claude Code、Cowork、API；AWS/GCP/Microsoft Foundry 将陆续重开。
    - 订阅计划：**7/7** 前 Fable 5 计入 Pro/Max/Team/部分 Enterprise 周用量上限的 **50%**，之后改走 usage credits；新 classifier 阻断 Amazon 报告中的 jailbreak 技术 **>99%**。
    - 与 **Sonnet 5** 同日发布，标志 frontier cyber 模型经历 **18 日** 全球下架后首次 consumer 级恢复；Mythos 5 仍限 Glasswing 伙伴。

- **Meituan open-sources LongCat-2.0 — 1.6T MoE agentic coding model**
  - 来源：**VB**
  - 时间：`260630`
  - 正文：~**920** tok
  - URL：https://venturebeat.com/technology/meituan-open-sources-longcat-2-0-the-1-6t-near-frontier-agentic-coding-model-thats-been-leading-openrouter-trained-entirely-on-chinese-chips
  - 类型：新模型
  - 要点：
    - **6/30** 美团开源 **LongCat-2.0**：**1.6T** MoE（每 token 激活 **33B–56B**）、原生 **1M** 上下文、**MIT** 许可；GitHub + Hugging Face + LongCat API 同步上线。
    - 基准：**SWE-bench Pro 59.5**（超 GPT-5.5 **58.6**）、**Terminal-Bench 2.1 70.8**；stealth 模型 **Owl Alpha** 两个月居 OpenRouter 调用量全球前三。
    - 全程在 **50K** 国产 ASIC 集群训练，无 Nvidia GPU 依赖；标准 **$0.75/$2.95** per 1M，promo **$0.30/$1.20**，**cache hit 免费**。

- **Nano Banana 2 Lite + Gemini Omni Flash — image/video models GA to developers**
  - 来源：**Google**
  - 时间：`260630`
  - 正文：~**860** tok
  - URL：https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-omni-flash-nano-banana-2-lite/
  - 类型：新模型
  - 要点：
    - **6/30** Google 向开发者 GA **Nano Banana 2 Lite**（`gemini-3.1-flash-lite-image`）：Nano Banana 家族最快最便宜图像模型，**4s** 文生图、**$0.034**/1K 图；同步 consumer 面（Search AI Mode、Gemini app 等）。
    - **Gemini Omni Flash**（`gemini-omni-flash-preview`）public preview：多模态视频生成 + 对话式编辑，**$0.10/s** 视频（同 Veo 3.1 Fast）；经 Gemini API、AI Studio、**Gemini Enterprise Agent Platform** 交付。
    - 工作流：Nano Banana 2 Lite 出图 → Omni Flash 动画；可用 **Interactions API** 维持多轮编辑上下文（最多 3 次连续编辑）。

- **GPT-5.6 Sol/Terra/Luna — limited preview unchanged through July 1, no ChatGPT GA**
  - 来源：**OpenAI**
  - 时间：`260629`
  - 正文：~**560** tok
  - URL：https://openai.com/index/previewing-gpt-5-6-sol/
  - 类型：新模型
  - 要点：
    - **6/29–7/1** 触发时刻：**GPT-5.6** 三档仍仅限约 **20** 家政府知情 trusted partners 经 API/Codex 预览；ChatGPT Free/Plus/Pro、自服务 API signup **均未开放**。
    - 定价/能力 SSOT 未变：Sol **$5/$30**、Terra **$2.50/$15**、Luna **$1/$6** per 1M tokens；Sol CTF **96.7%**、Terminal-Bench 2.1 **88.8%**；**7 月** Cerebras **750 tok/s** Sol 仍计划限量上线。
    - 与 **Fable 5** 恢复并列：frontier cyber 模型可用性仍高度依赖政府预审流程，非纯商业决策。

### 新产品

- **Claude Science — AI workbench for scientists (beta)**
  - 来源：**Anthropic**
  - 时间：`260630`
  - 正文：~**740** tok
  - URL：https://www.anthropic.com/news/claude-science-ai-workbench
  - 类型：新产品
  - 要点：
    - **6/30** Anthropic 发布 **Claude Science**：非新模型，而是面向科学家的 **AI workbench**（macOS/Linux beta，Pro/Max/Team/Enterprise）；整合常用科研数据库、代码工具与算力，产出可审计 artifact。
    - 多 agent 工作流：pipeline 在 lab 本地/HPC/SSH 运行，敏感数据不出境；reviewer agent 检查引用、数字与图表一致性；支持 session fork 对比方案。
    - 资助 **50** 个科研项目（最高 **$30K** credits，Modal 另供 **$2K** compute）；标志 Anthropic 从模型商向 **垂直行业 operating layer** 延伸（对标 Claude Code 之于软件工程）。

- **Cursor for iOS — public beta on all paid plans**
  - 来源：**Cursor**
  - 时间：`260629`
  - 正文：~**720** tok
  - URL：https://cursor.com/changelog
  - 类型：新产品
  - 要点：
    - **6/29** Cursor **3.9** 发布 **iOS** 公测（全部付费计划）：从手机启动 **cloud agents**（隔离 VM + 完整 dev env）、**Remote Control** 本地桌面 agent、语音输入与 slash commands。
    - **Live Activities** + push 通知：锁屏追踪 agent 状态；可审阅 demos/screenshots/diffs/logs 并 **直接 merge PR**；mobile app 内 **Composer 2.5** 至 **7/5** 享 **75% off**。
    - 标志 VibeCoding 从桌面独占转向 **mobile-first agent supervision**——与 OpenAI Codex Remote、Claude mobile→Claude Code 远程构成三强并列矩阵。

- **LongCat-2.0 API billing live — Token Pack flash sales + zero-cost cache hits**
  - 来源：**LongCat**
  - 时间：`260630`
  - 正文：~**480** tok
  - URL：https://longcat.chat/platform/docs/ChangeLog.html
  - 类型：新产品
  - 要点：
    - **6/30** LongCat 平台确认 **LongCat-2.0** 正式计费上线；深度兼容 **Claude Code、Hermes、OpenClaw、OpenCode、Kilo Code**。
    - 商业化创新：**Token Pack** 限量闪购（每日 **10:00/16:00/21:00/23:00** 北京时间四轮）、**30 天**有效；**cache hit 输入零计费**——长循环 agent 反复读同一 repo 时成本结构根本改变。
    - 与 OpenRouter/Hugging Face 开源权重并行：企业可自托管 MIT 权重或走 API，形成「开源权重 + 激进 cache 定价」双轨交付。

- **OpenCode v1.17.11 — session snapshots with full file revert**
  - 来源：**OpenCode**
  - 时间：`260630`
  - 正文：~**420** tok
  - URL：https://opencode.ai/changelog
  - 类型：新产品
  - 要点：
    - **6/30** OpenCode 发布 **session snapshots**：可将整个 session（含文件变更）回滚到任意历史消息，补齐相对 Claude Code `/rewind` 的缺口；同日启用 **Claude Sonnet 5** adaptive thinking。
    - 多 provider 架构不变（**75+** models via Models.dev）；MCP OAuth 重连、resource template listing、Opencode-managed provider 集成同步落地。
    - VibeCoding 工具链竞争焦点从「单模型能力」转向 **session 级可逆性与 harness 设计**——与 Karpathy 十规则 CLAUDE.md 叙事同向。

### 新模式

- **Glasswing jailbreak severity framework — four-axis scoring replaces ad-hoc shutdowns**
  - 来源：**Anthropic**
  - 时间：`260630`
  - 正文：~**680** tok
  - URL：https://www.anthropic.com/news/redeploying-fable-5
  - 类型：新模式
  - 要点：
    - **6/30** Anthropic 联合 **Amazon、Microsoft、Google** 等 Glasswing 伙伴起草 **jailbreak severity** 共识框架，拟替代 Fable 5 事件中「无标准即全球下架」的 ad-hoc 流程。
    - 四轴评分：**Capability gain**（相对现有工具增量）、**Breadth**（单 technique 覆盖多少 offensive task）、**Ease of weaponization**（prompt 复杂度/重试次数）、**Discoverability**（技术传播难度）。
    - 最 severe 级 jailbreak 将触发 **24/7 monitoring** + 即时 preliminary mitigations；同步启动 **HackerOne** Fable 5 cyber jailbreak 赏金计划——标志 frontier 模型发布从「能力竞赛」进入 **可量化安全 triage** 时代。

- **De facto cyber-capability licensing — undefined benchmark threshold gates frontier releases**
  - 来源：**TechTimes**
  - 时间：`260629`
  - 正文：~**600** tok
  - URL：https://www.techtimes.com/articles/319318/20260629/gemini-35-pro-cleared-july-launch-fable-5-nears-return-gpt-56-stays-locked.htm
  - 类型：新模式
  - 要点：
    - **6/29** 分析指出：美国政府从未公布正式 cyber 能力阈值，但 **GPT-5.6 Sol CTF 96.7%** 触发门控、**Gemini 3.1 Pro Terminal-Bench 70.7%** 暂未触发——形成 **未定义 benchmark 驱动的 de facto involuntary licensing**。
    - **6/2** 网络安全 EO 要求 voluntary pre-release review，但无 appeals、无 published methodology；**6/30** Fable 5 恢复显示流程可被逆转，但规则仍不透明。
    - VibeCoding 影响：跨境 agent 产品须假设模型 API 可能因 export control **瞬间全球下架**；model routing 须内置合规地域检测 + 开源 fallback（LongCat/GLM 等）。

- **End of flat-rate AI for developers — GitHub Copilot first full metered billing cycle closes June 30**
  - 来源：**GitHub**
  - 时间：`260630`
  - 正文：~**680** tok
  - URL：https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
  - 类型：新模式
  - 要点：
    - **6/30** 为 Copilot **6/1** 切换 **GitHub AI Credits**（**1 credit = $0.01**）后首个完整账期截止日；社区反馈 power user 月费从 **$29→$750**、**$50→$3,000** 级跳涨。
    - 机制：agent mode、premium frontier models、multi-step autonomous tasks、code review **按 token 计费**；耗尽 included credits 后 premium 功能 **停止**（旧版会 fallback 便宜模型）。
    - 行业 implication：**Cursor**、**Windsurf/Devin Desktop** 已走用量计费；**~$20 Pro + ~$200 power tier** 成为新常态——VibeCoding 从「无限 token 对话」转向 **per-agent-session 成本可见化**。

- **Mobile-first agent supervision — three-way race (Cursor iOS, Codex Remote, Claude mobile)**
  - 来源：**Sources**
  - 时间：`260630`
  - 正文：~**440** tok
  - URL：https://sources.news/p/why-cursor-made-an-iphone-app
  - 类型：新模式
  - 要点：
    - **6/30** Alex Heath 报道：工程师「边走边 review agent 产出」已成常态；Cursor 赌注 **专用 app > chatbot 外挂**（对比 Codex in ChatGPT、Claude mobile→desktop）。
    - Boris Cherny 公开称「大部分 coding 在手机上」——审批 PR、会议间隙 course-correct，而非逐行编辑；agent 须能 **长时 autonomous run + 周期性 human checkpoint**。
    - 工作流范式：从「盯着 IDE 看 agent 写代码」转向 **design loops + mobile approve**——VibeCoding 核心技能变为 loop harness 与 completion criteria 设计。

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

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
