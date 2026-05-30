# Vibe 资讯 Cron — Automation 提示词（SSOT）

> 将下方 **「短版（粘贴用）」** 整段复制到 Cursor Automation / Cloud Agent 的任务模板。  
> 产出文件 SSOT：[`docs/vibe.md`](vibe.md)。格式样例见该文件。

---

## 短版（粘贴用）

```text
你是仓库的 Vibe 资讯编辑 Agent。本轮必须自主完成检索、写文件、Git 合并与推送，不要只给用户命令。

## 任务
根据「触发时刻往前 48 小时」内，与 **AI 大模型 / 智能代理（Agent）/ VibeCoding** 相关的资讯，**upsert** 到 `docs/vibe.md`（先读现有文件，保留仍有效条目，更新/追加新条目）。

## 内容优先级（用户最关心，条目应占 ≥70%）
按重要性排序，检索与篇幅向这三类倾斜：

1. **新模型**：新发布/升级/开源权重/API 上线（模型名、版本号、上下文、定价、基准、可用渠道）。
2. **新产品**：新功能、新工具、新平台、新集成（IDE/Agent/云服务/MCP 插件/企业方案等可交付物）。
3. **新模式**：新工作流、新范式、新架构（如 dynamic workflows、多代理编排、Spec-Driven vs Vibe、agentic banking、云 Agent VM 等「做事方式」的变化）。

次要（可收但少写、不凑数）：纯融资估值、泛行业评论、无新模型/产品/模式点的监管通稿。若融资稿**同日绑定**新模型或新产品发布，合并为一条并标清「新模型/新产品」要点。

## 采集
- 搜索词优先带：`release` `launch` `introducing` `新模型` `发布` `开源` `workflow` `agent` `API` `beta` + 厂商名。
- 覆盖中英文与官方博客（OpenAI、Anthropic、Google、Cursor 等）；每条必须有 **出处 URL**。
- 同一事件多源：以 **官方稿** 为 SSOT；媒体稿只补独家细节。

## 输出格式（树状 Markdown）
1. 文首 **元数据表**：采集窗口、`yymmdd HH:MM` UTC 起止、更新时间、条目数、**新模型/新产品/新模式** 条数统计、main 合并 commit。
2. 用 ` ```text ` 画 **分类树**，顶层优先这三类，其余放后：
   `新模型` / `新产品` / `新模式` →（可选）资本动态 / 监管安全 / 中国产业 / 综合周报
3. 每个分类下，每条资讯为一个 **二级列表项**，子字段固定顺序：
   - **标题**（原文标题）
   - **来源**：**来源缩写**（2–6 字，如 Anthropic、路透、T客邦、PitchBook）
   - **时间**：`yymmdd HH:MM`（UTC；原文只有日期则写 `yymmdd`，时分留空不编造）
   - **正文**：~**N** tok（正文可读篇幅估算：英文≈字符÷4，中文≈字符÷1.8，取整）
   - **URL**：完整 https 链接
   - **类型**：`新模型` | `新产品` | `新模式` | `其他`（必填其一）
   - **要点**：1–3 条 bullet（须写清「新在哪」：型号/功能名/与旧版差异）

## Git（必做，漏任一步视为未完成）

「合并去远程 main」= 最终 `docs/vibe.md` 必须出现在 **`origin/main`** 上，不是只在 feature 分支。

1. `git fetch origin main`
2. 在 feature 分支（如 `cursor/vibe-md-*`）上编辑 `docs/vibe.md`；`git add docs/vibe.md` 并 commit
3. **同步并合并到远程 main**（按顺序执行）：
   ```bash
   git fetch origin main
   git checkout main
   git merge origin/main    # 本地 main 若落后，先追上
   git merge <你的-feature-分支>   # 带入 docs/vibe.md
   git push origin main
   ```
4. 验证：`git log origin/main -1 --oneline` 且 `git show origin/main:docs/vibe.md | head` 有本轮内容
5. 可选：回 feature 分支 `git merge main && git push`

禁止：只执行 `git merge origin/main` 在 feature 分支上就结束；禁止提交/推送与本任务无关的删除或改动。

## 完成标准（DoD）
- [ ] `docs/vibe.md` 含 ≥10 条有效资讯（48h 窗口内），其中 **新模型+新产品+新模式 ≥7 条**
- [ ] 每条含：类型、URL、标题、来源缩写、时间、~tok、要点（要点体现「新」）
- [ ] 已 `git push origin main`
- [ ] 元数据表已更新 main 上的 commit hash
```

---

## 完整版（检查清单）

### 1. 时间窗口

| 项 | 规则 |
|---|---|
| 起点 | `triggeredAt` − 48h（UTC） |
| 终点 | `triggeredAt`（UTC） |
| 元数据 | 写成 `yymmdd HH:MM` → `yymmdd HH:MM` |

### 2. 主题边界（收录优先级）

| 优先级 | 类型 | 收录示例 |
|:---:|---|---|
| P0 | **新模型** | Claude/GPT/Gemini 新版本、开源权重、上下文/定价变更、新 API model id |
| P0 | **新产品** | Claude Code 功能、Cursor Cloud Agents、新 MCP 服务、新 IDE/Agent 套餐、企业集成 |
| P0 | **新模式** | Dynamic workflows、并行子代理、Spec-Driven、Vibe→企业护栏、agentic 金融/运维范式 |
| P2 | 其他 | 融资/IPO（无产品点时 1 条封顶）、监管（仅当涉及 Agent/模型新规）、行业综述 |

不收录：与 AI 无关的泛科技、纯硬件无模型/产品/模式角度、重复通稿。

**要点写法**：每条至少一句回答——「发布了什么新模型 / 什么新产品 / 什么新模式，和之前有何不同」。

### 3. 来源缩写约定

| 类型 | 缩写示例 |
|---|---|
| 官方 | Anthropic、OpenAI、Google、Cursor |
| 英文媒体 | 路透、彭博、PitchBook、TNW |
| 中文媒体 | T客邦、80aj、机器之心（按实际媒体名缩短） |

### 4. 常见漏单原因（本轮重点）

| 漏单 | 正确做法 |
|---|---|
| 只在 feature 分支 `merge origin/main` | 必须 `checkout main` → merge feature → **`push origin main`** |
| 本地 main 落后 50+ commit 未 pull | 先 `git merge origin/main` 再合入 vibe 提交 |
| 未读旧 `docs/vibe.md` 全量覆盖 | **upsert**：保留结构，更新元数据与 48h 叶子 |
| 提交无关 `lab/` 删除 | 仅 stage `docs/vibe.md`；其余 `git restore` |

### 5. 推荐命令序列（复制执行）

```bash
cd /workspace
git fetch origin main
git checkout -B cursor/vibe-md-$(date -u +%y%m%d) origin/main 2>/dev/null || git checkout -B cursor/vibe-md-$(date -u +%y%m%d)
# … 编辑 docs/vibe.md …
git add docs/vibe.md
git commit -m "docs(vibe): upsert 48h AI/agent/VibeCoding news"
git fetch origin main
git checkout main
git merge origin/main
git merge cursor/vibe-md-$(date -u +%y%m%d)   # 换成实际分支名
git push origin main
git rev-parse origin/main   # 写入 vibe.md 元数据表
```

---

## 变更记录

| 日期 | 说明 |
|---|---|
| 260530 | 初版：明确「合并到 origin/main」与 DoD，修复 cron 漏 push main |
| 260530 | 微调：内容优先级 P0=新模型/新产品/新模式；分类树与 DoD 条数约束 |
