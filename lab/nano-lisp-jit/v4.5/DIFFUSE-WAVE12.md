# Wave12 — tier5 广度扩散（16 TU · 四轨并发归档）

> **签收**：`lispjit-ir` 真 `.c` 降至 **2**（`ape_v2` + `irjit`）。  
> **未签收**：`v45.physical.zero_c=0` 仍明示未完成。

## 四轨（同时 `v45-archive-runner-batch.sh`）

| 轨 | 簇 | 文件 ×4 |
|----|-----|---------|
| A | util/abi | `nano_abi` `nano_util` `nano_manifest` `nano_main` |
| B | parse/vm | `nano_lisp_parse` `nano_blob_vm` `nano_compile_cli` `nano_libc_resolve` |
| C | elf/cc | `nano_elf64` `nano_cc` `nano_genesis_pin` `nano_aot_x86` |
| D | cli/ape | `nano_ape` `nano_pack_app` `nano_run_cli` `nano_compile_elf64_cli` |

## 并发收敛

1. 四轨 `&`/`wait` 批量 `cp` + symlink  
2. 四 anchor plan 并行  
3. `verify-smoke` + rollup 串尾（洋葱内圈）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave12-tier5-converge.sh
```

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave12.parallel=4` | 四轨齐 |
| `v45.tier5.nano_tu_archived=16` | nano TU 出仓 |
| `v45.tier5.archive_symlinks=N` | `lispjit-ir` symlink 计数 |
| `v45.physical.lispjit_ir_c_files=2` | 余 `ape_v2` + `irjit` |
| `v45.physical.zero_c=0` | **未完成** |

## Wave13 预告

- 归档 `ape_v2.c`（`lispjit` `#include` 兼容 symlink）
- `irjit.c` 评估是否并入 archive 或 Lisp 替代
