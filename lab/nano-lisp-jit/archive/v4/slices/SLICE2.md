# v4 slice-2 — squad S2 状态 + gen5-via-gen2 锚点（scoped）

**前置**：[`v4-lisp-only-scoped`](LISP-ONLY.md)、[`SLICE1.md`](SLICE1.md)。

## 目标

| 轨 | 交付 | 非目标 |
|----|------|--------|
| **Squad S2** | `bootstrap-v4-squad-s2-state.lisp` 断言 `state-v4.db` + JSON 导出 | Lisp 内 SQLite FFI |
| **自举锚点** | `bootstrap-v4-gen5-via-gen2-anchor.lisp` + `run.sh` 回归 gen5v2 plan | 新 gen6 链 |
| **回归** | slice-1 add7 仍绿；lisp-only 门禁不退化 | 真 aarch64 VM/AOT（slice-3+） |

## 证据

- `.build/v4-slice2.evidence`（`v4.slice2=1`）
- `run.sh`：`run-bootstrap-v4-squad-s2-state-plan`、`run-bootstrap-v4-gen5-via-gen2-anchor-plan`、`run-bootstrap-v4-slice2-evidence-plan`
- 全量 `run-bootstrap-v35-selfhost-gen5-via-gen2-plan`（需 gen2 slice 已构建）

## 签收

`catalog-v4` → `signoff.id=v4-slice2-scoped`。
