# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260530 07:00` UTC → `260601 07:00` UTC（48h，cron 触发 `2026-06-01T07:00Z`） |
| 本文件更新 | `260601 07:00` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 1 · 新产品 6 · 新模式 5） |
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

- **Welcome NVIDIA Cosmos 3: The First Open Omni-model for Physical AI Reasoning and Action**
  - 来源：**NVIDIA**
  - 时间：`260601`
  - 正文：~**1180** tok
  - URL：https://huggingface.co/blog/nvidia/cosmos-3-for-physical-ai
  - 类型：新模型
  - 要点：
    - 统一 omni WFM：世界生成 + 物理推理 + 动作生成；MoT 架构替代此前 Predict/Reason/Transfer/Policy 多模型拼装。
    - **Cosmos3-Nano**（8B reasoner+8B generator，RTX 级）与 **Cosmos3-Super**（32B+32B，Hopper/Blackwell）同日上 Hugging Face；Diffusers `Cosmos3OmniPipeline`。
    - 开源 SDG 数据集 + GitHub 后训练脚本；面向机器人/自动驾驶/智能空间物理 AI。

### 新产品

- **Genesis World 1.0 Physics Platform（Nyx · Quadrants · 仿真接口）**
  - 来源：**Genesis**
  - 时间：`260530`
  - 正文：~**1050** tok
  - URL：https://www.genesis.ai/blog/the-role-of-simulation-in-scalable-robotics-genesis-world-10-and-the-path-forward
  - 类型：新产品
  - 要点：
    - Apache 2.0 开源四件套：统一多物理引擎、**Nyx** 实时光追渲染、**Quadrants** Python→GPU 编译器、仿真/数字孪生接口。
    - 宣称数百任务×数百 episode 评估：<0.5h 仿真 vs >200h 真机；Pearson 与真机 rollout 相关 0.90（zero-shot real-to-sim，训练不用仿真数据）。
    - 仓库：`genesis-world` / `genesis-nyx` / `quadrants`（`pip install quadrants`）。

- **openclaw 2026.5.30-beta.1**
  - 来源：**OpenClaw**
  - 时间：`260531 02:39`
  - 正文：~**920** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.30-beta.1
  - 类型：新产品
  - 要点：
    - **Workboard** 多代理编排与 run 跟踪；**Skill Workshop** + `skill_research` 治理技能提案生命周期。
    - 官方插件拆包：`@openclaw/copilot`、`@openclaw/tokenjuice`；iOS 托管 push relay 与 Talk 实时播放。
    - Agent/CLI 对中断工具调用、会话绑定、Codex 会话锁等恢复路径加固。

- **openclaw 2026.5.31-beta.4**
  - 来源：**OpenClaw**
  - 时间：`260601 02:04`
  - 正文：~**980** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.31-beta.4
  - 类型：新产品
  - 要点：
    - **Skill Workshop** Control UI：提案列表/今日动作/修订/文件预览/审查状态；`skill_workshop` 工具可 apply/reject/quarantine。
    - `@openclaw/copilot` 将 GitHub Copilot CLI/SDK 运行时外置为官方插件（`openclaw plugins install`）；**Code mode** 命名空间与 MCP API 文件。
    - SQLite 化 iMessage 队列/插件安装索引；Tailscale Serve 绑定 Gateway；MiniMax M3 等 provider 元数据更新。

- **Copilot SDK harness — `@openclaw/copilot`**
  - 来源：**OpenClaw**
  - 时间：`260601`
  - 正文：~**720** tok
  - URL：https://docs.openclaw.ai/plugins/copilot
  - 类型：新产品
  - 要点：
    - 通过 `@github/copilot-sdk` 在 OpenClaw 内跑订阅级 Copilot agent turn，替代内置 PI harness（按需安装 ~260MB）。
    - 配置 `agentRuntime: { id: "copilot" }` 于 `github-copilot/*` 模型；设备登录或 `gitHubToken` 无头/cron。
    - 与 Copilot 1M 上下文变体、动态模型目录刷新联动；适合要 Copilot 自有 compaction/线程态的场景。

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

