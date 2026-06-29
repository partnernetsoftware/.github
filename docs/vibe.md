# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260627 07:00` UTC → `260629 07:00` UTC（48h，cron 触发 `2026-06-29T07:00Z`） |
| 本文件更新 | `260629 07:00` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 3 · 新产品 4 · 新模式 5） |
| main 合并 commit | `f4fecf3` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Anthropic Mythos 5 cleared for redeployment to 100+ trusted U.S. cyber partners (Fable 5 still blocked)**
  - 来源：**路透**
  - 时间：`260627`
  - 正文：~**680** tok
  - URL：https://www.japantimes.co.jp/business/2026/06/27/tech/anthropic-mythos-ai-us-use/
  - 类型：新模型
  - 要点：
    - **6/26–27** 美国商务部长 Lutnick 函告 Anthropic：经风险缓解，**Mythos 5** 可重新部署给 **100+** 可信美国组织（Fortune 500、联邦机构、关键基础设施防御方）；Anthropic 正快速恢复已批准客户访问。
    - **Fable 5** 仍全面封锁、无恢复时间表——形成「最强 cyber 档恢复、消费级 cyber 档仍禁」的非对称格局；距 **6/12** 全球下架约两周。
    - VibeCoding 影响：general-purpose cyber coding（Fable 5）持续不可用，agent 开发者需转向 Mythos 受限渠道、GPT-5.6 预览名单或开源/亚太替代（Sakana Fugu、Kimi K2.7 Code 等）。

- **Gemini 3.5 Pro general availability slips to July — second major Google AI delivery miss of 2026**
  - 来源：**FAQ**
  - 时间：`260628`
  - 正文：~**820** tok
  - URL：https://faq.com.tw/en/ai-ml/2026-06-28-google-gemini-35-pro-july-delay-talent-exodus-en/
  - 类型：新模型
  - 要点：
    - **6/27** Google 向合作伙伴确认：**Gemini 3.5 Pro** 不会在 **6 月** GA，仍 confined 于 Vertex AI 窄名单 enterprise preview；距 I/O **5/19** Pichai「give us until next month」承诺已 slip **≥6 周**。
    - 规格未变：承诺 **2M** token 上下文、Deep Think 推理、全模态；延迟主因包括 **2M context 生产级 latency/内存优化**未完成，以及 **6/21–27** 四位 senior researcher 离职（Shazeer→OpenAI、Jumper→Anthropic、Adler/Pritzel→Anthropic）。
    - 竞争窗口：OpenAI **GPT-5.6 Sol** 已 **6/26** 受限预览；Gemini 3.5 Pro 若 **7 月** 再 miss，frontier reasoning 叙事将进一步让位。

- **GPT-5.6 Sol/Terra/Luna preview unchanged through June 29 — no GA, no ChatGPT rollout announced**
  - 来源：**explainx**
  - 时间：`260629`
  - 正文：~**560** tok
  - URL：https://explainx.ai/blog/when-will-gpt-5-6-sol-terra-luna-be-available-everyone-2026
  - 类型：新模型
  - 要点：
    - **6/29** 触发时刻：**GPT-5.6** 三档仍仅限约 **20** 家政府知情 trusted partners 经 API/Codex 预览；ChatGPT Free/Plus/Pro、自服务 API signup **均未开放**；Congress **6/26** EO 30 天 deadline 已过，Commerce 无公开回应。
    - 定价/能力 SSOT 未变：Sol **$5/$30**、Terra **$2.50/$15**、Luna **$1/$6** per 1M tokens；Sol **Terminal-Bench 2.1** Ultra **91.9%**；**7 月** Cerebras **750 tok/s** Sol 仍计划限量上线。
    - 与 Anthropic **Fable 5** 仍全面 offline 并列：frontier coding 模型空窗期进入第三日，开发者短期更依赖 **Opus 4.8**、开源 **Kimi K2.7 Code/Ornith-1.0** 或 orchestration 层 **Sakana Fugu**。

### 新产品

