# Wave15 — tier5 **100%**（发行面物理树）

> **签收**：`v45.tier5.100=1` · `v45.physical.zero_c=1`（**口径** = `lispjit-ir` + `samples/` 无真 `.c`；工厂真源仅在 `archive/`）。  
> **未声称**：全仓库（含 `lab/cross-arch-ffi`）零 C · 154KB runner Lisp 全量 codegen。

## 并发

1. `v45-wave14-vm-emit-converge.sh`
2. fixtures `G1`/`G2` 并行 `v45-archive-fixtures-batch.sh`
3. `tier5-100` + `onion-tdd` + `terminal-done`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave15-tier5-100-converge.sh
```

## 证据键

| 键 | 含义 |
|----|------|
| `v45.tier5.100=1` | T5a–T5d 齐 |
| `v45.physical.zero_c=1` | 发行面树零真 `.c` |
| `v45.honest.tier5.open=0` | tier5 卷闭合 |
| `v45.physical.archive_runner_c_files=N` | 工厂维护区（透明） |
