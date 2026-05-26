# v5 — 物理终局开卷

> v4.5 **规划面 DONE**（`v45.v45.v45_terminal_complete.100=1`）。v5 承接 **诚实未达** 项，见 [`v4.5/HONEST-REMAINING.md`](../v4.5/HONEST-REMAINING.md)。

## 开卷范围

| 项 | v4.5 状态 | v5 目标 |
|----|-----------|---------|
| `archive/c/runner/lispjit.c` ~154KB | 探针绿 · 仍 C | 全 Lisp codegen |
| host 产物 | `nano-jit.com` | `nano-lisp.com` 硬切 |
| CI / 维护 | `scripts/v45-*.sh` | plan-only 外层收敛 |

## 日常（维护轨 · Wave52）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave52-v5-open-maintenance-converge.sh
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-maintenance.lisp
```

## SSOT

- 决策：[`DECISION.md`](DECISION.md)
- v4.5 终局：[`v4.5/DIFFUSE-WAVE51.md`](../v4.5/DIFFUSE-WAVE51.md)
