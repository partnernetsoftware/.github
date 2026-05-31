# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260529 07:01` UTC → `260531 07:01` UTC（48h，cron 触发 `2026-05-31T07:01Z`） |
| 本文件更新 | `260531 07:01` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 4 · 新产品 6 · 新模式 2） |
| main 合并 commit | `e7e3875` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **Step 3.7 Flash**
  - 来源：**StepFun**
  - 时间：`260529`
  - 正文：~**1050** tok
  - URL：https://huggingface.co/stepfun-ai/Step-3.7-Flash
  - 类型：新模型
  - 要点：
    - Apache-2.0 开源权重；198B MoE（196B 语言 + 1.8B ViT），每 token 约 11B 激活；256K 上下文。
    - 原生多模态 + Agent 工具链；ClawEval-1.1 67.1、SWE-Bench Pro 56.3；API $0.20/$1.15 per M in/out。
    - 渠道：StepFun Platform、OpenRouter、NVIDIA NIM；vLLM / SGLang / llama.cpp 自托管。

- **Grok Build 0.1 on API**
  - 来源：**xAI**
  - 时间：`260529`
  - 正文：~**380** tok
  - URL：https://x.ai/news/grok-build-0-1
  - 类型：新模型
  - 要点：
    - `grok-build-0.1` 公测上线 xAI Responses API；与 Grok Build CLI 同模型，面向 agentic 编码与 MCP。
    - 定价 $1/M 输入、$2/M 输出；宣称 100+ tok/s；亦经 OpenRouter、Vercel AI Gateway 分发。
    - 推荐在 Grok Build、Cursor、Hermes Agent、OpenClaw 等 harness 中使用。

- **Keye-VL-2.0-30B-A3B：快手开源 30B 多模态**
  - 来源：**快手**
  - 时间：`260529`
  - 正文：~**950** tok
  - URL：https://huggingface.co/Kwai-Keye/Keye-VL-2.0-30B-A3B
  - 类型：新模型
  - 要点：
    - Apache-2.0；30B MoE（约 3B 激活）；DSA 稀疏注意力；256K 上下文。
    - 原生 Code / Tool / Search Agent 能力；推荐与广告场景已量产部署。

- **Gemini 3.5: frontier intelligence with action**
  - 来源：**Google**
  - 时间：`260529`
  - 正文：~**780** tok
  - URL：https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-omni-3-5-videos/
  - 类型：新模型
  - 要点：
    - **Gemini 3.5 Flash** 全球成为 Gemini App 与 Search AI Mode 默认模型；面向 agent/编码的长程任务。
    - GA 渠道：Antigravity、Gemini API / AI Studio、Android Studio、Gemini Enterprise；3.5 Pro 预告下月推出。
    - 与 Antigravity harness 联动，可编排协作子代理处理大规模工作流。

### 新产品

- **Codex updates: Computer use and remote control for Windows**
  - 来源：**OpenAI**
  - 时间：`260529`
  - 正文：~**380** tok
  - URL：https://help.openai.com/en/articles/6825453-chatgpt-release-notes
  - 类型：新产品
  - 要点：
    - Codex app 在 **Windows** 支持 Computer Use（见、点、键入本地应用）；主机仍为 Windows 项目上下文。
    - 可用 iOS/Android ChatGPT 或 Mac Codex **远程操控** Windows 会话；EEA/UK/CH 暂不可用。
    - 新增 **Codex Profiles**（身份、用量、token 活动统计）。

- **Gemini Spark rolls out to Google AI Ultra in the US**
  - 来源：**9to5G**
  - 时间：`260529`
  - 正文：~**720** tok
  - URL：https://9to5google.com/2026/05/29/gemini-spark-ultra-us/
  - 类型：新产品
  - 要点：
    - 24/7 云端个人代理；Gemini Web「Spark」标签页，移动端 Beta；Ultra 美国用户可用。
    - **Task / Schedule / Skill** 三组件；Workspace + Connected Apps；默认关闭 Gmail 等需显式授权。
    - 并发最多 15 任务；基于 Gemini 3.5 + Antigravity；今夏扩展本地文件与「代付款」能力。

