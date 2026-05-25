# Wave4 扩散 — next 代际洋葱 · tier3 锚点 · squad plan 化

> **目标**：在 Wave3 单轮收敛之上，**一代** 完成 `next.com` 全洋葱、tier3 归档锚点、squad 验收 plan 化。

## 本波交付

| 面 | 交付 |
|----|------|
| 收敛 | `scripts/v45-wave4-converge.sh` — 内含 wave3 + wave4 四 plan + **next 跑 onion-tdd** |
| tier3 | `archive/runner/` README + `lispjit.c` 符号链接锚点 |
| squad | `bootstrap-v45-wave4-squad-plan.lisp` — plan 内仅 `squad-dispatch`/`squad-assess`（无 `.sh` 步骤） |
| runner C | `nano_bootstrap.c` — `squad-assess` 改为 catalog smoke（与 dispatch 同构） |
| run.sh | 单 case `run-bootstrap-v45-wave4-converge-plan` |
| catalog | `verify` → `v45-wave4-converge.sh`；wave4 四轨任务 |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave4.diffuse=1` | Wave4 开卷 |
| `v45.wave4.plans=N` | 当前 `bootstrap-v45-*.lisp` 总数 |
| `v45.tier3.runner_archived=1` | `archive/runner` 锚点就绪 |
| `v45.tier3.plan_no_c=1` | wave4 tier3 plan 无 `build-slice` C |
| `v45.selfhost.next_onion=1` | `next.com` 跑通 `onion-tdd` |
| `v45.squad.plan_no_sh=1` | squad plan 无 shell 步骤 |

## 收敛（发行面日常）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave4-converge.sh
```

## 诚实未声称

- 仓内 **未删除** `lab/lispjit-ir/lispjit.c`（`v45.runner.no_c_src` 仍为 0）
- `nano-jit.com` 需重打 ape 才带上新 `squad-assess` smoke（genesis 代际后续波）
- `run.sh` v4 工厂 case 墙未退役

## Wave5

已实施：[`DIFFUSE-WAVE5.md`](DIFFUSE-WAVE5.md) · `v45-wave5-converge.sh`
