# 物理终局 — 诚实口径

## 北极星（产品）

**`*.lisp` 自举 → `nano-lisp.com`**，用户路径 **无 `.c` / `.sh` / `.py`**。

| 层 | 含义 |
|----|------|
| plan 面 | bootstrap 步骤只引用 `.lisp` + `.com`（`*-lisp-only.lisp` 已示范） |
| 命令面 | 仅 `nano-lisp.com run-bootstrap-plan …`（收敛脚本 `.sh` 仍开卷） |
| 物理面 | `.com` 内无 C codegen · 仓内无 runner 真源（**未签收**） |

## 已签收（v4.5 发行面 · ≠ 北极星全满）

| 键 | 含义 |
|----|------|
| `v45.tier5.100=1` | tier5 发行面树 |
| `v45.physical.zero_c=1` | **`lisp/` 树** 无真 `.c`（真源在 `archive/c/`） |
| `v45.selfhost.plan_no_c=1` | plan 零 `lispjit.c` 路径绿 |
| `v45.selfhost.100=1` | 自举卷（含代际矩阵） |

## 诚实未达（北极星缺口）

| 缺口 | 说明 |
|------|------|
| **`.com` 从纯 Lisp 重建** | 种子仍来自 genesis / 历史构建；`pack-ape` 产出 next，≠ 体内零 C |
| **154KB runner 全 Lisp codegen** | `archive/c/runner/lispjit.c` 仍为真源 |
| **零 `.sh` 收敛** | `v45-wave*.sh` · `run.sh` 仍在维护路径 |
| **零 `.py` 工具链** | `compile_blob.py` 等仍在 `lab/lispjit-ir` |
| **产物名统一** | 目标 `nano-lisp.com`；仓内暂 `nano-jit.com` |
| **全 monorepo 零 `.c`** | 如 `lab/cross-arch-ffi` 等未纳入 |

## 日常（发行面 · 仅 com + lisp）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-regenesis-lisp-only.lisp
```

工厂回归（**非北极星**）：`archive/c/` · `NANO_V45_FULL_FACTORY=1 bash run.sh`
