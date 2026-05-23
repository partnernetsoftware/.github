# v3.5 vs v4 分流决策

## 判定（2026-05-23）

| 档位 | 状态 | 依据 |
|------|------|------|
| **v3.5-scoped** | **已完成 · CLOSED** | `catalog.signoff.gates` 全绿；无新工程任务 |
| **v3.5-terminal** | **已完成 · CLOSED** | wave-5 + `terminal_gates`；维护仅回归，不扩 scope |
| **v4 slice-0** | **scoped 签收 · 完成** | `v4-slice0-scoped` |
| **v4 slice-1** | **scoped 签收 · 完成** | `v4-slice1-scoped` assess 100%；见 [`../v4/SLICE1.md`](../v4/SLICE1.md) |

## 规则

```text
assess.scoped_ready 且非 require_terminal     → 仅 scoped 签收（历史 wave-1..4）
assess.ready（scoped ∧ terminal）            → v3.5 全线完成 → 小队转 v4
```

## terminal 门禁（catalog `terminal_gates`）

1. `gen2-runs-gen5-full-plan` — gen2 slice 跑 **完整** `bootstrap-v35-selfhost-gen5.lisp`
2. `genesis-pin-matches-native` — genesis x86 pin hash = native `nano-lisp-jit`
3. `signoff-via-bootstrap-plan` — `bootstrap-v35-signoff-evidence.lisp` 已跑通

**刻意不在 v3.5-terminal**：全 VM/AOT aarch64（归 **v4** slice）。

## 当前动作（wave-5 后）

- v3.5：**CLOSED** — 不再开 squad 工程波次；`assess` 仅作回归哨兵。
- v4 slice-0/1：**scoped 签收完成**；下一波 **slice-2**（VM/AOT 或 Lisp squad S2+）再开 catalog 任务。
- squad **wave2**：`run-loop` 仅 `complete|failed|timeout` 解散；`auto_done` 闭环工单（见 `squad/PROTOCOL.md`）