- **gstack — Garry Tan's 23-persona Claude Code slash-command engineering team (MIT)**
  - 来源：**GitHub**
  - 时间：`260627`
  - 正文：~**780** tok
  - URL：https://github.com/garrytan/gstack
  - 类型：新产品
  - 要点：
    - **6/27** YC CEO **Garry Tan** 发布 **gstack**（MIT，**117K+** stars）：**23** 个 slash command 角色（CEO/Designer/Eng Manager/Release/Doc/QA/Security 等）+ **8** 工具，全 Markdown 配置，将 Claude Code 变为「虚拟工程团队」。
    - 核心命令：`/ship`（sync→test→coverage audit→PR）、`/review`（生产级 bug hunt）、`/qa`（真实浏览器测试）、`/security`（OWASP+STRIDE）；无专有 runtime，纯 Claude Code 配置层。
    - 标志 VibeCoding 从「单 agent 对话」转向**可 fork 的高层工程角色 playbook**——高管/创始人公开其 agent 工作流 SSOT。

- **DeepSpec + DSpark — open-source speculative decoding stack for DeepSeek-V4 (60–85% per-user speedup)**
  - 来源：**DeepSeek**
  - 时间：`260627`
  - 正文：~**880** tok
  - URL：https://github.com/deepseek-ai/DeepSpec
  - 类型：新产品
  - 要点：
    - **6/27** DeepSeek 开源 **DeepSpec**（MIT 全栈 speculative decoding 训练/评测工具链）及 **DSpark** 框架；Hugging Face 发布 V4 Pro / V4 Flash 的 DSpark 版 checkpoint（原 V4 权重 + draft 模块，非新架构）。
    - 生产实测（对比 MTP-1 baseline、吞吐不变）：V4-Flash 单用户生成 **+60–85%**、V4-Pro **+57–78%**；半自回归 draft + confidence-scheduled verification，离线 accepted length 超 Eagle3 **26–31%**。
    - 与 OpenAI Cerebras **750 tok/s** 硬件路线对照：DSpark 走** commodity GPU 算法加速**开源路线——agent 长循环推理成本显著下降。

- **GitHub Copilot deprecates Opus 4.6 (fast) — migration to Opus 4.8 (fast) effective June 29**
  - 来源：**GitHub**
  - 时间：`260629`
  - 正文：~**420** tok
  - URL：https://github.blog/changelog/2026-06-18-upcoming-deprecation-of-opus-4-6-fast/
  - 类型：新产品
  - 要点：
    - **6/29** **Opus 4.6 (fast)** 在 Copilot Chat、inline edits、ask/agent modes、completions **全面下线**；官方替代为 **Opus 4.8 (fast)**。
    - 背景：Anthropic **Fable 5** 自 **6/12** 在 Copilot 全平台 suspended；Opus 4.8 成为 enterprise 可用的最强 Anthropic 档，Enterprise admin 须在 Copilot model policy 显式启用。
    - VibeCoding 路由影响：依赖 Fable/Mythos cyber 档的团队需重新评估 Copilot model picker 与 BYOK 路径。

- **OpenMontage — first open-source agentic video production system (12 pipelines, 500+ skills)**
  - 来源：**GitHub**
  - 时间：`260627`
  - 正文：~**720** tok
  - URL：https://github.com/calesthio/OpenMontage
  - 类型：新产品
  - 要点：
    - **6/25–27** `calesthio/OpenMontage` 持续 GitHub Trending 前列：首个开源 **agent-first** 视频制作系统——**12** 条 pipeline、**52** 工具、**500+** agent skills；AGPL-3.0，**22K+** stars。
    - 无中央 Python orchestrator：AI 编码助手（Claude Code/Cursor/Codex/Copilot）读 YAML manifest + Markdown director skills 编排全流程（调研→脚本→资产生成→剪辑→合成）。
    - 覆盖 animated explainer、documentary montage、talking-head、screen-demo 等；集成 FFmpeg/Remotion/ElevenLabs/FLUX 等 **50+** 媒体工具——标志 agentic 工作流从代码 repo 向**多媒体生产**扩展。

### 新模式

- **Asymmetric cyber-model re-access — Mythos 5 restored, Fable 5 still blocked under export controls**
  - 来源：**POLITICO**
  - 时间：`260627`
  - 正文：~**540** tok
  - URL：https://www.politico.com/news/2026/06/26/white-house-makes-peace-with-anthropic-for-now-00965675
  - 类型：新模式
  - 要点：
    - **6/26–27** 白宫部分撤销 Anthropic export ban：**Mythos 5** 恢复 **100+** 已批准美企/机构访问，但 **Fable 5**（面向更广泛开发者/消费者的 cyber 能力档）仍全面禁运——「最强档先放、普及档后议」的分级恢复模式。
    - 与 OpenAI **GPT-5.6** 政府门控预览形成双厂商对齐：frontier cyber 模型发布默认附带**政府逐客户许可 + 非对称 tier 恢复**。
    - VibeCoding 影响：cyber coding 能力呈「tier 分级许可」新常态，agent harness 需内置 model routing fallback 与合规地域检测。

