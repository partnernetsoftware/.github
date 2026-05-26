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
| 工厂诚实 + 自举 | 61 | ✅ | **`archive/c` 工厂 C 仍在** |
| host COM 统一 | 62 | ✅ | 宿主迁 `nano-lisp/` |
| **原生 bootstrap** | **63** | ✅ `daily_v45_nano_lisp_com_native` | **promote 仍种子** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.nano_lisp_com_native_bootstrap_continue.100=1` | Wave63 四轨 + `nano-lisp.com` 直接 bootstrap |
| `v45.nano_lisp_com.native_bootstrap=1` | 产品 COM 可 `run-bootstrap-plan` |
| `v45.honest.nano_lisp_host_retired=1` | `nano-lisp-host.com` 已迁 `retired/com/` |
| `v45.physical.zero_cpysh=1` | active 发行面树零 c/sh/py |

## 日常

```bash
# bootstrap 宿主（Wave63 · nano-lisp.com 原生）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com-native.lisp
bash lab/nano-lisp-jit/scripts/v45-wave63-nano-lisp-com-native-bootstrap-converge.sh
```

## 下一物理轨

Wave64：`archive/c` 工厂 C 物理退仓 · 全 monorepo 诚实
