# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | 内容 | 状态 |
|------|------|------|
| 1 | 154KB `lispjit.c` → Lisp codegen | Wave53 扩面绿 · **C 仍在** |
| 2 | CI `.sh` → plan-only 收敛 | Wave54 用户路径绿 · **host .sh 仍在** |
| 3 | `tools/*.py` 出仓或替代 | 未开 Wave55 |
| 4 | `v45.physical.zero_cpysh=1` | **未达** |

## 已签收（≠ v4.5 DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.lispjit_154kb_codegen_continue.100=1` | Wave53 154KB 扩面 |
| `v45.v45.ci_plan_only_converge_continue.100=1` | Wave54 plan-only 收敛 |
| `v45.converge.daily_v45_complete_plan_only=1` | 完整 daily（无 `.sh` 步骤） |
| `v45.honest.host_sh_ci_only=1` | host CI `.sh` **仍在**（诚实） |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete-plan-only.lisp
bash lab/nano-lisp-jit/scripts/v45-wave54-ci-plan-only-converge-converge.sh
```
