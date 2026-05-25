# Dev Agents Team（实用板 · V4 映射）

来源：强模型对长程 V4 的编排建议；与本仓库 [`skills/squad-parallel/`](../../../skills/squad-parallel/)、[`skills/nano-lisp-jit-v4-longrun/`](../../../skills/nano-lisp-jit-v4-longrun/) 对齐。

---

## 1. 六角色（完整板）

| 角色 | 模型档位 | 职责 |
|------|----------|------|
| **Commander** | 最高级 | 目标、约束、拆解、**最终裁决**（合 main / 停不停 / 终局口径） |
| **Planner** | 中高级 | 目标 → **任务树**（波次、四轨、touch 边界） |
| **Worker Pool** | 便宜、快 | **并行**执行可验证子任务 |
| **Critic** | 强模型或**异构**模型 | 漏洞、反证、风险（catalog≠终局、假进度） |
| **Integrator** | 高 Q | 合并 Worker 产出 → 可提交 diff |
| **Memory / Context** | 便宜或**程序** | 摘要、检索、压缩（**禁止**靠 regex 改 markdown 指针） |

### 最小编制

```text
1 × Commander + 3–5 × Workers + 1 × Critic
```

---

## 2. 调度四问（每个任务先问）

| 问题 | 是 → | 否 → |
|------|------|------|
| **失败代价高吗？** | 强模型（Commander / Critic） | 可下放 |
| **可验证吗？** | Worker（脚本 / cc + `run.sh`） | 需 Critic 或 Commander |
| **能拆小吗？** | Worker Pool 并行 | 整包给 Integrator |
| **需要创造性判断吗？** | 上交 Commander | Worker 执行 |

**不追求「很多 agent」**，追求：

- **强模型**：控方向、少调用  
- **弱模型 / 程序**：批量执行、多调用  
- **异构 Critic**：交叉验证  
- **程序**：记忆与调度（`longrun-state.json`、skill、`gen-v4-wave-batch.py`）

---

## 3. V4 本仓库映射

| 理论角色 | V4 实现 | 工具 |
|----------|---------|------|
| Commander | Cursor Cloud Agent（本 Agent） | 指针、`/goal`、PR、EVAL 六维裁决 |
| Planner | Commander 兼；产出 `WAVES` 表 + `cc-task-*.txt` | `gen-v4-wave-batch.py` |
| Worker | **gen apply**（确定性）、**cc-huoshan**（C/run.sh） | `bun … apply`、stdin cc-task |
| Critic | `run.sh` + **PROGRESS 诚实口径** + 可选第二模型 | gate；catalog≠终局 |
| Integrator | skill `bump` + git commit + PR body | `nano-lisp-jit-v4-longrun.ts` |
| Memory | **`longrun-state.json` SSOT** | `v4-longrun-state.py` / skill `show` |

### 禁止

- Commander 亲自改 `nano_bootstrap.c` / `run.sh` 碎活（应写 cc-task 给 Worker）  
- 用 markdown 正则改指针（用 state SSOT）  
- 每批 3 波各跑一次全量 `run.sh`（用 `--gate-every N`）

---

## 4. 一批 3 波的标准编排（wave N…N+2）

```text
Commander: 读 state → 扩 WAVES → 写 cc-task（高代价 C 轨）
     ├─ Worker(gen):  python3 gen-v4-wave-batch.py N N+2
     ├─ Worker(cc):   cc-huoshan < cc-task-waveN-M.txt   [并行]
     └─ Worker(skill): loop --batches 3 --gate-every 3 --goal wave(N+2)
Critic:    run.sh exit 0 + PROGRESS 未夸大
Integrator: bump → EVAL/本表/LONG-RUN-TODO → commit → PR
Memory:    longrun-state.json only
```

## 4b. 先扩散后并发（提速 · wave149+）

见 [`DIFFUSE-WORKFLOW.md`](DIFFUSE-WORKFLOW.md)。

```text
Commander:  gen-v4-wave-batch.py 149 165   # 一次扩散框架
Workers:    bash lab/nano-lisp-jit/tools/v4-diffuse-then-cc.sh   # ≤5× cc
Critic:     bun … gate 一次
```

---

## 5. 与 squad-parallel 关系

| 场景 | 用 |
|------|-----|
| v4 长程波次、add 续批 | 本文 + **nano-lisp-jit-v4-longrun** skill |
| 四角色 tmux 小队、wave≤67 编排 | **squad-parallel** skill |

Commander 不混用两套真源：长程指针只认 `longrun-state.json`。

---

## 6. 变更日志

| 日期 | 摘要 |
|------|------|
| 2026-05-24 | 初版：强模型实用板入账；映射 turbo + cc + SSOT |
