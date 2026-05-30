# v4 签收决策

## 档位（2026-05-23）

| 档位 | 状态 | 依据 |
|------|------|------|
| **v4-complete-scoped** | **CLOSED** | catalog scoped gates 100%；S0–S15 + POST-V4 |
| **v4-terminal（cloud native）** | **可签收** | `terminal_gates`：run≥270 + `build.pass≥26`（`build_nano_jit.sh` native） |
| **v4-terminal（full cosmocc）** | **dev container** | `build.pass≥119`；见 `Dockerfile.dev` |
| **v4 终局自举** | **未开卷** | 零 `.c`、Lisp squad FFI、VM emit — 见 [`POST-V4.md`](POST-V4.md) |

## 规则

```text
scoped_ready=True              → v4-complete-scoped（不要求 terminal）
terminal_ready=True            → run + build 回归（v4 catalog 已下调 build 门槛至 native smoke）
ready=True（assess）           → scoped ∧ terminal
```

## 刻意不在 v4-scoped

- 全仓库零 `.c` / `.py` / `.sh`
- VM/AOT 真 codegen（当前为 `nano_elf64.c` 表驱动 stub）
- 119 build case 全量（无 cosmocc 时仅保证 report + ≥26 pass）
