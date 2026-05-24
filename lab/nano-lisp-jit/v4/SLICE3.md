# v4 slice-3 — squad S3 单 tick（scoped）

**前置**：[`SLICE2.md`](SLICE2.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。

## 目标

| 轨 | 交付 | 非目标 |
|----|------|--------|
| **S3 leader** | `run.sh` → `squad supervise --once` | Lisp `squad-supervise-tick` |
| **S3 follower** | `run.sh` → `squad run-loop --role … --once` | 完整 S4 agent-team |
| **样本** | `bootstrap-v4-squad-s3-*-once.lisp` | |

## run.sh 门禁

- `squad-v4-supervise-once` — 指挥长一拍（assess/dispatch/信号）
- `squad-v4-run-loop-engineer-once` — 工程兵一拍（`--auto-exec`）
- `squad-v4-run-loop-reviewer-once` — 审查员一拍

## 证据

`.build/v4-slice3.evidence`（`v4.slice3=1`）

## 签收

`catalog-v4` → `signoff.id=v4-slice3-scoped`。
