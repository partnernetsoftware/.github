# Wave11 — tier5 物理扩散（四轨并发 · 单轮收敛）

> **不签收** `physical.zero_c=1`；本波推进 T5a–T5d 切片，证据透明。

## 四轨（≤4 槽 · 同时 touch）

| 轨 | 角色 | T5 | 交付 |
|----|------|-----|------|
| **A** | engineer-a | T5a | 无参 `run.sh` → `NANO_V45_SCOPED_ONLY=1` 默认 |
| **B** | engineer-a | T5b | `nano_bootstrap.c` 迁 `archive/c/runner/` + symlink |
| **C** | engineer-b | T5c | [`PHYSICAL-INVENTORY.md`](PHYSICAL-INVENTORY.md) + 计数 plan |
| **D** | engineer-b | T5d | `wave11-vm-emit-matrix` — tier4 IR 扩面 smoke |
| **R** | reviewer | — | `wave11-rollup` + `REFLECTION` |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave11.diffuse=1` | 全局扩散 plan 绿 |
| `v45.wave11.parallel=4` | 四轨 plan 齐 |
| `v45.wave11.rollup=1` | reviewer rollup |
| `v45.tier5.runsh_default=1` | T5a 默认瘦入口 |
| `v45.tier5.archive_symlinks=2` | lispjit + nano_bootstrap 在 archive |
| `v45.physical.zero_c=0` | **仍未完成** |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave11-tier5-converge.sh
```

全量 v4 工厂：`NANO_V45_FULL_FACTORY=1 bash lab/nano-lisp-jit/run.sh`
