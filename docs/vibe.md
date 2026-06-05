# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260603 07:01` UTC → `260605 07:01` UTC（48h，cron 触发 `2026-06-05T07:01Z`） |
| 本文件更新 | `260605 07:01` UTC |
| 条目数 | 13 |
| 新模型 / 新产品 / 新模式 | 13（新模型 5 · 新产品 6 · 新模式 2） |
| main 合并 commit | `4ab568b` |

---

## 资讯树

```text
vibe-48h/
├── 新模型
├── 新产品
└── 新模式
```

### 新模型

- **NVIDIA Nemotron 3 Ultra Powers Faster, More Efficient Reasoning for Long-Running Agents**
  - 来源：**NVIDIA**
  - 时间：`260604`
  - 正文：~**1120** tok
  - URL：https://developer.nvidia.com/blog/nvidia-nemotron-3-ultra-powers-faster-more-efficient-reasoning-for-long-running-agents/
  - 类型：新模型
  - 要点：
    - **550B-A55B** 开源 MoE（Hybrid Mamba-Attention LatentMoE + MTP），**1M** 上下文，面向长程 agent 编排（规划、工具、子 agent、验证、错误恢复）。
    - 权重/数据/配方全开放，**OpenMDW-1.1** 许可；Hugging Face、NVIDIA NIM、OpenRouter、Perplexity Pro；单 checkpoint 覆盖 Blackwell/Hopper/Ampere。
    - 官方称复杂 agent 负载推理吞吐最高 **~6×**、成本降 **~30%**；配套 agent harness cookbook（OpenClaw、OpenHands、CrewAI 等）。

- **Introducing Gemma 4 12B: a unified, encoder-free multimodal model**
  - 来源：**Google**
  - 时间：`260603`
  - 正文：~**920** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/
  - 类型：新模型
  - 要点：
    - **12B** 统一架构：**无独立 vision/audio encoder**，图/音直接进 LLM backbone；**Apache 2.0**，Hugging Face / Kaggle 权重。
    - 消费级 **16GB** 本机可跑 agentic 多模态；性能接近 **Gemma 4 26B MoE**，内存约一半；内置 **MTP** drafter 降延迟。
    - 配套 **Gemma Skills** 官方仓库，供 coding agent 生成 Gemma 应用；可上 Gemini Enterprise Model Garden / Cloud Run。

- **Aion 1.0 Instruct and Aion 1.0 Plan — on-device Windows SLMs**
  - 来源：**Microsoft**
  - 时间：`260603`
  - 正文：~**860** tok
  - URL：https://news.microsoft.com/build-2026-live-blog/microsoft-build-2026-live/
  - 类型：新模型
  - 要点：
    - **Aion 1.0 Instruct**：更小更快 on-device SLM，摘要/改写/意图/无障碍；Edge Insider 预览，**7 月** Hugging Face 开放权重。
    - **Aion 1.0 Plan**：**14B** 推理+工具调用、**32K** 上下文，将随 Windows 内置，支持本地文件/子 agent 编排。
    - 与 **Windows AI APIs**（CPU/NPU）协同，标志微软「云 frontier + 端侧 agent」双轨。

- **Dnotitia Releases DNA 3.0, an Enterprise-Ready AI Language Model Family**
  - 来源：**Dnotitia**
  - 时间：`260604`
  - 正文：~**780** tok
  - URL：https://www.prnewswire.com/news-releases/dnotitia-releases-dna-3-0--an-enterprise-ready-ai-language-model-family-302787871.html
  - 类型：新模型
  - 要点：
    - 开源权重家族 **0.8B–122B-A10B**（含 MoE **35B-A3B**、**122B-A10B**），面向企业 agent/RAG，已上 Hugging Face。
    - 与 **Seahorse Cloud** 集成：企业文档→语义检索→上下文回答→agent 工作流，强调组织数据微调而非裸 base。
    - 延续 DNA 1.0/2.0 韩文与 agent 路线，3.0 强化企业一致性与产品化部署档位。

