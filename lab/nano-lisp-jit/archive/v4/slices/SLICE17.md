# v4 slice-17 — plan 字表 host 校验

**洋葱圈**：C3 codegen（宿主减量一步，非 VM）。

## 交付

- `v4_plan_words_v1_file_ok()` 读 `v4-ir-words-v1.txt`
- 日志 `aarch64.emit.ir.table.verified=plan-words-v1`（add20）
- add20 ELF

## 非目标

- 动态表替换 `nano_elf64.c` 内常量
- 去掉 C runner
