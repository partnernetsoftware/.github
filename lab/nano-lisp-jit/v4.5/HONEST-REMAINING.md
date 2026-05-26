# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| 154KB codegen | 53 | ✅ 零 c/sh/py 步骤 | `lispjit.c` **仍在** |
| CI plan-only | 54 | ✅ | host `.sh` **仍在** |
| tools `.py` | 55 | ✅ | 维护 `.py` **仍在** |
| 四轨 rollup | 56 | ✅ `daily_v45_target` | **`zero_cpysh=1` 未达** |
| **lispjit.c 迁出** | **57** | ✅ `daily_v45_zero_c` | **active C 已删** · sh/py **仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.lispjit_c_delete_continue.100=1` | Wave57 Lisp 替代 + active C 迁 `retired/` |
| `v45.physical.zero_c_progress=1` | 进度键（**非**终局） |
| `v45.honest.lispjit_c_retired=1` | active `lispjit.c` 已迁出 |
| `v45.honest.zero_cpysh_remaining=1` | host `.sh` / `tools/*.py` 仍存 |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-c.lisp
bash lab/nano-lisp-jit/scripts/v45-wave57-lispjit-c-delete-converge.sh
```

## 下一物理轨

Wave58：host `scripts/v45-*.sh` 退 `retired/` · plan-only 外层终局
