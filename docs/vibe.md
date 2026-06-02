# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260531 07:01` UTC → `260602 07:01` UTC（48h，cron 触发 `2026-06-02T07:01Z`） |
| 本文件更新 | `260602 07:01` UTC |
| 条目数 | 13 |
| 新模型 / 新产品 / 新模式 | 13（新模型 3 · 新产品 6 · 新模式 4） |
| main 合并 commit | `ca66b97` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **NVIDIA Launches Cosmos 3, the Open Frontier Foundation Model for Physical AI**
  - 来源：**NVIDIA**
  - 时间：`260531`
  - 正文：~**1150** tok
  - URL：https://nvidianews.nvidia.com/news/nvidia-launches-cosmos-3-the-open-frontier-foundation-model-for-physical-ai
  - 类型：新模型
  - 要点：
    - 全球首个全开源 physical AI **omnimodel**：MoT 架构统一视觉推理、世界生成与动作预测；文本/图/视频/环境声/动作多模态。
    - **Cosmos3-Nano**（16B：8B reasoner + 8B generator，RTX 工作站级）与 **Cosmos3-Super**（64B：32B+32B，Hopper/Blackwell）已上 Hugging Face；**Cosmos3-Edge** 即将推出。
    - 同步 Cosmos Coalition（Agile Robots、Runway、Skild AI 等）；build.nvidia.com 试用、Diffusers `Cosmos3OmniPipeline`、NIM 与开源 SDG 数据集。

- **NVIDIA Launches Alpamayo 2 Super Open Reasoning Model for Robotaxis**
  - 来源：**NVIDIA**
  - 时间：`260601`
  - 正文：~**980** tok
  - URL：https://nvidianews.nvidia.com/news/nvidia-alpamayo-2-super-robotaxis
  - 类型：新模型
  - 要点：
    - 开源 **32B** 推理型 **VLA**：跨全栈驾驶栈推理、规划与行动，面向 L4 robotaxi；家族从 10B 扩至 32B。
    - 多任务：推理、自动标注、场景理解、模型批判、蒸馏到小模型；今夏 GitHub 推理代码 + Hugging Face 权重。
    - 配套 **AlpaGym**、**OmniDreams**、Omniverse **NuRec** 与 physical AI agent skills（神经重建、场景生成、闭环 RL）。

