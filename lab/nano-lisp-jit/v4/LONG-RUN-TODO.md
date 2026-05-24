# V4 长程自循环 TODO（catalog ≠ 终局 100%）

**停点**：终局六维 **100%**（零 `.c`/`.py`/`.sh`、Lisp VM emit）— 见 [`DECISION.md`](DECISION.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。  
**catalog `v4-complete` ready=True** 时 **不停止**。

## 每批循环（默认 3 波 × ≤4 轨）

| 步 | 动作 | 产出 |
|----|------|------|
| 1 扩散 | 轨 A diffusion + addN；轨 B/C tick；轨 D evidence | `samples/*`、`SLICE*.md` |
| 2 收敛 | `nano_bootstrap.c` add 入 `plan-lisp-v1-full`；`run.sh`；`catalog-v4.yaml` | 接线 |
| 3 洋葱 | `v4-wave-index-v1.lisp`；`EVAL.md` §wave；`PROGRESS.md`；`MINDMAP.md` | 进度评估 |
| 4 门禁 | `bash lab/nano-lisp-jit/run.sh` → `squad.sh … assess` | exit 0, ready=True |
| 5 合入 | `git checkout -b cursor/v4-wave{N}-{M}-autonomous-108a` → commit → **ff main** | 带 §EVAL |

## 队列（执行后打勾）

- [x] wave59–61 · add54–56
- [x] wave62–64 · add57–59
- [x] wave65–67 · add60–62 · 索引 **67**
- [x] **wave68–70** · add63–65 · ir-table / build-graph / host-reduce
- [x] **wave71–73** · add66–68 · plan-contract / evidence-matrix / four-track-milestone
- [ ] wave74+ … 直至终局 100% 或 Lisp emit 实质线开卷

## 当前指针

| 项 | 值 |
|----|-----|
| 下一波 | **74** |
| 下一 add | **69** (46+17) |
| 末次门禁 | tests.pass=494 · build.pass=26 |
| 终局粗估 | **15–22%**（wave73 后见 EVAL §wave68–73）（[`EVAL.md`](EVAL.md) 最新 §） |

## 自循环规则

1. 每回合至少完成 **一批（3 波）** 再停。
2. 合 **main** 必须更新 **EVAL + PROGRESS**（与 catalog 分离）。
3. 单波并发 **≤4**（A/B/C/D）；禁止 >4 并行轨。
4. 失败：修门禁 → 不重开已签收波。
5. 本文件：每批合 main 后更新「队列」与「当前指针」。
