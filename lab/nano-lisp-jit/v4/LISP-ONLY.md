# v4「全 Lisp」— 三层含义（避免误解）

## 直接回答

**v4 现在不是「整个仓库零 `.c`」。**  
**v4 bootstrap 计划层**可以做到 **不引用任何 `.c` 源文件**（与 v3.5 `gen5-no-c` 同口径）；**实现层**仍依赖 C 写的 `nano-lisp-jit` runner 与 scoped 的 `aarch64-add-emit` 硬编码。

## 三层

| 层 | v4 现状 | 验收 |
|----|---------|------|
| **A. Plan（bootstrap `.lisp`）** | 所有 `bootstrap-v4-*.lisp` 仅 `build-slice-lisp` / `file-*` / `compile` `.lisp` 等 | `run.sh` `v4-bootstrap-plans-no-c` + `v4-lisp-only.evidence` |
| **B. Runner（执行器）** | `nano-lisp-jit` 由 `lispjit.c` + `nano_*.c` 编译 | v3.5 已接受；v4 不重复声称消除 |
| **C. Codegen（真自举）** | aarch64 add 仍在 `nano_elf64.c`：`emit_aarch64_add_exit_v1_lower` + opcode 表（S6–S9） | **终局**：Lisp IR 驱动 emit；**非**「已无 C」 |

## 与 v3.5 的关系

- v3.5 **terminal**：`bootstrap-v35-selfhost-gen5.lisp` **plan 无 `.c`**（`gen5-no-c` gate）。
- v4 **必须保持该锚点**：`bootstrap-v4-gen5-anchor.lisp` + catalog gate `v35-gen5-plan-no-c`。
- v4 slice-0–S5：编排样本 + plan 无 `.c`；slice-6–9：**emit 表驱动**仍为 C 实现。
- **不是**「Lisp VM _codegen 已替代 C」；**不是**「v4 已完全摆脱 `.c` 自举」。

## slice-2 前进条件

1. `assess` 中 **v4 全 plan no-c** 与 **gen5 anchor** 常绿。  
2. 再开 VM/AOT 或 gen5-via-gen2 类任务（见 `README.md` S2–S5）。
