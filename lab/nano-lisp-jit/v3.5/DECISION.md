# v3.5 vs v4 分流决策

## 判定（2026-05-23）

| 档位 | 状态 | 依据 |
|------|------|------|
| **v3.5-scoped** | **已完成** | `catalog.signoff.gates` 全绿；已合并 `main` |
| **v3.5-terminal** | **已完成** | wave-5：`gen2×gen5` full plan、pin=runner、`terminal_gates` 全绿；`run.sh` 257 pass |
| **v4 产品轨** | **已启动** | `squad/catalog-v4.yaml` + wave-v4 小队 |

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

- v3.5：**无剩余阻塞**（aarch64 全 AOT 明确归入 v4）。
- v4：`tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team`
