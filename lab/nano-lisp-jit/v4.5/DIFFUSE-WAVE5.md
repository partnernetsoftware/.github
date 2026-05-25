# Wave5 扩散 — lisp-only 洋葱 · scoped CI · w3.com 矩阵

> **目标**：发行面 CI 不再绑全量 `tests.pass≥1302`；洋葱 plan 去 `lispjit.c`；`v45-w3-lisp-only.com` 矩阵探测。

## 本波交付

| 面 | 交付 |
|----|------|
| 洋葱 | `bootstrap-v45-onion-lisp-only.lisp` — 仅 `build-slice-lisp` + ape |
| CI | `v45-scoped-results.txt` — `tests.pass=2`（terminal + converge） |
| 收敛 | `scripts/v45-wave5-converge.sh`（内嵌 wave4） |
| w3 矩阵 | converge 内可选跑 `w3.com` smoke（不阻塞） |
| catalog | `v45-scoped-ci-run` 替代 `v35-regression-run` |
| run.sh | `run-bootstrap-v45-wave5-converge-plan` |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave5.diffuse=1` | Wave5 开卷 |
| `v45.onion.lisp_only_plan=1` | lisp-only 洋葱 plan 绿 |
| `v45.scoped.tests_pass=2` | scoped CI 口径 |
| `v45.w3_com.matrix=N` | w3.com 通过的 smoke 数（0–2 不阻塞） |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave5-converge.sh
```

## 诚实未声称

- `v45-w3-lisp-only.com` 跑 verify 仍可能 exit 42（代际能力未对齐 genesis com）
- 全量 `run.sh` v4 工厂墙未删
