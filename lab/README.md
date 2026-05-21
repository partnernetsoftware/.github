# lab

实验与小型工具目录。`nano-lisp-jit` 本体在 `lab/nano-lisp-jit/`；其余子目录用其 CLI 做消费者验证。

## 消费者小工具

| 目录 | 说明 |
|------|------|
| `tool-exit42/` | `compile-elf64-code` → 退出码 42 |
| `tool-strlen-check/` | FFI `strlen` + `.lbin` run |
| `tool-blob-compare/` | 确定性 `compile` / `compare` |
| `tool-resolve-check/` | `resolve --quiet` + `strlen("x")` |

共享脚本：`lab/_nano_common.sh`（定位 `nano-lisp-jit/.build/nano-lisp-jit`，必要时触发 `run.sh`）。

```bash
bash lab/run-lab-tools.sh
```

使用反馈写回：`lab/nano-lisp-jit/LAB-USAGE-FEEDBACK.md`。
设计与产品化命名：`lab/nano-lisp-jit/DESIGN-MEMORY-AND-PRODUCT.md`。
能力边界探测：`lab/boundary-probes/`（`run-probes.sh`）。
