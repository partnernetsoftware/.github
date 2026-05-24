# V4 长程自循环 TODO（catalog ≠ 终局 100%）

**停点**：终局六维 **100%**（零 `.c`/`.py`/`.sh`、Lisp VM emit）— 见 [`DECISION.md`](DECISION.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。  
**catalog `v4-complete` ready=True** 时 **不停止**。

**编排框架**：见 [`DEV-AGENTS-TEAM.md`](DEV-AGENTS-TEAM.md)（Commander / Worker / Critic / Memory 映射 + 调度四问）。

## 瓶颈对策（实践归纳）

| 瓶颈 | 现象 | 对策 |
|------|------|------|
| **并发不足** | 单 Agent 串行写样本+文档+门禁 | Composer 编排；**耦合低**任务拆后台（见下表）；单波仍 ≤4 轨 |
| **下手未用** | 主 Agent 亲自改 C/run.sh | 编程碎活 **必须**走 `cc-huoshan1-ds4pro` + `tools/cc-task-*.txt` |
| **长程断档** | 干一轮就总结停 | **`/goal` + `/loop`**：`v4-longrun-loop.sh` 直到成功/失败/超时 |

### 角色分工（Dev Agents Team · 最小 1+3+1）

| 理论 | V4 实现 | 工具 | 调度 |
|------|---------|------|------|
| **Commander** | Cursor Agent | 目标、`/goal`、PR、终局裁决 | 失败代价高 / 需判断 |
| **Planner** | Commander 兼 | `WAVES` + `cc-task-*.txt` | 任务树 |
| **Worker** | gen + **cc** | `gen-v4-wave-batch.py`、`cc-huoshan1-ds4pro` | 可验证、可拆小 |
| **Critic** | gate + EVAL 诚实 | `run.sh`、`PROGRESS.md` | 异构验收 |
| **Integrator** | skill bump + git | `nano-lisp-jit-v4-longrun.ts` | 合并产出 |
| **Memory** | **state SSOT** | `longrun-state.json` | 程序化管理 |

旧表（≤4 轨）仍适用：单波 A/B/C/D 扩散；**并行** = Worker Pool（gen ∥ cc），非多 Commander。

| 槽 | 角色 | 工具 | 典型任务 |
|----|------|------|----------|
| 0 | **Commander** | Cursor Agent | 读指针、写 cc-task、Critic 验收、commit/PR |
| 1 | **Worker (cc)** | `cc-huoshan1-ds4pro` | C/run.sh、emit 实质（**可验证**） |
| 2 | **Worker (gen)** | `gen-v4-wave-batch.py` | 确定性 apply（**禁止**手改样本） |
| 3 | **Worker (skill)** | `bun … loop --gate-every` | 批量 apply + 单次 gate |

### `/goal` 与 `/loop` 契约（skill · Bun TS）

**可执行 skill**：[`skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts`](../../skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts)

```bash
export PATH="$HOME/.bun/bin:$PATH"
bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop --batches 3 --gate-every 3 --goal wave121
```

**真源**：[`v4/longrun-state.json`](longrun-state.json) · 旧 `v4-longrun-loop.sh` 仅委托 skill

```text
┌─────────┐   读「当前指针」   ┌──────────┐   gen 三波    ┌─────────┐
│  IDLE   │ ───────────────► │ DIFFUSE  │ ────────────► │ CONVERGE│
└─────────┘                  └──────────┘  ≤4轨/波      └────┬────┘
     ▲                              │                        │ run.sh
     │                              │ onion 文档             ▼
     │                         ┌────┴────┐              ┌─────────┐
     └──── 终局 < 100% ────────│ ONION   │◄─────────────│  GATE   │
                               └────┬────┘              └─────────┘
                                    │ EVAL+PROGRESS+本表
                                    ▼
                               ┌─────────┐
                               │ MERGE   │ → 指针 N+=3 → 未 100% 则回到 DIFFUSE
                               └─────────┘
```

| 钩子 | 命令 / 动作 |
|------|-------------|
| **生波** | `python3 tools/gen-v4-wave-batch.py $N $((N+2))`（扩 WAVES 表后） |
| **编程下手** | `~/.local/bin/cc-huoshan1-ds4pro -p < tools/cc-task-*.txt`（火山 Claude；需 `API_KEY_HUOSHAN_PLAN_1`） |
| **收敛** | `export NANO_SLICE_COMPILER=native && bash lab/nano-lisp-jit/run.sh` |
| **评估** | 写 `EVAL.md` §wave、`PROGRESS.md` 六维、本文件指针 |
| **卫生** | 合 main 前 `bash tools/clean-lab.sh`（见 [`MAINTENANCE.md`](../MAINTENANCE.md)） |

**技巧**：一批固定 **3 波 × 4 轨**；禁止单轨碎补；catalog 签收 ≠ 终局停。

## 每批循环（默认 3 波 × ≤4 轨）

| 步 | 动作 | 产出 |
|----|------|------|
| 1 扩散 | 轨 A diffusion + addN；轨 B/C tick；轨 D evidence | `samples/*`、`SLICE*.md` |
| 2 收敛 | `nano_bootstrap.c` add 入 `plan-lisp-v1-full`；`run.sh`；`catalog-v4.yaml` | 接线 |
| 3 洋葱 | `v4-wave-index-v1.lisp`；`EVAL.md` §wave；`PROGRESS.md`；`MINDMAP.md` | 进度评估 |
| 4 门禁 | `bash lab/nano-lisp-jit/run.sh` → `squad.sh … assess` | exit 0, ready=True |
| 5 合入 | `git checkout -b cursor/v4-wave{N}-{M}-autonomous-fc19` → commit → **ff main** | 带 §EVAL |

## 队列（执行后打勾）

- [x] wave59–61 · add54–56
- [x] wave62–64 · add57–59
- [x] wave65–67 · add60–62 · 索引 **67**
- [x] **wave68–70** · add63–65 · ir-table / build-graph / host-reduce
- [x] **wave71–73** · add66–68 · plan-contract / evidence-matrix / four-track-milestone
- [x] **wave74–76** · add69–71 · runner-scout / emit-deep / mindmap-autonomous
- [x] **wave77–79** · add72–74 · commander-resume / build-graph-onion / longrun-milestone
- [x] **wave80–82** · add75–77 · ir-table-scout / emit-manifest-chain / four-track-autonomous
- [x] **wave83–85** · add78–80 · reflection-resume / lisp-only-terminal / codegen-emit-milestone
- [x] **wave86–88** · add81–83 · runner-plan / squad-evidence / onion-mindmap-close
- [x] **wave89–91** · add84–86 · host-reduce / ir-table / four-track
- [x] **wave92–97** · add87–92 · skill longrun 2 批
- [x] **wave98–103** · add93–98 · evidence/terminal/ir-words/post-v4/orchestration
- [x] **wave104–112** · add99–107 · turbo runner/emit/codegen
- [x] **wave113–121** · add108–116 · cc emit obs + turbo（tests.pass=760）
- [x] **wave122–130** · add117–125 · extra_grep emit 验收 + DEV-AGENTS-TEAM（tests.pass=724）
- [x] **wave131–139** · add126–134 · post-main 续批（tests.pass=760）
- [ ] wave140+ … 直至终局 100%

## 当前指针

| 项 | 值 |
|----|-----|
| 下一波 | **140** |
| 下一 add | **135** (117+17) |
| 末次门禁 | tests.pass=760 · [`longrun-state.json`](longrun-state.json) |
| 终局粗估 | **15–22%**（[`EVAL.md`](EVAL.md) 最新 §） |

## 自循环规则

1. 每回合至少完成 **一批（3 波）** 再停。
2. 合 **main** 必须更新 **EVAL + PROGRESS**（与 catalog 分离）。
3. 单波并发 **≤4**（A/B/C/D）；禁止 >4 并行轨。
4. 失败：修门禁 → 不重开已签收波。
5. 本文件：每批合 main 后更新「队列」与「当前指针」。
6. 目录卫生：合 main 前可 `bash tools/clean-lab.sh`；见 [`../MAINTENANCE.md`](../MAINTENANCE.md)。