- **Government-gated staggered frontier release — vetted-partner preview before GA (GPT-5.6)**
  - 来源：**TC**
  - 时间：`260628`
  - 正文：~**600** tok
  - URL：https://techcrunch.com/2026/06/26/openai-unveils-gpt-5-6-sol-terra-and-luna-models-but-only-accessible-to-limited-preview-partners-for-now-per-us-gov/
  - 类型：新模式
  - 要点：
    - **6/26–28** 特朗普 **6/2** 网络安全 EO 后，OpenAI 接受「约 **20** 家 US-only trusted partners 预览 + 政府逐客户知情」；Euractiv 确认首批参与者**全部位于美国**，欧洲企业与监管机构暂无法访问。
    - OpenAI 称计划「as soon as next week」加入国际伙伴，但 **6/29** 仍无公开名单；OpenAI 在官方稿中公开反对此流程长期化。
    - 对 VibeCoding：frontier 模型地缘门控从 Anthropic 单边下架扩展为**双 frontier lab 对齐模式**——跨境 agent 产品需假设模型 API 可能因 export control 突然不可用。

- **Multi-agent engineering role playbook — slash-command personas as forkable org chart (gstack)**
  - 来源：**GitHub**
  - 时间：`260627`
  - 正文：~**480** tok
  - URL：https://github.com/garrytan/gstack
  - 类型：新模式
  - 要点：
    - gstack 将 Claude Code 从「通用 coding agent」拆为 **23** 个可组合角色（CEO/Designer/EngMgr/Release/Doc/QA/Security…），每个角色是独立 slash command + Markdown skill 文件。
    - 与 Microsoft **MAI-Code-1-Flash**、OpenAI **ultra subagent** 等厂商内建编排不同，gstack 走**零代码 fork 的组织 playbook** 路线——任何团队可复制并改写角色定义而不改 runtime。
    - 标志 VibeCoding 范式从 prompt engineering 转向**可版本化的 agent 组织设计**（AGENTS.md + 角色 manifest SSOT）。

- **Commodity GPU algorithm speed vs wafer-scale hardware — DSpark open-source path (DeepSeek)**
  - 来源：**MarkTechPost**
  - 时间：`260627`
  - 正文：~**520** tok
  - URL：https://www.marktechpost.com/2026/06/27/deepseek-releases-dspark-a-speculative-decoding-framework-that-accelerates-deepseek-v4-per-user-generation-60-85-over-mtp-1/
  - 类型：新模式
  - 要点：
    - **6/27** DSpark 以 **speculative decoding** 在 commodity GPU 上实现 V4 **+60–85%** 单用户加速，无需 Cerebras 等专用硬件；DeepSpec 同时开源训练/评测全栈，支持 Qwen3/Gemma 等非 DeepSeek 目标。
    - 与 OpenAI **GPT-5.6 Sol on Cerebras 750 tok/s**（**7 月**限量）形成「硬件独占速度 vs 算法开源速度」双轨——自托管/agent 平台更倾向后者。
    - agent 长循环成本模型变化：throughput 不变前提下 per-user latency 下降 → 同等预算可跑更多 tool-call 轮次。

- **Frontier lab delivery consistency as competitive moat — Gemini 3.5 Pro slip compounds talent exodus**
  - 来源：**FAQ**
  - 时间：`260628`
  - 正文：~**640** tok
  - URL：https://faq.com.tw/en/ai-ml/2026-06-28-google-gemini-35-pro-july-delay-talent-exodus-en/
  - 类型：新模式
  - 要点：
    - **6/28** 分析指出：Gemini 3.5 Pro 第二次 major delivery miss（继 Ultra 1.5 三延迟）与 **6/21–27** 人才流失（Shazeer/Jumper/Adler/Pritzel）形成**可信度 compound crisis**——benchmark 能力 vs 可预测 ship 能力分离。
    - 行业 implication：2026 下半年 frontier 竞争不只看 MMLU/SWE-Bench，还看**「announce→GA 周期可预测性」**——影响 enterprise agent 平台的 model routing 长期承诺。
    - 对 builder：reasoning-heavy 工作负载若等 Gemini 3.5 Pro，应设 **7 月** hard deadline 并准备 GPT-5.6 GA 或 Opus 4.8 fallback plan。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
