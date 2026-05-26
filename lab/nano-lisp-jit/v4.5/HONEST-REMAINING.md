# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| CI plan-only | 54 | ✅ | host `.sh` **仍在** |
| tools plan-only | 55 | ✅ | 维护 `.py` **仍在** |
| lispjit.c 迁出 | 57 | ✅ | active C 已删 |
| host .sh 迁出 | 58 | ✅ | wave `.sh` 已删 |
| **tools .py 迁出** | **59** | ✅ `daily_v45_zero_cpysh_terminal` | **active py 已删** · CI `.sh` **仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.tools_py_retire_continue.100=1` | Wave59 plan-only 终局 + `tools/*.py` 迁 `retired/tools/` |
| `v45.physical.zero_cpysh_progress=1` | 进度键（**非**终局 `zero_cpysh=1`） |
| `v45.honest.tools_py_retired=1` | active `tools/*.py` 已迁出 |
| `v45.honest.ci_shell_remaining=1` | CI wave59 `.sh` 仍存 |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-cpysh-terminal.lisp
bash lab/nano-lisp-jit/scripts/v45-wave59-tools-py-retire-converge.sh
```

## 下一物理轨

Wave60：最后 CI `v45-wave59*.sh` 退 `retired/` · 冲刺 `v45.physical.zero_cpysh=1`
