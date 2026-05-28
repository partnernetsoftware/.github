# Wave79 — com-integrity-sync（/goal nano-jit.com · integrity 反思插队）

**签收**：`v45.goal.com_integrity_sync_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `goal-com-manifest-pin-sync.lisp` | manifest fnv ↔ COM file-hash |
| W2 | `goal-com-container-audit.lisp` | inspect-ape + genesis slice parity |
| W3 | `goal-com-bootstrap-host-matrix.lisp` | verify 矩阵重 pin（不含 run-ape exit42） |
| W4 | daily |

**背景**：Wave78 后 integrity 四层分析 — L1/L3 pass，**L2 manifest 过期**，L4 仍 open。

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave79-com-integrity-sync-converge.sh
```

**下一波 preview**：wave80-compose15-module-expand（L4 语义层）