- **SAR updates its first homegrown AI model**
  - 来源：**ChinaDaily**
  - 时间：`260604`
  - 正文：~**720** tok
  - URL：https://www.chinadaily.com.cn/a/202606/04/WS6a20d570a310d6866eb4c5cc.html
  - 类型：新模型
  - 要点：
    - 香港 **HKGAI V3**：token 压缩效率 **>10×**、agent 连续运行 **~100×**（对比上代）；**Agent Workshop** 单会话最长 **28h**。
    - 面向港府/企业垂直场景（HKChat、HKPilot）；同步以 **ClawNet** 名称开源，便于定制 agent。
    - 代表亚太区域「主权/本地化 agent 平台」与全球 frontier 模型并行迭代。

### 新产品

- **Be There for Every Customer With Meta Business Agent**
  - 来源：**Meta**
  - 时间：`260603`
  - 正文：~**980** tok
  - URL：https://about.fb.com/news/2026/06/meta-business-agent/
  - 类型：新产品
  - 要点：
    - **Meta Business Agent** 全球扩展至 WhatsApp / Instagram / Messenger 全规模商家；分钟级配置，多语言、品牌语气，可推荐商品、预约、成交、转人工。
    - 同步 **Meta Business Agent Platform**：企业可接 Shopify、Zendesk、Shopee 等，构建可规模部署的定制 agent，内置治理与计量。
    - 初期免费，数月后分层订阅；印/墨/巴试点已超 **100 万** 商家，日活 B2C 线程超 **10 亿**。

- **Nous Research Releases Hermes Desktop: A Native Cross-Platform Front End for Hermes Agent v0.15.2**
  - 来源：**Nous**
  - 时间：`260603`
  - 正文：~**840** tok
  - URL：https://www.marktechpost.com/2026/06/03/nous-research-releases-hermes-desktop-a-native-cross-platform-front-end-for-hermes-agent-v0-15-2-with-streaming-tool-output/
  - 类型：新产品
  - 要点：
    - **Hermes Desktop** 公测：Win/macOS/Linux 原生 GUI，**MIT** 开源；与 CLI/gateway 共享配置、会话、技能、记忆，**v0.15.2** 核心。
    - 流式工具输出、网页/文件预览、语音 I/O；五类沙箱后端（local/Docker/SSH/Singularity/Modal）；**MCP** 工具支持。
    - 模型无关，可接 Nous Portal（**300+** 模型）、OpenRouter、OpenAI；降低 OpenClaw 类 agent 的非技术用户门槛。

- **AlphaSense Introduces SuperAnalyst: The Always-On AI Agent for Decision-Grade Intelligence**
  - 来源：**AlphaSense**
  - 时间：`260603 08:00`
  - 正文：~**620** tok
  - URL：https://www.globenewswire.com/news-release/2026/06/03/3093842/0/en/AlphaSense-Introduces-SuperAnalyst-The-Always-On-AI-Agent-for-Decision-Grade-Intelligence.html
  - 类型：新产品
  - 要点：
    - **SuperAnalyst**：面向金融/战略团队的 **24/7** agent，代执行高价值研究、尽调、竞品与行业工作流，嵌入 AlphaSense 情报平台。
    - 基于平台 **>500M** 文档与实时数据馈送，输出可审计的决策级情报而非泛聊天。
    - 企业客户早期访问，数周内逐步扩面；代表垂直领域「always-on 专业 analyst agent」产品化。

