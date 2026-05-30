# Wave29 — selfhost-next 深度自举矩阵（扩展活图 7/7）

在 Wave28 工厂物理之上，**selfhost-next.com** 四轨并发：

| 轨 | plan（跑在 next.com 上） |
|----|-------------------------|
| W1 | `selfhost-modules-full`（13/13） |
| W2 | `selfhost-regenesis-lisp-only` |
| W3 | `selfhost-chain-lisp-only` |
| W4 | `onion-tdd`（代际洋葱复核） |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave29-selfhost-deep-continue-converge.sh
grep v45.v45.selfhost_deep_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.factory.selfhost_next_deep=1` · `v45.selfhost.next_onion_tdd=1`

**诚实未达**：154KB 全量 runner Lisp codegen · 全 monorepo 零 C
