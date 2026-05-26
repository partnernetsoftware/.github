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
FASMGX_FRONTIER=mindmap-frontier-runner-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
# 收敛脚本（待实现）:
# bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh
```

证据（规划）：`v45.v45.runner_codegen_continue.100=1` · `v45.codegen.runner_broad_profiles=4`

**诚实未达**：154KB runner 全 Lisp codegen · 物理删 `run.sh`
