# v4.5 — 发行面 = `nano-jit.com` + `*.lisp`

**前置**：v4 lispjit-from-lisp DONE · tier0 ✅

## 发行面验收（tier1 · 仅 `.com`）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
for p in verify-smoke verify-core v4-handoff verify-all entry; do
  $COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp
done
grep v45.verify.plan_only=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## verify 矩阵

| plan | 覆盖 |
|------|------|
| `bootstrap-v45-verify-smoke.lisp` | VM 前缀（strlen/arithmetic/ctrl/emit） |
| `bootstrap-v45-verify-core.lisp` | multi-func/ptr/AOT/APE/pack-app |
| `bootstrap-v45-v4-handoff.lisp` | v4 gen60/genesis/.com + lispjit-modules |
| `bootstrap-v45-verify-all.lisp` | 矩阵索引 + `.com` hash |
| `bootstrap-v45-entry.lisp` | tier0 入口 + 锚点 |

## Tier 进度

| Tier | 状态 |
|------|------|
| 0 entry | ✅ |
| **1 com-only verify** | **✅ 开卷** |
| 2 无 host cc | 未开 |
| 3 无 C 源码 | 未开 |
| 4 VM emit | 未开 |

口径：[`DECISION.md`](DECISION.md)
