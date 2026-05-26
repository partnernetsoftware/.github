# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

在达成前：**禁止**混称 v4.5 DONE。

## 完成路径（当前聚焦）

| 阶段 | 内容 | 状态 |
|------|------|------|
| 1 | 154KB `lispjit.c` → Lisp codegen 全模块 | Wave53 扩面绿 · **C 仍在** |
| 2 | 外层 CI `.sh` → plan-only 收敛 | 未开 |
| 3 | `tools/*.py` 出仓或 Lisp 替代 | 未开 |
| 4 | `v45.physical.zero_cpysh=1` 签收 | **未达** |

## 已签收（≠ 物理终局）

| 键 | 含义 |
|----|------|
| `v45.goal.onion_tdd_tree_mindmap.100=1` | /goal 26/26 |
| `v45.v45.lispjit_154kb_codegen_continue.100=1` | Wave53 154KB 扩面 |
| `v45.codegen.lispjit_154kb_expand=1` | 15link 全 13 模块绿 |
| `v45.honest.lispjit_c_remains=1` | archive C **仍在**（诚实） |

## 日常

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical.lisp
bash lab/nano-lisp-jit/scripts/v45-wave53-lispjit-154kb-codegen-expand-converge.sh
```
