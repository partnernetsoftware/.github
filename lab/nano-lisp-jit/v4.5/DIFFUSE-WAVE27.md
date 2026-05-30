# Wave27 — 工厂 codegen 洋葱×mindmap 耦合（扩展活图 7/7）

在 **/goal 26/26 不变** 前提下，扩展 [`mindmap-frontier-v45-codegen.json`](mindmap-frontier-v45-codegen.json)：

| 轨 | plan |
|----|------|
| W1 | `codegen-lisp-vm-ctrl` |
| W2 | `codegen-lisp-vm-multi` |
| W3 | `onion-chain-lo-minimal` |
| W4 | `codegen-lisp-gen60-handshake` |
| R | `mindmap-codegen-coupled-tree` + goal |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave27-codegen-coupled-converge.sh
grep v45.v45.codegen_coupled.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
NANO_V45_FRONTIER=mindmap-frontier-v45-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

证据：`v45.codegen.lisp_slices=7` · `v45.codegen.vm_emit_profiles=4` · `v45.mindmap.codegen.coupled=1`

**诚实未达**：154KB runner 全量 Lisp codegen · 全 monorepo 零 C。
