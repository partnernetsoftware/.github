# lisp/ — `*.lisp` 自举 `nano-lisp.com`

> **北极星**：plan 里只有 Lisp 步骤（`build-slice-lisp` · `pack-ape` · `run-bootstrap-plan`…），**不出现 `.c` / `.sh` / `.py`**。  
> 种子：`.com`（当前 `.build/nano-jit/nano-jit.com`，对外 **`nano-lisp.com`**）。

## 目录

| 子目录 | 内容 |
|--------|------|
| [`bootstrap/`](bootstrap/) | `bootstrap-v45-*.lisp` — verify / 洋葱 / 自举 / DONE |
| [`modules/`](modules/) | `lispjit-modules`（13 TU） |
| [`core/`](core/) | VM/AOT 样例 |
| [`boundary/`](boundary/) | 能力边界 |

## 零 C plan 示例（已存在）

| plan | 作用 |
|------|------|
| `bootstrap-v45-selfhost-regenesis-lisp-only.lisp` | `build-slice-lisp` → `pack-ape` → next `.com` |
| `bootstrap-v45-selfhost-chain-lisp-only.lisp` | S2–S5 链，plan 内无 `lispjit.c` |
| `bootstrap-v45-onion-lisp-only.lisp` | 洋葱验收，无 `build-slice "…lispjit.c"` |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp
```

## 仍开卷（≠ 说「还要改 C」）

| 项 | 说明 |
|----|------|
| `.com` 体内 | 仍有 C 时代 codegen；154KB runner 未全 Lisp 化 |
| 收敛 | 仍用 `scripts/v45-*.sh`；目标迁入 `lisp/bootstrap/*-converge*.lisp` |
| 产物名 | 目标统一 `nano-lisp.com` / `.build/nano-lisp/` |

`archive/c/` 仅工厂归档，**不是**用户自举路径。
