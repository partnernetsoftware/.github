# Vibe 资讯（AI 大模型 · 智能代理 · VibeCoding）

## 元数据

| 项 | 值 |
|---|---|
| 采集窗口 | `260604 07:01` UTC → `260606 07:01` UTC（48h，cron 触发 `2026-06-06T07:01Z`） |
| 本文件更新 | `260606 07:01` UTC |
| 条目数 | 12 |
| 新模型 / 新产品 / 新模式 | 12（新模型 4 · 新产品 6 · 新模式 2） |
| main 合并 commit | `cbf138b` |

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

- **Gemma 4 QAT models: Optimizing model compression for mobile and laptop efficiency**
  - 来源：**Google**
  - 时间：`260605`
  - 正文：~**940** tok
  - URL：https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/
  - 类型：新模型
  - 要点：
    - 全家族 **QAT** 权重上线：**Q4_0** GGUF + 移动端专用量化格式；**E2B** 文本-only 可压至 **<1GB** 内存。
    - 训练期模拟量化，质量优于标准 PTQ；保留 **MTP** drafter 加速；Hugging Face / Ollama / LM Studio / LiteRT-LM 即日可用。
    - 延续 **Gemma 4 12B**（数日前发布）路线，把 on-device agentic 多模态推到消费级硬件。

### 新产品

- **Announcing Microsoft Web IQ**
  - 来源：**Microsoft**
  - 时间：`260604`
  - 正文：~**980** tok
  - URL：https://www.microsoft.com/en-us/webiq
  - 类型：新产品
  - 要点：
    - **Web IQ**：AI-native 网页/新闻/图/视频 grounding API 套件，返回 citation-ready 片段而非整页 HTML，**P95 ~164ms**。
    - **MCP-native**（JSON-RPC 2.0）+ REST/SDK；模型无关；已支撑 Copilot、ChatGPT 等 grounding；Azure 企业限量开放申请。
    - 标志 Bing 二十年搜索基建「为 agent 推理时刻」重构，把 web grounding 做成可复用云服务而非每团队自建爬虫。

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

- **Meshy Launches 3D Agent Beta, the World's First AI Agent for 3D Creation**
  - 来源：**Meshy**
  - 时间：`260604 09:05`
  - 正文：~**680** tok
  - URL：https://www.prnewswire.com/news-releases/meshy-launches-3d-agent-beta-the-worlds-first-ai-agent-for-3d-creation-302790052.html
  - 类型：新产品
  - 要点：
    - **Meshy 3D Agent Beta** 全用户开放：从自然语言创意到可编辑 3D 资产的 agent 流水线（建模、材质、迭代）。
    - 将 3D 生产关键步骤封装为 agent 工作流，而非单步文生 3D；面向游戏、电商、设计从业者。
    - 在 meshy.ai 即时可用，拓展 VibeCoding 从 2D 代码/界面到 3D 资产生成。

- **Dreaming: Better memory for a more helpful ChatGPT**
  - 来源：**OpenAI**
  - 时间：`260604`
  - 正文：~**860** tok
  - URL：https://openai.com/index/chatgpt-memory-dreaming/
  - 类型：新产品
  - 要点：
    - **Dreaming V3**：对话结束后后台合成记忆档案（工作/爱好/旅行等分类叙事），无需用户逐条「记住这个」。
    - 计算效率 **~5×** 提升，使 Free 档即将获得 dreaming 记忆；Plus/Pro 美国用户先行，记忆容量翻倍。
    - 新记忆摘要页可审阅/纠正/删除；代表 consumer agent「自动用户建模 + 时效衰减」产品化升级。

- **NVIDIA Nemotron 3 Ultra now available on Amazon SageMaker JumpStart**
  - 来源：**AWS**
  - 时间：`260605`
  - 正文：~**720** tok
  - URL：https://aws.amazon.com/blogs/machine-learning/nvidia-nemotron-3-ultra-now-available-on-amazon-sagemaker-jumpstart/
  - 类型：新产品
  - 要点：
    - **day-zero** 一键部署 **550B-A55B NVFP4** Nemotron 3 Ultra 至 SageMaker JumpStart，免自建 serving 框架。
    - 支持 **ml.p5en.48xlarge** 等 GPU 实例；面向 agent orchestrator、coding agent、deep research 企业工作负载。
    - 把 48h 内最强开源 agent 模型与 AWS 企业采购链打通，降低生产 agent 落地摩擦。

- **Unlocking dependable responses with Gemini Enterprise Agent Platform's Agentic RAG**
  - 来源：**Google**
  - 时间：`260605`
  - 正文：~**820** tok
  - URL：https://research.google/blog/unlocking-dependable-responses-with-gemini-enterprise-agent-platforms-agentic-rag/
  - 类型：新产品
  - 要点：
    - **Agentic RAG**（Cross-Corpus Retrieval）公测：多 agent 拆解企业复杂查询、迭代检索直至「足够上下文」再生成答案。
    - 对比标准 RAG，事实性数据集准确率最高 **+34%**；与 Gemini Enterprise Agent Platform 深度集成。
    - 输出可审计、可追溯、有引用，面向合规敏感的企业知识问答与 agent 后端。

### 新模式

- **Multi-agent Mobile Squad（Designer → PM → Developer 串行编排）**
  - 来源：**MWM**
  - 时间：`260604`
  - 正文：~**520** tok
  - URL：https://www.prnewswire.com/news-releases/mwm-ai-partners-with-google-cloud-to-launch-new-mobile-agents-for-app-creators-and-entrepreneurs-302790646.html
  - 类型：新模式
  - 要点：
    - 将「全栈应用制造」拆为三个专职 agent 角色按序 handoff，而非单 generalist coding agent 端到端硬扛。
    - 每角色绑定不同 Gemini 能力与工具面（设计资产 / 产品规格 / Swift·Kotlin 实现），共享同一产品上下文。
    - 与 Microsoft Scout「单 Autopilot」、Google Agentic RAG「检索-验证」并列，体现 2026 年中「角色化多 agent 编排」成为可交付模式。

- **Agent-native web grounding（passage-level evidence vs SERP scraping）**
  - 来源：**Microsoft**
  - 时间：`260604`
  - 正文：~**640** tok
  - URL：https://www.microsoft.com/en-us/webiq
  - 类型：新模式
  - 要点：
    - 从「给 agent 整页 HTML/SERP」转向「推理时刻注入 ranked passage + provenance」，优化 token 预算与多步链延迟。
    - **MCP 一等公民**：agent 通过 JSON-RPC 调用 grounding，而非每家 IDE 写定制搜索适配器。
    - 与 Google Agentic RAG「足够上下文再答」、OpenAI Dreaming「后台记忆合成」同属 2026 年 agent 基础设施层范式迁移。

---

## 维护说明

- **Automation 提示词 SSOT**：[`docs/vibe-cron-prompt.md`](vibe-cron-prompt.md)。
- **upsert**：新 cron 在 48h 窗口内追加/更新；过期条目可移至 `## 归档`（未启用）。
- **去重**：同一官方事件以厂商博客为 SSOT；媒体稿仅补独家细节。
- **~tok**：正文可读篇幅估算，非 API `usage` 计费。
