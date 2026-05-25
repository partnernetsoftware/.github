# 物理清单（tier5 · 透明计数）

> 由 `v45-wave11-tier5-converge.sh` 刷新 `v45-entry.evidence` 中的 `v45.physical.*` 键。

## 口径

| 区域 | 计数规则 |
|------|----------|
| `lispjit-ir/*.c` | 非 symlink 的 `.c` 文件数 |
| `archive/**/*.c` | 归档真源 `.c` 数 |
| symlink | `lispjit-ir/*.c` 全部 → `archive/runner/`（Wave13：**零真 `.c`**） |
| `archive/runner` 真源 | 工厂 runner TU |
| `archive/fixtures` 真源 | `nano-cc-*.c` |
| `samples/*.c` | **0** 真文件（Wave15 symlink） |

## Tier5 目标对照

| ID | Wave11 进展 |
|----|-------------|
| T5a | 无参默认 `NANO_V45_SCOPED_ONLY=1` |
| T5b | Wave11 +2 symlink；**Wave12** 16× `nano_*.c` 出仓（`ir` 真源剩 2） |
| T5c | 本文档 + evidence 键 |
| T5d | vm-emit-matrix smoke（非全量替代 C 表） |

## 禁止

- 不得把计数下降写成 `physical.zero_c=1`
- 不得删 `run.sh` 文件