- **MWM AI Partners with Google Cloud to Launch New Mobile Agents for App Creators and Entrepreneurs**
  - 来源：**MWM**
  - 时间：`260604`
  - 正文：~**900** tok
  - URL：https://www.prnewswire.com/news-releases/mwm-ai-partners-with-google-cloud-to-launch-new-mobile-agents-for-app-creators-and-entrepreneurs-302790646.html
  - 类型：新产品
  - 要点：
    - **AI Mobile Squad**：Designer / Product Manager / Developer 三 agent 串行协作，基于 **Gemini Enterprise** 与 **Nano Banana**，替代原 MWM AI 通用体验。
    - 提示词→原生 **Swift/Kotlin** iOS/Android 应用，内置 App Store / Google Play 发布、IAP、A/B 测试与增长工具。
    - 面向全球 **5 亿** 创作者与 SMB；公测后数月内全量开放，标志「多角色 agent 小队」进入移动应用制造场景。

- **Meshy Brings AI Agents to 3D Creation: Meshy 3D Agent Beta Launches**
  - 来源：**Meshy**
  - 时间：`260604 09:05`
  - 正文：~**680** tok
  - URL：https://www.eqs-news.com/news/corporate/meshy-brings-ai-agents-to-3d-creation-meshy-3d-agent-beta-launches/f1dbf054-7ab4-4bab-824f-a83364caa3e9_en
  - 类型：新产品
  - 要点：
    - **Meshy 3D Agent Beta** 全用户开放：从自然语言创意到可编辑 3D 资产的 agent 流水线（建模、材质、迭代）。
    - 将 3D 生产关键步骤封装为 agent 工作流，而非单步文生 3D；面向游戏、电商、设计从业者。
    - 在 meshy.ai 即时可用，拓展 VibeCoding 从 2D 代码/界面到 3D 资产生成。

- **Introducing the Services Track and Partner Hub of the Claude Partner Network**
  - 来源：**Anthropic**
  - 时间：`260603`
  - 正文：~**760** tok
  - URL：https://www.anthropic.com/news/services-track-partner-hub
  - 类型：新产品
  - 要点：
    - **Claude Partner Network** 新增 **Services Track** 分级（按已交付 Claude 项目能力认证）与 **Partner Hub** 门户（伙伴自评进度、客户查目录）。
    - 已有 **>4 万** 申请、**>1 万** 持 Claude 认证顾问；**$100M** 培训/技术支持/共营销基金延续。
    - 降低企业选型与落地 Claude agent 的摩擦，标志 frontier 厂商以「认证生态 + 交付目录」争夺企业 agent 实施层。

### 新模式

- **Frontier Tuning: Teaching AI to work the way you do**
  - 来源：**Microsoft**
  - 时间：`260603`
  - 正文：~**1020** tok
  - URL：https://devblogs.microsoft.com/microsoft365dev/frontier-tuning-teaching-ai-to-work-the-way-you-do/
  - 类型：新模式
  - 要点：
    - **Frontier Tuning**：在客户合规边界内，用 **RLE（Reinforcement Learning Environment）**「训练健身房」让 MAI 等模型从真实工作流轨迹学习，而非仅 SFT。
    -  tuned 模型/技能/编排逻辑留在客户环境，继承现有访问控制；Excel 场景官方称匹配 **GPT-5.4** 且 **~10×** 更高效。
    - 私有预览经 **FDE** 交付，后续进 **Copilot Studio** / **Foundry**；代表「保留 foundation + 组织内 RL 定制」的企业 agent 范式。

- **Multi-agent Mobile Squad（Designer → PM → Developer 串行编排）**
  - 来源：**MWM**
  - 时间：`260604`
  - 正文：~**520** tok
  - URL：https://www.prnewswire.com/news-releases/mwm-ai-partners-with-google-cloud-to-launch-new-mobile-agents-for-app-creators-and-entrepreneurs-302790646.html
  - 类型：新模式
  - 要点：
    - 将「全栈应用制造」拆为三个专职 agent 角色按序 handoff，而非单 generalist coding agent 端到端硬扛。
    - 每角色绑定不同 Gemini 能力与工具面（设计资产 / 产品规格 / Swift·Kotlin 实现），共享同一产品上下文。
    - 与 Microsoft Scout「单 Autopilot」、Zip「领域 Superagents」并列，体现 2026 年中「角色化多 agent 编排」成为可交付模式。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
