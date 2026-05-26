# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

在达成前：**禁止**混称 v4.5 DONE · **禁止**开 v5。

## 已签收（扩展活图 / 发行面子集 · ≠ 物理终局）

| 键 | 含义 |
|----|------|
| `v45.goal.onion_tdd_tree_mindmap.100=1` | /goal 26/26 |
| `v45.v45.v45_terminal_complete.100=1` | 扩展活图 Wave34–51 rollup（**≠ 目标达成**） |
| `v45.v45.physical_zero_cpysh_continue.100=1` | Wave52 物理续推签收 |
| `v45.selfhost.plan_no_c=1` | plan 零 `lispjit.c` 路径 |
| `v45.physical.zero_c=1` | `lisp/` 树无真 `.c`（发行面 · **≠ 全仓零 C**） |

## 诚实未达

| 项 | 说明 |
|----|------|
| `archive/c/runner/lispjit.c` ~154KB | 全 Lisp codegen 未替代 |
| CI / 维护 | `scripts/v45-*.sh` · `tools/*.py` 仍在 |
| host 产物 | 仍 `nano-jit.com`；叙事 `nano-lisp.com` |
| `v45.physical.zero_cpysh=1` | **未达** — 全仓零 `.c/.py/.sh` |

## 日常

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-physical-zero-cpysh-continue.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-zero-cpysh.lisp
bash lab/nano-lisp-jit/scripts/v45-wave52-physical-zero-cpysh-continue-converge.sh
```
