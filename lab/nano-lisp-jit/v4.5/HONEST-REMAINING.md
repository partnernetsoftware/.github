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
| lispjit.c 迁出 | 57 | ✅ `daily_v45_zero_c` | active C 已删 · sh **仍在** |
| **host .sh 迁出** | **58** | ✅ `daily_v45_plan_only_outer` | **wave `.sh` 已删** · py **仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.host_sh_retire_continue.100=1` | Wave58 plan-only 外层 + wave `.sh` 迁 `retired/scripts/` |
| `v45.physical.zero_cpysh_progress=1` | 进度键（**非**终局） |
| `v45.honest.host_sh_retired=1` | 历史 `v45-wave*.sh` 已迁出 |
| `v45.honest.zero_cpysh_remaining=1` | CI wave58 `.sh` / `tools/*.py` 仍存 |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-outer.lisp
bash lab/nano-lisp-jit/scripts/v45-wave58-host-sh-retire-converge.sh
```

## 下一物理轨

Wave59：`tools/*.py` 退 `retired/` · 全 monorepo plan-only 终局
