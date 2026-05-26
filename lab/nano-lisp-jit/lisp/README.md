# lisp/ — 完全自举发行面（`*.lisp`）

> **种子**：`nano-jit.com`（genesis 二进制）· **验收**：`run-bootstrap-plan` · 真源：[`../v4.5/ONION-TDD.md`](../v4.5/ONION-TDD.md)

## 目录

| 子目录 | 内容 |
|--------|------|
| [`bootstrap/`](bootstrap/) | `bootstrap-v45-*.lisp` — 洋葱 TDD / verify / 自举 / DONE |
| [`modules/`](modules/) | `lispjit-modules` — 13 个 TU（gen60） |
| [`core/`](core/) | VM/AOT 核心样例（arithmetic、strlen、ir-table…） |
| [`boundary/`](boundary/) | 能力边界正向样例 |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-tdd.lisp
bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh
```

## 与 `archive/c/`

本目录 **不含** `.c` 真源与 v4 工厂 plan；含 C 的第一代维护面见 [`../archive/c/`](../archive/c/README.md)。

旧路径 `samples/` 已废弃，仅留 [`../samples/README.md`](../samples/README.md) 指向此处。
