# v4.5 终局进度

## 仓库口径 100% ✅

**主签收键**：`v45.warehouse.100=1`

| 键 | 含义 | 状态 |
|----|------|------|
| `v45.endgame.100=1` | DECISION tier0–4 | ✅ |
| `v45.factory.100=1` | scoped 工厂路径 | ✅ |
| `v45.warehouse.100=1` | **合卷终局** | ✅ |
| `v45.scoped.100=1` | 洋葱 scoped | ✅ |
| `v45.release.100=1` | 发行面 | ✅ |

## 收敛（唯一日常）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave9-converge.sh
grep v45.warehouse.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## Wave 扩散

| Wave | 状态 |
|------|------|
| Wave3–8 | ✅ |
| **Wave9** | ✅ [`DIFFUSE-WAVE9.md`](DIFFUSE-WAVE9.md) — factory/warehouse 100% |

## 超 DECISION 口径（仍不声称）

| 项 | 状态 |
|----|------|
| 仓内零 **全部** `.c` | ❌ |
| 无参 `run.sh` 即瘦工厂 | ❌ 须 `NANO_V45_SCOPED_ONLY=1` |
| 154KB runner 全 Lisp codegen | ❌ |
