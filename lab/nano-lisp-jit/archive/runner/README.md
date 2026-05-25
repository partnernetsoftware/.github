# Tier3 factory runner（`lispjit.c` 真源）

发行面 **不** 依赖本目录；日常验收走 `nano-jit.com` + `bootstrap-v45-*.lisp`（主洋葱 `onion-lisp-only`）。

| 路径 | 角色 |
|------|------|
| `archive/runner/lispjit.c` | **唯一** `lispjit.c` 真源（tier3 出仓） |
| `lab/lispjit-ir/lispjit.c` | 符号链接 → 本文件（工厂 `cc` / `build-slice` 兼容） |

证据：`v45.runner.no_c_src=1` · `v45.tier3.runner_archived=1`
