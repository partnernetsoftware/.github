# Wave10 — 诚实剩余（tier5 开卷，**不**冒充物理 100%）

## 交付

| 面 | 交付 |
|----|------|
| 真源 | [`HONEST-REMAINING.md`](HONEST-REMAINING.md) |
| 入口 | `scripts/v45-release-run.sh`（`NANO_V45_SCOPED_ONLY=1` + `run.sh`） |
| 收敛 | `scripts/v45-wave10-honest-converge.sh` |
| 明示未完成 | `v45.physical.zero_c=0` |

## 禁止写法

- 不得把 `v45.warehouse.100=1` 写成「全仓终局完成」
- 不得把 `v45.endgame.100=1` 写成「零 `.c`」

## 证据键

| 键 | 含义 |
|----|------|
| `v45.honest.tier5.open=1` | 物理终局进行中 |
| `v45.physical.zero_c=0` | **未完成**（故意写 0） |
| `v45.physical.lispjit_ir_c_files=N` | 计数透明 |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave10-honest-converge.sh
```
