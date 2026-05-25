# Tier3 runner archive anchor

`lispjit.c` 真源仍在 `lab/lispjit-ir/lispjit.c`；本目录为 **v4.5 tier3** 归档锚点（日常发行面走 genesis-pin / `build-slice-lisp`，不直接 host-cc 本文件）。

- `lispjit.c` → 符号链接至 `../../../lispjit-ir/lispjit.c`
- 证据键：`v45.tier3.runner_archived=1` · `v45.runner.no_c_src=0`（未删仓内 C，仅锚定迁移路径）
