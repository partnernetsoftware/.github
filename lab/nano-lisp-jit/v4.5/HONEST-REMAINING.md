# 物理终局 — 诚实口径

## 发行面目标（洋葱 TDD 扩散）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`。  
推进方式：mindmap 广度设计 → 主对话编排 → 后台 agents 四轨并发 → 收敛（Wave44 nano-lisp-com-terminal）。

## 已签收（v4.5 /goal 等 · ≠ 上表终局）

| 键 | 含义 |
|----|------|
| `v45.goal.onion_tdd_tree_mindmap.100=1` | /goal 26/26 |
| `v45.selfhost.plan_no_c=1` | plan 零 `lispjit.c` 路径 |
| `v45.physical.zero_c=1` | `lisp/` 树无真 `.c` |

## 诚实未达

- `.com` 体内 C codegen（`archive/c/runner/` 真源仍在）
- 收敛仍用 `scripts/v45-*.sh`（Wave40 用户入口已迁 `converge-daily-plan.lisp`，CI 外层仍 .sh）
- 产物名统一 `nano-lisp.com`（仓内暂 `nano-jit.com`）
- 154KB runner 全 Lisp codegen

## 日常

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-nano-lisp-com-terminal.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-terminal.lisp
```
