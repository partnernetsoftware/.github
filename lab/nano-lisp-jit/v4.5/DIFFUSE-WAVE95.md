# Wave95 — semantic 32K milestone（modules-semantic 轨）

**签收**：`v45.goal.semantic_32k_milestone=1` · code_bytes ≥ **32000**

| 槽 | 交付 |
|----|------|
| W1 | `gen-semantic-compose15.py` → `tu-main-32k.lisp` (2765 func) |
| W2 | profile `compose-15link-semantic-32k` |
| W3 | `probe-compose15-semantic-32k-pure-link.lisp` |
| W4 | journal round 24 · 8K 轨回归 |

**三轨并存**：

| 轨 | profile | code_bytes |
|----|---------|------------|
| semantic 8K | `compose-15link-semantic` | 9286 |
| semantic 32K | `compose-15link-semantic-32k` | **32001** |
| bulk | `compose-15link-bulk-scale` | 154559 |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave95-semantic-32k-converge.sh
```

**下一波**：semantic 64K 阶梯
