# Wave2 扩散筹划 — 完全自举 · 工厂 Lisp 化（一刀 wave，非几十年碎砍）

> **问题**：S0–S5 已证明「能」；若按 S6、S7… 各开一周 = 假进度。  
> **解法**：**Wave2 单波扩散** — 四轨 ≤4 并发槽，**同一收敛轮** `v45-wave2-converge.sh`。

## 北极星（本波结束定义）

```text
发行面 = 仅 nano-jit.com + *.lisp plan 矩阵（含 next.com 代际验证草图）
工厂   = run.sh 仅 terminal；日常收敛 = v45-com-verify + wave2-converge
自举   = S2–S5 保持 + S6 next.com 跑 smoke + S7 全模块 TU
```

**不声称**：tier3 删光 `lispjit.c`、tier4 VM emit（留 Wave3 扩散面）。

## 扩散面（Wave2 一次铺开）

| 面 | 轨 | 并发交付物 | 禁止 |
|----|-----|------------|------|
| **自举代际** | A | `selfhost-next-com-verify` · `selfhost-modules-full` · `SELFHOST` S6–S8 | 勿改 genesis 字节 |
| **工厂矩阵** | B | `factory-matrix.lisp` · `wave2-diffuse-global` · `DIFFUSE-WAVE2` | 勿删 v4 wave 样本 |
| **收敛脚本** | C | `v45-wave2-converge.sh` · 扩 `v45-com-verify` · catalog wave2 | 勿扩 run.sh 1212 case |
| **评估签收** | D | `wave2-assess` · `EVAL/REFLECTION` · `wave2-rollup` | 勿单独改 boundary 域 |

## 自举阶梯（Wave2 并入，非新几十年）

| 阶 | 本波目标 | plan / 脚本 |
|----|----------|-------------|
| S6 | **next.com** 跑 `verify-smoke` | `scripts/v45-wave2-converge.sh` |
| S7 | **13/13** `lispjit-modules` VM | `bootstrap-v45-selfhost-modules-full.lisp` |
| S8 | 工厂 **plan 索引**（替代 run.sh 心智） | `bootstrap-v45-factory-matrix.lisp` |
| S9 | `build-slice-lisp` 多切片族 | Wave3 扩散（本波只登记） |
| T3/T4 | runner 出仓 / VM emit | Wave3–4（本波不砍） |

## 四轨并发实施

详见 [`CONCURRENT-IMPL.md`](CONCURRENT-IMPL.md)。

```bash
# ① 扩散登记
skills/squad-parallel/scripts/fast-wave.sh \
  lab/nano-lisp-jit/squad/catalog-v45.yaml wave2-v45-lisp-selfhost

# ② 四轨并行改 touch_paths（见 CONCURRENT-IMPL §轨 A–D）

# ③ 收敛（一次）
bash lab/nano-lisp-jit/scripts/v45-wave2-converge.sh

# ④ assess
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v45.yaml assess
```

## 证据键（Wave2）

| 键 | 含义 |
|----|------|
| `v45.wave2.diffuse=1` | `wave2-diffuse-global` 绿 |
| `v45.wave2.factory_matrix=1` | `factory-matrix` 索引齐 |
| `v45.selfhost.modules_full=1` | 13 模块 VM |
| `v45.selfhost.next_com=1` | next.com smoke 绿 |
| `v45.wave2.rollup=1` | reviewer rollup |

## Wave3 草图（勿本波碎做）

| 面 | 一次扩散 |
|----|----------|
| 无 C plan | 全部 `build-slice-lisp` / 模块链接 TU |
| run.sh | 单 case → `exec v45-wave2-converge.sh` |
| squad | `squad-dispatch` 迁 bootstrap，去 `system(squad.sh)` |
| 归档 | `bootstrap-v4-wave*` → `archive/samples/`（批量路径脚本 **一轮**） |

## 反模式（= 几十年）

- ❌ 每加一个 boundary op 开新 wave  
- ❌ 每修一个 run.sh case 开 PR 自称 100%  
- ❌ A/B 同改 `nano_bootstrap.c` 同一函数  
- ❌ 未写代码先挂 `agent-team` 全量 run.sh  
