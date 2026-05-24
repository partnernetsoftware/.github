# V4 长程自循环 TODO（catalog ≠ 终局 100%）

**停点**：终局六维 **100%**（零 `.c`/`.py`/`.sh`、Lisp VM emit）— 见 [`DECISION.md`](DECISION.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。  
**catalog `v4-complete` ready=True** 时 **不停止**。

## 瓶颈对策（实践归纳）

| 瓶颈 | 现象 | 对策 |
|------|------|------|
| **并发不足** | 单 Agent 串行写样本+文档+门禁 | Composer 编排；**耦合低**任务拆后台（见下表）；单波仍 ≤4 轨 |
| **下手未用** | 主 Agent 亲自改 C/run.sh | 编程碎活 **必须**走 `cc-huoshan1-ds4pro` + `tools/cc-task-*.txt` |
| **长程断档** | 干一轮就总结停 | **`/goal` + `/loop`**：`v4-longrun-loop.sh` 直到成功/失败/超时 |

### 角色分工（≤4 并发）

| 槽 | 角色 | 工具 | 典型任务 |
|----|------|------|----------|
| 0 | **Composer** | Cursor Agent | 读指针、写 cc-task、验收、commit/PR、**禁止**早停总结 |
| 1 | **cc 下手** | `cc-huoshan1-ds4pro` | `gen-v4-wave-batch`、C/run.sh、修门禁 |
| 2 | 可选后台 | Task/`cc` | 并行：MINDMAP 洋葱行、assess smoke（与轨 1 无 touch 冲突时） |
| 3 | 可选后台 | `run.sh` 子集 | 仅当 cc 已提交且 composer 做交叉验证 |

### `/goal` 与 `/loop` 契约（skill · Bun TS）

**可执行 skill**：[`skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts`](../../skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts)

```bash
export PATH="$HOME/.bun/bin:$PATH"
bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop --batches 3 --goal wave95
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
- [ ] wave98+ … 直至终局 100% 或 Lisp emit 实质线开卷

## 当前指针

| 项 | 值 |
|----|-----|
| 下一波 | **104** |
| 下一 add | **99** (76+17) |
| 末次门禁 | tests.pass=616 · [`longrun-state.json`](longrun-state.json) |
| 终局粗估 | **15–22%**（[`EVAL.md`](EVAL.md) 最新 §） |

## 自循环规则

1. 每回合至少完成 **一批（3 波）** 再停。
2. 合 **main** 必须更新 **EVAL + PROGRESS**（与 catalog 分离）。
3. 单波并发 **≤4**（A/B/C/D）；禁止 >4 并行轨。
4. 失败：修门禁 → 不重开已签收波。
5. 本文件：每批合 main 后更新「队列」与「当前指针」。
6. 目录卫生：合 main 前可 `bash tools/clean-lab.sh`；见 [`../MAINTENANCE.md`](../MAINTENANCE.md)。