- **Cloud Agents | Cursor Docs**
  - 来源：**Cursor**
  - 时间：`260530`
  - 正文：~**850** tok
  - URL：https://cursor.com/docs/cloud-agent
  - 类型：新产品
  - 要点：
    - 云端隔离 VM 运行代理；GitHub / Slack / Linear / API 触发。
    - `.cursor/environment.json` 定义依赖与构建；企业可自托管 K8s worker。
    - 与本地 Agent 并行，适合 cron / PR 自动化长任务。

- **openclaw 2026.5.30-beta.1**
  - 来源：**OpenClaw**
  - 时间：`260531 02:39`
  - 正文：~**920** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.30-beta.1
  - 类型：新产品
  - 要点：
    - **Workboard** 多代理编排与 run 跟踪；**Skill Workshop** + `skill_research` 工具治理提案生命周期。
    - 官方插件拆包：`@openclaw/copilot`、`@openclaw/tokenjuice`；iOS 托管 push relay 与 Talk 实时播放。
    - Agent/CLI 对中断工具调用、会话绑定、Codex 会话锁等恢复路径加固。

- **Hermes Agent v0.15.2 (2026.5.29.2)**
  - 来源：**Nous**
  - 时间：`260529 13:37`
  - 正文：~**680** tok
  - URL：https://github.com/NousResearch/hermes-agent/releases/tag/v2026.5.29.2
  - 类型：新产品
  - 要点：
    - 同日 hotfix v0.15.1→0.15.2：修复 dashboard 无限重载、kanban worker SIGTERM、`/model` 选择器统一。
    - 延续 v0.15.0「Velocity」：19k+ skills.sh 目录、MCP bare-command PATH、Docker `--insecure` 显式开关。
    - 面向多通道网关的终端/IDE agent 运行时，强调 MCP 与 skills 生态。

- **docker-agent v1.70.0**
  - 来源：**Docker**
  - 时间：`260529 12:12`
  - 正文：~**420** tok
  - URL：https://github.com/docker/docker-agent/releases/tag/v1.70.0
  - 类型：新产品
  - 要点：
    - Docker Engineering 的 **AI Agent Builder and Runtime** 版本迭代；Go 实现的开源 agent 平台。
    - `mcp_catalog` 工具新增 MCP server allow/block 列表，便于企业治理外部工具接入。
    - 与 Docker 桌面/容器栈集成，面向可复现的 agent 构建与运行环境。

### 新模式

- **Hexo Labs Open-Sources SIA: Self-Improving Agent**
  - 来源：**MTP**
  - 时间：`260529`
  - 正文：~**980** tok
  - URL：https://www.marktechpost.com/2026/05/29/hexo-labs-open-sources-sia-a-self-improving-agent-that-updates-both-the-harness-and-the-model-weights/
  - 类型：新模式
  - 要点：
    - **SIA**（MIT）：同一反馈环内同时改写 agent harness（提示/工具/重试）与 **LoRA** 权重（`gpt-oss-120b` rank 32）。
    - Feedback-Agent 按奖励在 scaffold 编辑 vs 权重更新间选择；LawBench / TriMul / scRNA 三域验证。
    - 开源 [`github.com/hexo-ai/sia`](https://github.com/hexo-ai/sia)；代表「自改进代理」新范式。

- **OpenClaw Workboard: multi-agent planning orchestration**
  - 来源：**OpenClaw**
  - 时间：`260531 02:39`
  - 正文：~**520** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.30-beta.1
  - 类型：新模式
  - 要点：
    - **Workboard** 提供编排原语与 agent 协调工具，用于多代理计划分解与 run 状态跟踪。
    - 与 Skill Workshop 提案流、`skill_research` 工具联动，形成「规划—执行—技能演化」闭环。
    - 个人助理栈向可观测的多 agent 车间演进，而非单会话黑盒。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
