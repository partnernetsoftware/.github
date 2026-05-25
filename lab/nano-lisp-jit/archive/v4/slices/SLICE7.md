# v4 slice-7 — emit profile + add11（scoped）

**前置**：[`SLICE6.md`](SLICE6.md)、[`REFLECTION.md`](REFLECTION.md)。

## 目标

| 轨 | 交付 | 非目标 |
|----|------|--------|
| **emit profile** | 构建日志 `aarch64.emit.profile=add-exit-v1` | VM/AOT |
| **add11** | `nano-jit-slice-add-11.lisp`（5+6）+ ELF | 替换 `emit_aarch64_add_exit_file` 为 IR 发射 |
| **解析** | 仍由 `build_slice_lisp_parse_add_operands` 读 plan 内 `(i64 …)` | 全模块 Lisp codegen |

## run.sh 门禁

- `run-bootstrap-v4-slice7-add11-plan`（含 `aarch64.add=5+6` + `aarch64.emit.profile=add-exit-v1`）
- `run-bootstrap-v4-slice7-evidence-plan`
- `qemu-aarch64-v4-slice7-add11-exit11`（有 qemu 时）
- `squad-v4-wave12-practice-smoke`

## 证据

`.build/v4-slice7.evidence`（`v4.slice7=1`）

## 签收

`catalog-v4` → `signoff.id=v4-slice7-scoped`。
