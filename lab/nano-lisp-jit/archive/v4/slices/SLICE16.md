# v4 slice-16 — plan 侧 IR 字表（洋葱圈 C1+）

**方法**：洋葱 TDD mindmap + 双轨并行（见 [`MINDMAP.md`](MINDMAP.md)、[`PARALLEL.md`](PARALLEL.md)）。

## 交付

- `samples/v4-ir-words-v1.txt`：固定 opcode 字表契约（非 `.c` 源）
- 日志 `aarch64.emit.ir.table.source=plan-words-v1` + `ir.table.version=v5`
- add19（9+10）ELF

## 非目标

- C 从 plan 文件动态读表（仍 `nano_elf64.c` emit）
- 去掉 runner
