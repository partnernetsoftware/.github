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

## 派单板（本轮）

| 兵 | 任务 ID | 洋葱切片 | 验收 |
|----|---------|----------|------|
| **A** | `L2-companion` | P0：nano-cc add 不再依赖 `nano-cc-add.lisp` companion；门禁改以 `nano-jit-slice-add.lisp` 为 add 真相源 | `run.sh` 全绿；plan 日志无 `nano-cc.lisp=` |
| **B** | `L4-tu-kickoff` | P1：多 `.lisp` → `link-elf64-exe` bootstrap 样例（2 object smoke） | 新 `bootstrap-v35-lisp-tu-link.lisp` + `run.sh` case |
| **R** | `wave-squad-R1` | 汇入 gen5 状态、小组模式、A/B 缺口 | ROADMAP + REFLECTION 变更日志一行 |

**合并顺序**：A（`nano_cc.c`/`run.sh`）→ B（samples/bootstrap）→ R（docs）→ C 跑全矩阵。

## 停止条件

```text
gen5 计划无 .c
AND 双架构 Lisp slice + pack 无 genesis pin
AND aarch64 真实 codegen 签收（非仅 exit-stub）
AND L4：至少一条「多 TU link」→ 可 run-bootstrap-plan 的剖面样例
AND run.sh + NANO_SELFHOST_THOROUGH=1 build 全绿
→ 指挥长宣布 v3.5 100%，A/B/R 停派单
```
