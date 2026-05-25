# Wave13 — tier5 收尾（`lispjit-ir` 门面零真 `.c`）

> **签收**：`lispjit-ir/*.c` 全部为 symlink → `archive/runner/`。  
> **未签收**：`v45.physical.zero_c=0`（`archive/runner` 仍有 ~20 真源 `.c`）。

## 四轨并发

| 轨 | 交付 |
|----|------|
| A | `ape_v2.c` 出仓（`lispjit` `#include` 兼容） |
| B | `irjit.c` 出仓（原型 TU） |
| C | 归档后洋葱键仍绿 |
| D | `PHYSICAL-INVENTORY` + `ir_facade_zero_real=1` |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave13-tier5-converge.sh
```

## 证据键

| 键 | 含义 |
|----|------|
| `v45.tier5.ir_facade_zero_real=1` | `lispjit-ir` 无真 `.c` |
| `v45.physical.lispjit_ir_c_files=0` | 计数透明 |
| `v45.physical.zero_c=0` | **全仓** 仍未完成 |

## Wave14 预告

- T5d：IR 表扩面 / runner Lisp codegen 切片
- 可选：`archive/runner` 分 tier 子目录（勿冒充删 C）
