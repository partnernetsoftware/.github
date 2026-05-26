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
| 工厂诚实 + 自举 | 61 | ✅ `daily_v45_nano_lisp_com` | **`archive/c` 工厂 C 仍在** |
| **host COM 统一** | **62** | ✅ `daily_v45_nano_lisp_com_host` | **宿主仍种子复制** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.nano_lisp_com_host_only_continue.100=1` | Wave62 四轨 + COM 路径迁 `nano-lisp/` |
| `v45.host.com_nano_lisp_only=1` | bootstrap 宿主在 `.build/nano-lisp/` |
| `v45.honest.nano_jit_com_legacy=1` | `nano-jit.com` 退居 legacy seed |
| `v45.physical.zero_cpysh=1` | active 发行面树零 c/sh/py |

## 日常

```bash
# bootstrap 宿主（Wave62 · nano-lisp/ 树）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com-host.lisp
bash lab/nano-lisp-jit/scripts/v45-wave62-nano-lisp-com-host-only-converge.sh
```

## 下一物理轨

Wave63：`nano-lisp.com` 原生 bootstrap · 退 `nano-lisp-host.com` 种子
