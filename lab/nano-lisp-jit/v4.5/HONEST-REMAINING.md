# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| lispjit.c 迁出 | 57 | ✅ | active C 已删 |
| host wave .sh 迁出 | 58 | ✅ | wave converge 已删 |
| tools .py 迁出 | 59 | ✅ | active py 已删 |
| **CI shell 终局** | **60** | ✅ `daily_v45_physical_zero_cpysh` | **`physical.zero_cpysh=1`** · 工厂 C **仍在** |

## 签收

| 键 | 含义 |
|----|------|
| `v45.physical.zero_cpysh=1` | **发行面 active 树零 c/sh/py**（wave converge 链已迁 `retired/`） |
| `v45.v45.ci_shell_retire_continue.100=1` | Wave60 四轨 + 活图 7/7 |
| `v45.honest.archive_factory_c=1` | `archive/c/` 工厂 C 仍在（**≠ v4.5 DONE**） |
| `v45.honest.ci_utility_sh=1` | `v45-evidence-canonical.sh` 等工具 sh 仍存 |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical-zero-cpysh.lisp
bash lab/nano-lisp-jit/scripts/v45-wave60-ci-shell-retire-converge.sh
```

## 下一物理轨

Wave61：`archive/c` 工厂诚实终局 · `nano-lisp.com` 自举冲刺
