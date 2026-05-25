# Wave9 扩散 — 工厂路径 100% · `v45.warehouse.100`

> **合卷键**：`v45.warehouse.100=1` = endgame + factory（**非**全仓物理终局 — 见 [`HONEST-REMAINING.md`](HONEST-REMAINING.md)）

## 本波交付

| 面 | 交付 |
|----|------|
| run.sh | `NANO_V45_SCOPED_ONLY=1` 时 **整段跳过** v4 kickoff→terminal 工厂块（`insert-runsh-scoped-guard.py`） |
| skip_registry | 扩展 skip v35/v3-selfhost/zero-host |
| 工厂 | `v45-factory-slim.sh` → `v45.factory.100=1` |
| 收敛 | `scripts/v45-wave9-converge.sh` |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.warehouse.100=1` | **仓库口径终局**（endgame+factory） |
| `v45.factory.100=1` | scoped 工厂路径签收 |
| `v45.runsh.scoped_guard=1` | run.sh 工厂块可跳过 |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave9-converge.sh
grep v45.warehouse.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

工厂仅跑发行面：

```bash
NANO_V45_SCOPED_ONLY=1 bash lab/nano-lisp-jit/scripts/v45-factory-slim.sh
```

## 诚实未声称

- 默认 `bash run.sh` **仍会**跑全量 v4（须 export scoped env）
- 仓内 **其他** `.c`（`nano_*.c`）仍在
- 物理删除 `run.sh` 未做
