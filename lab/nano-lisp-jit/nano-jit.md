# nano-lisp-jit

**北极星**：`*.lisp` 自举出 **`nano-lisp.com`** — 用户路径上 **无 `.c` / `.sh` / `.py`**。

> 仓内种子路径暂为 `.build/nano-jit/nano-jit.com`（与 `nano-lisp.com` 同一产品；见 [`v4.5/DECISION.md`](v4.5/DECISION.md)）。

## 用户路径（目标形态）

```bash
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com   # 目标名；当前见下
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-regenesis-lisp-only.lisp
# plan 内：build-slice-lisp → pack-ape → next .com（无 lispjit.c / 无 run.sh）
```

当前种子（构建产物）：

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp
```

## 目录

| 路径 | 用途 |
|------|------|
| [`lisp/`](lisp/README.md) | 发行面 **仅 `*.lisp`** — bootstrap / modules / core / boundary |
| [`v4.5/`](v4.5/README.md) | 洋葱 TDD · 活图 · 签收 |
| [`archive/c/`](archive/c/README.md) | 第一代 C 工厂（**不在用户路径**） |
| [`genesis/`](genesis/) | 可选 genesis pin（非日常 host cc） |

**不在用户路径**：`run.sh` · `scripts/v45-*.sh` · `archive/c/runner/*.c` · `tools/*.py` — 维护/历史用。

## 与 fasmgx

**fasmgx**（fasmg + `.fg`）为独立产品线，不在本仓。

## 详细

- 结构：[`STRUCTURE.md`](STRUCTURE.md)
- 自举阶梯：[`v4.5/SELFHOST.md`](v4.5/SELFHOST.md)
- 诚实未达：[`v4.5/HONEST-REMAINING.md`](v4.5/HONEST-REMAINING.md)
