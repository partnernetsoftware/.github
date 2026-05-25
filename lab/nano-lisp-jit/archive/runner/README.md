# Tier3 factory runner（`lispjit.c` 真源）

发行面 **不** 依赖本目录；日常验收走 `nano-jit.com` + `bootstrap-v45-*.lisp`（主洋葱 `onion-lisp-only`）。

| 路径 | 角色 |
|------|------|
| `archive/runner/lispjit.c` | **唯一** `lispjit.c` 真源（tier3 出仓） |
| `archive/runner/nano_bootstrap.c` | **唯一** `nano_bootstrap.c` 真源（wave11 tier5） |
| `lab/lispjit-ir/lispjit.c` | 符号链接 → 本文件（工厂 `cc` / `build-slice` 兼容） |
| `lab/lispjit-ir/nano_bootstrap.c` | 符号链接 → `archive/runner/nano_bootstrap.c` |

| 计数 | Wave12 后 |
|------|-----------|
| `archive/runner/*.c` 真源 | 18 |
| `lispjit-ir` symlink | 18 |
| `lispjit-ir` 真 `.c` | **0**（Wave13 门面） |
| `lispjit-ir` symlink | 20 |

证据：`v45.tier5.ir_facade_zero_real=1` · `v45.physical.zero_c=0`（全仓仍未零 C）
