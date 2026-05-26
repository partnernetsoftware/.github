# 物理终局 — 诚实口径

## 发行面目标（洋葱 TDD 扩散）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`。

## v4.5 规划面 DONE ✅

签收：`v45.v45.v45_terminal_complete.100=1`

| 层 | 状态 |
|----|------|
| /goal 主活图 | 26/26 |
| 扩展活图 Wave34–51 | **18 张 × 7/7** |
| 用户 daily | `converge-daily-v45-complete.lisp` |
| CI verify | `v45-wave51-v45-terminal-complete-converge.sh` |

推进记录：Wave44–51 发行面终局链 · Wave50 154KB 独立活图 · Wave51 全链 rollup。

## 已签收（v4.5 /goal 等 · ≠ 物理终局）

| 键 | 含义 |
|----|------|
| `v45.goal.onion_tdd_tree_mindmap.100=1` | /goal 26/26 |
| `v45.selfhost.plan_no_c=1` | plan 零 `lispjit.c` 路径 |
| `v45.physical.zero_c=1` | `lisp/` 树无真 `.c`（发行面） |

## 诚实未达（v5 / maintenance）

- `archive/c/runner/lispjit.c` ~154KB 全 Lisp codegen（探针绿 ≠ 替代 DONE）
- host 仍 `nano-jit.com`；产品叙事 `nano-lisp.com`
- CI/维护仍用 `scripts/v45-*.sh`（用户 plan 面无 `.sh`）

## 日常

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-v45-terminal-complete.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete.lisp
bash lab/nano-lisp-jit/scripts/v45-wave51-v45-terminal-complete-converge.sh
```
