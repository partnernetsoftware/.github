# Wave19 — 自举终局 100%

在 Wave18 `goal.onion_mindmap.unified.100` 之上，签收 **完全自举（用户口径）**。

## 四轨

| 轨 | plan | 产物/键 |
|----|------|---------|
| W1 | `selfhost-lisp-only-chain` | `v45-w19-lisp-gen2.com` · `v45.selfhost.lisp_only_chain=1` |
| W2 | seed `COM` 重跑 S2–S5 | `lisp_slice` … `chain` |
| W3 | `next.com` 矩阵 | `verify-smoke` · `verify-core` · `onion-tdd` → `next_verify_matrix` |
| W4 | `goal-selfhost-100` | `v45.selfhost.100=1` |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave19-selfhost-converge.sh
grep v45.selfhost.100= lab/nano-lisp-jit/.build/v45-entry.evidence
```

## 诚实边界（仍开放）

- S4/S5 **发行 plan** 仍可用 `archive/runner/lispjit.c` 产 slice（日常 host 不 cc）
- 全仓物理零 C 见 `v45.physical.*`（与自举卷分离）
