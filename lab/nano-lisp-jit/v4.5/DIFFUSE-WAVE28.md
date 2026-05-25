# Wave28 — 工厂物理续推（扩展活图 7/7）

在 **/goal 26/26** + **codegen 7/7** 不变前提下，并行：

| 轨 | plan |
|----|------|
| W1 | `codegen-lisp-slice-dual-arch` |
| W2 | `codegen-lisp-ir-table-broad` |
| W3 | `selfhost-next.com` → smoke + core + onion（全量代际） |
| W4 | `runsh-factory-continue-anchor` |
| R | `mindmap-factory-coupled-tree` + goal |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave28-factory-physical-continue-converge.sh
grep v45.v45.factory_physical_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
NANO_V45_FRONTIER=mindmap-frontier-v45-factory.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

证据：`v45.factory.selfhost_next_full=1` · `v45.codegen.lisp_slices=9`

**诚实未达**：154KB runner 全 Lisp codegen · 全 monorepo 零 C · 物理删除 run.sh
