# v4.5 终局进度

## 终局 100% ✅

**主签收键**：`v45.endgame.100=1`

| 键 | Tier | 状态 |
|----|------|------|
| `v45.scoped.100=1` | 0–2 + 洋葱 | ✅ |
| `v45.release.100=1` | 发行面 | ✅ |
| `v45.runner.no_c_src=1` | **3** no-c-src | ✅ |
| `v45.codegen.vm_emit=1` | **4** vm-emit | ✅ |
| `v45.endgame.100=1` | **终局** | ✅ |

## 收敛（唯一日常）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave8-converge.sh
grep -E 'v45\.(endgame|release|scoped)\.100=1' lab/nano-lisp-jit/.build/v45-entry.evidence
```

## Wave 扩散

| Wave | 状态 |
|------|------|
| Wave3–7 | ✅ |
| **Wave8** | ✅ [`DIFFUSE-WAVE8.md`](DIFFUSE-WAVE8.md) — tier3 迁仓 + tier4 IR emit |

## 诚实未声称（超 DECISION 口径）

| 项 | 状态 |
|----|------|
| 仓内零 **所有** `.c` | ❌ `lispjit-ir` 仍有 `nano_*.c` 等 |
| 物理删 `run.sh` | ❌ `NANO_V45_SCOPED_ONLY` skip |
| 全量 runner Lisp codegen | ❌ genesis pin |
