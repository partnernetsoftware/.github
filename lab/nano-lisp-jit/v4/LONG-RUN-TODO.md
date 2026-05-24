# V4 长程自循环 TODO（catalog ≠ 终局 100%）

**停点**：终局六维 **100%**（零 `.c`/`.py`/`.sh`、Lisp VM emit）— 见 [`DECISION.md`](DECISION.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。  
**catalog `v4-complete` ready=True** 时 **不停止**。

## 自循环状态机（Agent 每回合照跑）

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
| **编程下手** | `~/.local/bin/cc-huoshan1-ds4pro`（C/run.sh 碎活；断链则自写） |
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
- [ ] wave80+ … 直至终局 100% 或 Lisp emit 实质线开卷

## 当前指针

| 项 | 值 |
|----|-----|
| 下一波 | **80** |
| 下一 add | **75** (58+17) |
| 末次门禁 | tests.pass=519 · build.pass=26（catalog build≥119 待 cosmocc） |
| 终局粗估 | **15–22%**（[`EVAL.md`](EVAL.md) 最新 §） |

## 自循环规则

1. 每回合至少完成 **一批（3 波）** 再停。
2. 合 **main** 必须更新 **EVAL + PROGRESS**（与 catalog 分离）。
3. 单波并发 **≤4**（A/B/C/D）；禁止 >4 并行轨。
4. 失败：修门禁 → 不重开已签收波。
5. 本文件：每批合 main 后更新「队列」与「当前指针」。
6. 目录卫生：合 main 前可 `bash tools/clean-lab.sh`；见 [`../MAINTENANCE.md`](../MAINTENANCE.md)。