- **Mellum2 Goes Open Source: A Fast Model for AI Workflows**
  - 来源：**JetBrains**
  - 时间：`260601`
  - 正文：~**920** tok
  - URL：https://blog.jetbrains.com/ai/2026/06/mellum2-goes-open-source-a-fast-model-for-ai-workflows/
  - 类型：新模型
  - 要点：
    - **12B MoE**（每 token **2.5B** 激活）、Apache 2.0；base / instruct / thinking  checkpoint 与 [arXiv:2605.31268](https://arxiv.org/pdf/2605.31268) 技术报告。
    - 面向路由、RAG 摘要、子代理与私有部署；128K 上下文、GQA + 滑动窗口 + MTP 推测解码；同类模型推理速度 **>2×**。
    - 从单任务补全演进为工具调用与多步 agentic 工作流的 **focal model**（非多模态，专精 NL+代码）。

### 新产品

- **NVIDIA Unveils Vera, the CPU for Agents**
  - 来源：**NVIDIA**
  - 时间：`260531`
  - 正文：~**880** tok
  - URL：https://nvidianews.nvidia.com/news/nvidia-unveils-vera-the-cpu-for-agents
  - 类型：新产品
  - 要点：
    - 首款面向 **agentic AI / RL / 数据处理** 的 CPU，已量产；**88 Olympus** 核 + Spatial Multithreading，任务完成较 x86 **1.8×**。
    - **LPDDR5X** 最高 **1.2TB/s** 带宽；作 Vera Rubin 主机 CPU，**NVLink-C2C** 与 GPU 相干带宽达 **1.8TB/s**；机架级机密计算。
    - Dell/HPE/Lenovo/Supermicro 等 OEM 今年秋起提供独立 Vera 服务器；客户含 Anthropic、OpenAI、CoreWeave、OCI 等。

- **OpenAI models GPT-5.5 and GPT-5.4—and Codex—now on Amazon Bedrock**
  - 来源：**AWS**
  - 时间：`260601`
  - 正文：~**1020** tok
  - URL：https://www.aboutamazon.com/news/aws/bedrock-openai-models
  - 类型：新产品
  - 要点：
    - **GA**：GPT-5.5、GPT-5.4 经 Bedrock 下一代推理引擎 + **OpenAI 兼容 Responses API**；定价与 OpenAI 直客一致、无 AWS 加价，计入云承诺。
    - **Codex** 经 Bedrock 路由（CLI / 桌面 / VS Code），IAM、VPC、加密与现有 AWS 治理一致。
    - **Bedrock Managed Agents**（OpenAI agent harness + AgentCore）与多厂商模型同一控制台选型；6/1 更新为正式可用节点。

- **NVIDIA Releases Major Collection of Open Source Agent Tools and Skills for Physical AI**
  - 来源：**NVIDIA**
  - 时间：`260531`
  - 正文：~**1100** tok
  - URL：https://nvidianews.nvidia.com/news/nvidia-releases-major-collection-of-open-source-agent-tools-and-skills-for-physical-ai
  - 类型：新产品
  - 要点：
    - **NVIDIA Agent Toolkit** 开源 physical AI **skills**：Cosmos / Omniverse / Isaac / Metropolis / Alpamayo / Jetson 库可被编码代理直接调用。
    - 技能覆盖机器人、AV、视觉 AI、工业数字孪生、医疗仿真；含 Neural Reconstruction、Defect Image Generation、Video Augmentation 等。
    - GitHub + skills.sh 即用；**NemoClaw** blueprint + **OpenShell** 运行时做策略治理；Brev Physical AI Launchables 一键试玩。

- **openclaw 2026.5.31-beta.4**
  - 来源：**OpenClaw**
  - 时间：`260601 02:04`
  - 正文：~**1050** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.31-beta.4
  - 类型：新产品
  - 要点：
    - **Skill Workshop** Control UI：提案列表/今日动作/修订/文件预览/审查；`skill_workshop` 工具可 apply/reject/quarantine。
    - 官方插件 **`@openclaw/copilot`**（Copilot SDK harness）、**`@openclaw/tokenjuice`**；**Workboard** 多代理编排与 run 跟踪。
    - SQLite 化 iMessage 队列与插件安装索引；Tailscale Serve 绑定 Gateway；MiniMax M3 等 provider 元数据更新。

- **GitHub Copilot is moving to usage-based billing**
  - 来源：**GitHub**
  - 时间：`260601`
  - 正文：~**720** tok
  - URL：https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
  - 类型：新产品
  - 要点：
    - **6 月 1 日**起 Premium Request 改为 **GitHub AI Credits**（1 credit = $0.01）；按 input/output/cached token 与模型 API 价计费。
    - 月费不变（Pro $10、Pro+ $39 等），含等额 credits；**代码补全与 Next Edit 仍不限量**不扣 credits。
    - Business/Enterprise 6–8 月促销加赠 credits；组织级预算与池化用量；agentic 长会话成本与用量对齐。

- **Salt Security launches Salt Code**
  - 来源：**Salt**
  - 时间：`260601`
  - 正文：~**950** tok
  - URL：https://salt.security/press-releases/salt-security-launches-salt-code-the-first-agentic-security-solution-to-enforce-security-policies-inside-ai-coding-assistants
  - 类型：新产品
  - 要点：
    - 在 **Claude Code / Cursor / Copilot / Codex / Gemini CLI / Antigravity** 等助手内通过 **MCP** 实时强制执行安全策略（生成即合规）。
    - Posture Governance Engine 统一代码、控制面配置与运行时；预置 OWASP API、**MCP Security Top 10**、LLM Security、OpenAPI 等策略包。
    - 现有 Salt 客户无额外费用；非客户可通过 EAP（前 100 家）申请，覆盖 CI/CD 到 runtime 全链路。

### 新模式

- **NVIDIA Cosmos 3 omni-model：单 forward 多模态物理 AI**
  - 来源：**NVIDIA**
  - 时间：`260531`
  - 正文：~**620** tok
  - URL：https://huggingface.co/docs/diffusers/main/api/pipelines/cosmos3
  - 类型：新模式
  - 要点：
    - MoT：推理 transformer + 生成 expert 联合注意力，同一权重切换 VLM / 视频生成 / 动力学 / 策略。
    - 将「世界模型 + 策略」从多模型编排收敛为单 omni 前向，物理 AI 合成数据与仿真周期从月级压到日级。
    - Diffusers `Cosmos3OmniPipeline` 降低管线集成摩擦，配合 NIM 与 post-training 脚本形成端到端 SDG 工作流。

- **JetBrains focal model：大模型 + 专用小模型编排**
  - 来源：**JetBrains**
  - 时间：`260601`
  - 正文：~**540** tok
  - URL：https://huggingface.co/blog/JetBrains/mellum2-launch
  - 类型：新模式
  - 要点：
    - 高延迟敏感步骤（路由、检索摘要、规划校验）用 **Mellum2** 专模，前沿大模型处理复杂推理，降低 token 成本与尾延迟。
    - MoE 仅 2.5B 激活/token，适合高频子代理与本地私有部署；代表 VibeCoding 规模化下的「协调系统」而非单模堆叠。
    - 与 IDE / RAG / agent pipeline 解耦，可自托管 fine-tune，填补生产 AI 的吞吐瓶颈层。

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

- **OpenClaw Skill Workshop：可审查的技能演化**
  - 来源：**OpenClaw**
  - 时间：`260601 02:04`
  - 正文：~**560** tok
  - URL：https://github.com/openclaw/openclaw/releases/tag/v2026.5.31-beta.4
  - 类型：新模式
  - 要点：
    - 技能变更以 **proposal** 提交：扫描/哈希/回滚/隔离（quarantine），Gateway 与 Control UI 人工审查后再 apply。
    - `skill_workshop` agent 工具与 Codex app-server 提示联动，把「写 skill」纳入治理而非直接落盘。
    - 对应 VibeCoding 中「AI 改仓库能力需审计轨迹」的治理范式，与 Salt Code 等外部策略层形成互补。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