- **GitHub Copilot is moving to usage-based billing**
  - 来源：**GitHub**
  - 时间：`260601`
  - 正文：~**640** tok
  - URL：https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
  - 类型：新产品
  - 要点：
    - **6 月 1 日**起 Premium Request 改为 **GitHub AI Credits**（1 credit = $0.01）；按 input/output/cached token 与模型 API 价计费。
    - 月费不变（Pro $10、Pro+ $39 等），含等额 credits；**代码补全与 Next Edit 仍不限量**不扣 credits。
    - Business/Enterprise 6–8 月促销加赠 credits；组织级预算与池化用量；agentic 长会话成本与用量对齐。

### 新模式

- **Genesis zero-shot real-to-sim 评估范式**
  - 来源：**Genesis**
  - 时间：`260530`
  - 正文：~**880** tok
  - URL：https://www.genesis.ai/blog/the-role-of-simulation-in-scalable-robotics-genesis-world-10-and-the-path-forward
  - 类型：新模式
  - 要点：
    - 仿真优先作 **评估/迭代引擎**，训练管线暂不用仿真数据，避免「评测分布=训练分布」虚假提升。
    - 14 任务×200 episode：Pearson 0.90、MMRV 0.017；侧-by-side 真机/仿真 rig 可逐层归因物理/渲染/控制差距。
    - 代表机器人基础模型开发从「墙钟真机」转向「可重复算力评测」的工作流转变。

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

- **OpenClaw Skill Workshop：可审查的技能演化**
  - 来源：**OpenClaw**
  - 时间：`260601 02:04`
  - 正文：~**560** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.31-beta.4
  - 类型：新模式
  - 要点：
    - 技能变更以 **proposal** 提交：扫描/哈希/回滚/隔离（quarantine），Gateway 与 Control UI 人工审查后再 apply。
    - `skill_workshop` agent 工具与 Codex app-server 提示联动，把「写 skill」纳入治理而非直接落盘。
    - 对应 VibeCoding 中「AI 改仓库能力需审计轨迹」的治理范式。

- **Copilot agentic 计费：从席位到 token 预算**
  - 来源：**GitHub**
  - 时间：`260601`
  - 正文：~**480** tok
  - URL：https://docs.github.com/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises
  - 类型：新模式
  - 要点：
    - Chat、CLI、**Copilot cloud agent**、Spaces、Spark 等均消耗 AI credits；补全类功能除外。
    - 组织 **池化 credits** + 企业/成本中心/用户预算；耗尽后需显式开启超额计费而非静默降级模型。
    - 倒逼团队为长时 agent 会话建立用量可见性与成本归因（VibeCoding 规模化前提）。

- **NVIDIA Cosmos 3 omni-model：单 forward 多模态物理 AI**
  - 来源：**NVIDIA**
  - 时间：`260601`
  - 正文：~**620** tok
  - URL：https://huggingface.co/docs/diffusers/main/api/pipelines/cosmos3
  - 类型：新模式
  - 要点：
    - MoT：AR 子序列（推理/理解）+ DM 子序列（扩散生成）联合注意力，同一权重切换 VLM/视频生成/动力学/策略。
    - 文本/图/视频/动作统一编码；支持 T2V、I2V、前向/逆向动力学与 policy 输出，无需换 pipeline 架构。
    - 将「世界模型 + 策略」从多模型编排收敛为单 omni 前向，改变物理 AI 合成数据与仿真工作流。

- **Quadrants：Python 即 GPU 物理内核**
  - 来源：**Genesis**
  - 时间：`260530`
  - 正文：~**540** tok
  - URL：https://github.com/Genesis-Embodied-AI/quadrants
  - 类型：新模式
  - 要点：
    - 从 Taichi fork；纯 Python 内核 JIT 到 CUDA/ROCm/Metal/Vulkan/CPU；单步录成 kernel graph 降 launch 开销。
    - 相对上游 Taichi 操作/运动基准最高 **4.6×**；warm-cache 启动 7.2s→0.3s；PyTorch DLPack 零拷贝。
    - 使「写 Python、跑集群级并行仿真」成为机器人/agent 数据飞轮的基础设施层。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
