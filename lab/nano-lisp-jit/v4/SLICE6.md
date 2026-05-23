# v4 slice-6 — codegen kickoff（scoped）

**前置**：[`SLICE5.md`](SLICE5.md)、[`REFLECTION.md`](REFLECTION.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。

## 目标

| 轨 | 交付 | 非目标 |
|----|------|--------|
| **inventory** | 锚定 `lab/lispjit-ir/nano_elf64.c` emit 路径 hash | 删除 stub |
| **regression** | add7 + scout ELF 仍绿 | VM/AOT aarch64 |
| **文档** | emit 函数 ↔ slice 映射表 | 产品轨 NDTSV/SQL |

## emit 路径（当前真相源）

| 符号 | 用途 | v4 状态 |
|------|------|---------|
| `emit_aarch64_exit_file` | `(expect N)` min 切片 | scoped stub |
| `emit_aarch64_add_exit_file` | add 切片 `aarch64-add-emit` | scoped stub（参数化 3+4） |
| VM/AOT from Lisp IR | 终局 | **未开始** |

## run.sh 门禁

- `run-bootstrap-v4-codegen-kickoff-plan`
- `run-bootstrap-v4-slice6-evidence-plan`
- `squad-v4-wave11-practice-smoke`（写入 `v4.slice6_wave11_smoke`）

## 证据

`.build/v4-slice6.evidence`（`v4.slice6=1`）

## 签收

`catalog-v4` → `signoff.id=v4-slice6-scoped`。
