# v3.5 小组并行模式（审查员 / 指挥长 / 工程兵）

**签收判据（100% 才全员停）**：见 [`LISP-ONLY.md`](LISP-ONLY.md) § v3.5 完成定义 + [`README.md`](README.md)。

| 角色 | 职责 | 产出物 |
|------|------|--------|
| **审查员 R** | 观察证据/技术债；对比 mindmap「终局 vs scoped」 | `REFLECTION.md` §1–4 + ROADMAP「反思 · v3.5」节点补丁 |
| **指挥长 C** | 评估是否 100%；维护 mindmap；派单 A/B（最多 2 开发轨） | 本文件「派单板」+ ROADMAP 进度表 |
| **工程兵 A** | 执行派单（偏 P0/L2） | 代码 + `run.sh` + commit |
| **工程兵 B** | 执行派单（偏 P1/L4） | 代码 + `run.sh` + commit |

## 指挥长 · 当前评估（非 100% → 继续）

**已 scoped**：gen5 双架构 Lisp pack（零 genesis pin）；L0–L3；nano-cc 证据轨。  
**未签收**：L4 全功能 runner；L2 去 companion；aarch64 非 stub；gen5 由 Lisp 全功能 slice 编排。

## 派单板（本轮 · wave-squad-1）

| 兵 | 任务 ID | 状态 | 验收 |
|----|---------|------|------|
| **A** | `L2-companion` | **完成** `7866e4e` | canonical `nano-jit-slice-add.lisp`；删 `nano-cc-add.lisp`；250 pass |
| **B** | `L4-tu-kickoff` | **完成** `a043fd5` | `bootstrap-v35-lisp-tu-link.lisp` + run/build case |
| **R** | `wave-squad-R1` | **完成** `20e36c2` | ROADMAP 小组模式 + PARALLEL 表 |

**指挥长判定**：仍 **≠100%** → 开 wave-squad-2（见下）。

## 派单板（wave-squad-2 · 待派）

| 兵 | 任务 ID | 洋葱切片 | 验收 |
|----|---------|----------|------|
| **A** | `aarch64-codegen-1` | min profile 从 exit-stub 扩一步（保留 qemu） | 新日志 tag + run case |
| **B** | `L4-runner-1` | gen5 plan 改由 `v35-gen4-nano-jit.com` 跑（若 slice 仍 stub 则文档化阻塞） | selfhost case 或 skip+REFLECTION |
| **R** | `wave-squad-R2` | 更新 L2/L4 签收栏；进度 → ~88% | REFLECTION + mindmap |

**合并顺序**：A → B → R → C 全矩阵。

## 停止条件

```text
gen5 计划无 .c
AND 双架构 Lisp slice + pack 无 genesis pin
AND aarch64 真实 codegen 签收（非仅 exit-stub）
AND L4：至少一条「多 TU link」→ 可 run-bootstrap-plan 的剖面样例
AND run.sh + NANO_SELFHOST_THOROUGH=1 build 全绿
→ 指挥长宣布 v3.5 100%，A/B/R 停派单
```
