# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| lispjit.c 迁出 | 57 | ✅ | active C 已删 |
| wave .sh 迁出 | 58 | ✅ | wave converge 已删 |
| tools .py 迁出 | 59 | ✅ | active py 已删 |
| CI shell 终局 | 60 | ✅ | **`physical.zero_cpysh=1`** |
| **工厂诚实 + 自举** | **61** | ✅ `daily_v45_nano_lisp_com` | **`archive/c` 工厂 C 仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.physical_honest_terminal_continue.100=1` | Wave61 四轨 + nano-lisp.com 自举冲刺 |
| `v45.physical.zero_cpysh=1` | active 发行面树零 c/sh/py |
| `v45.nano_lisp_com.bootstrap_sprint=1` | pack + 15link 自举绿 |
| `v45.honest.archive_factory_terminal=1` | 工厂 C 仅在 `archive/c` + `retired/` |

## 日常

```bash
# bootstrap 宿主（Wave62 前仍 nano-jit.com · 目标产物 nano-lisp.com）
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com.lisp
bash lab/nano-lisp-jit/scripts/v45-wave61-physical-honest-terminal-converge.sh
```

## 下一物理轨

Wave62：host COM 统一 `nano-lisp.com` · 退 `nano-jit.com` 叙事
