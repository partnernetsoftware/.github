# Wave33 — codegen 代际深潜（扩展活图 7/7）

在 Wave32 rollupy 之上，**selfhost-next** 并发跑 codegen 探针（slice + VM + ir-table）。

| 轨 | plan（next.com） |
|----|------------------|
| W1 | `codegen-lisp-slice-min` |
| W2 | `codegen-lisp-vm-ctrl` |
| W3 | `codegen-lisp-ir-table` |
| W4 | `codegen-lisp-vm-arith` |
| R | `runsh-slim-terminal`（发行锚） |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave33-codegen-deep-continue-converge.sh
grep v45.v45.codegen_deep_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.codegen.selfhost_next_codegen=1` · `v45.codegen.next_deep_profiles=4`

**诚实未达**：154KB runner 全 Lisp codegen（探针已在代际 com 绿，≠ 全量 C 替代）
