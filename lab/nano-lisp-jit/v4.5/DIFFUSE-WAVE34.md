# Wave34 — runner codegen 广面（fasmgx 第九活图）

在 Wave33 代际深潜之上，把 codegen 从四轨探针扩到 **runner 广面**（模块表 · emit 宽表 · ir-facade · modules 子集）。

| 轨 | plan（规划） |
|----|----------------|
| W1 | `codegen-runner-module-table` |
| W2 | `codegen-runner-emit-broad` |
| W3 | `codegen-ir-facade-next` |
| W4 | `codegen-lispjit-modules-subset` |
| R | `runsh-slim-terminal` |
| T/G | mindmap-tree · goal-100 |

**活图 SSOT**：[`../../../fasmgx/mindmap-frontier-runner-codegen.json`](../../../fasmgx/mindmap-frontier-runner-codegen.json)  
**策划**：[`../../../fasmgx/NEXT-ONION-TDD-TREE.md`](../../../fasmgx/NEXT-ONION-TDD-TREE.md)

```bash
bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh
grep v45.v45.runner_codegen_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.codegen.selfhost_next_runner_broad=1` · `v45.codegen.runner_broad_profiles=4`

**诚实未达**：154KB runner 全 Lisp codegen · 物理删 `run.sh`
