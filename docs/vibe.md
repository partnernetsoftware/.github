# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260528 06:04` UTC → `260530 06:04` UTC（48h，cron 触发 `2026-05-30T06:04Z`） |
| 本文件更新 | `260530 06:04` UTC |
| 条目数 | 13 |
| 新模型 / 新产品 / 新模式 | 11（新模型 3 · 新产品 5 · 新模式 3） |
| main 合并 commit | *（合并 push 后填写）* |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
├── 新模式
└── 资本动态
```

### 新模型

- **Introducing Claude Opus 4.8**
  - 来源：**Anthropic**
  - 时间：`260528`
  - 正文：~**1850** tok
  - URL：https://www.anthropic.com/news/claude-opus-4-8
  - 类型：新模型
  - 要点：
    - 同价升级 Opus 4.7（$5/$25 per M in/out；Fast 约 150% 更快、费用约降 3×）。
    - API 标识 `claude-opus-4-8`；默认 1M 上下文、128K 输出；Messages API 支持 messages 内 system 条目以 mid-task 更新指令。
    - SWE-bench Pro 69.2%、Terminal-Bench 2.1 74.2%；同日预告 Mythos 级模型数周内面向客户。

- **GPT-5.5 Instant Update（ChatGPT & API）**
  - 来源：**OpenAI**
  - 时间：`260528`
  - 正文：~**420** tok
  - URL：https://help.openai.com/en/articles/6825453-chatgpt-release-notes
  - 类型：新模型
  - 要点：
    - 对话风格更自然、更少冗长列表；写作/编码改由 chat 内 writing/code blocks 直接呈现。
    - GPT-5.5 Instant / Thinking 移除 Canvas；付费用户可经 legacy 模型短期继续用 Canvas。
    - ChatGPT 将退役 o3（`260826`）与 GPT-4.5（`260627`）；**仅 ChatGPT**，API 不变。

- **Keye-VL-2.0-30B-A3B：快手开源 30B 多模态**
  - 来源：**快手**
  - 时间：`260529`
  - 正文：~**950** tok
  - URL：https://huggingface.co/Kwai-Keye/Keye-VL-2.0-30B-A3B
  - 类型：新模型
  - 要点：
    - Apache-2.0；30B MoE（约 3B 激活）；DSA 稀疏注意力；256K 上下文。
    - 原生 Code / Tool / Search Agent 能力；推荐与广告场景已量产部署。

### 新产品

- **Introducing dynamic workflows in Claude Code**
  - 来源：**Anthropic**
  - 时间：`260528`
  - 正文：~**680** tok
  - URL：https://claude.com/blog/introducing-dynamic-workflows-in-claude-code
  - 类型：新产品
  - 要点：
    - 单会话可编排数十至数百并行子代理，对抗验证后汇总（研究预览）。
    - Max / Team / Enterprise；需 Claude Code v2.1.154+；prompt 含 `workflow` 或 `/effort ultracode`。
    - 官方文档：[`code.claude.com/docs/en/workflows`](https://code.claude.com/docs/en/workflows)。

- **Vibe gets to work.**
  - 来源：**Mistral**
  - 时间：`260528`
  - 正文：~**900** tok
  - URL：https://mistral.ai/news/vibe-agent/
  - 类型：新产品
  - 要点：
    - Le Chat 全面更名为 **Vibe**；Work Mode（Workspace/Slack/GitHub 等）与 Code Mode（云端沙箱、并行 PR）合一。
    - 发布 **Mistral Vibe VS Code 扩展**与 CLI `/teleport`（终端↔云端会话迁移）。
    - 定价：Free / Pro $14.99 / Team $24.99·user / Enterprise 定制。

- **What's new in Copilot Studio: May 2026**
  - 来源：**MS**
  - 时间：`260528`
  - 正文：~**1100** tok
  - URL：https://www.microsoft.com/en-us/microsoft-copilot/blog/copilot-studio/new-and-improved-computer-using-agents-a-new-workflows-experience-and-real-time-voice-experiences/
  - 类型：新产品
  - 要点：
    - **Computer-using agents** 在 Copilot Studio **GA**；无 API 系统可通过 UI 自动化。
    - 重设计 **workflows** 可视化编排；Work IQ 支持远程 **MCP** 与 **A2A** 代理互操作。
    - 北美 Dynamics 365 Contact Center **实时语音代理** GA；新编排层宣称 eval +20%、token −50%。

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

- **Introducing Workspace MCP: agentic financial workflows**
  - 来源：**OpenBB**
  - 时间：`260526`
  - 正文：~**720** tok
  - URL：https://openbb.co/blog/introducing-workspace-mcp/
  - 类型：新产品
  - 要点：
    - 开源 [`github.com/OpenBB-finance/workspace-mcp`](https://github.com/OpenBB-finance/workspace-mcp)；本地 sidecar + Workspace **MCP Companion**。
    - 代理可查询许可数据、生成可复用 **widget/仪表盘/多 tab 应用**（非只读问答）。
    - 继承 Workspace 权限、凭证保险库与数据 lineage；对接 Claude Code / Codex 等 MCP 客户端。

### 新模式

- **From Human Coders to Autonomous AI Engineers**
  - 来源：**Medium**
  - 时间：`260528`
  - 正文：~**1100** tok
  - URL：https://medium.com/@shuaib_18577/from-human-coders-to-autonomous-ai-engineers-the-future-of-software-development-db82ea2083b3
  - 类型：新模式
  - 要点：
    - 批判纯 **Vibe Coding** 缺乏确定性与可审计性。
    - 主张 **Spec-Driven Development**：规格 → 计划 → 原子任务 → 实现/验证闭环。
    - 与「一句话出整库」的 agent  hype 对照，强调工程可维护性。

- **Vibe Coding for Enterprise: A 2026 Practitioner's Guide**
  - 来源：**Tembo**
  - 时间：`260528`
  - 正文：~**1600** tok
  - URL：https://www.tembo.io/blog/vibe-coding-for-enterprise
  - 类型：新模式
  - 要点：
    - 企业级 Vibe 须配沙箱、强制 PR、审计日志、凭据作用域与策略门禁。
    - Karpathy「vibe」梗 → 需预算线与合规护栏才能进生产。
    - 将 AI 辅助编码纳入现有 SDLC，而非绕过 code review。

- **National cyber shield could be ready in five years**
  - 来源：**CW**
  - 时间：`260528 17:08`
  - 正文：~**520** tok
  - URL：https://www.computerweekly.com/news/366643734/National-cyber-shield-could-be-ready-in-five-years
  - 类型：新模式
  - 要点：
    - GCHQ 局长 Keast-Butler 提出国家级 **agentic AI** 网盾蓝图，目标约五年内覆盖 CNI（能源、医疗、金融等）。
    - 将自主代理用于威胁检测/响应编排，而非仅传统 SIEM 规则。
    - 与 Bletchley 演讲一脉：AI 为「不可阻挡之力」，呼吁企业把网安紧迫度提 10 倍。

### 资本动态

- **Anthropic raises $65B Series H at $965B post-money valuation**
  - 来源：**Anthropic**
  - 时间：`260528`
  - 正文：~**420** tok
  - URL：https://www.anthropic.com/news/series-h
  - 类型：其他
  - 要点：
    - 同日发布 **Claude Opus 4.8** 与 **dynamic workflows**；融资与产品绑定，非纯估值稿。
    - 年化收入 run-rate 超 470 亿美元；领投含 Altimeter / Dragoneer / Greenoaks / 红杉等。
    - 算力侧延续 AWS、Google、Broadcom 等多 GW 级协议；Micron / 三星 / SK 海力士首入 cap table 报道见媒体跟进。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
