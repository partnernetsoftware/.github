# v4 反思与调整（track R · 持续更新）

**范围**：v3.5-terminal 之后、v4 **signoff `v4-slice9-scoped`**（编排 S0–S5 + codegen S6–S9）。与 [`../v3.5/REFLECTION.md`](../v3.5/REFLECTION.md) 互补；**未达成**全仓库零 `.c` 自举 — 见 [`LISP-ONLY.md`](LISP-ONLY.md)、[`../ROADMAP.md`](../ROADMAP.md) § v4 mindmap。

---

## 1. 进度（诚实口径）

| Slice | 签收 id | 交付 | 未声称 |
|-------|---------|------|--------|
| S0 | `v4-slice0-scoped` | aarch64 scout + squad assess/dispatch 样本 | 真 AOT |
| S1 | `v4-slice1-scoped` | add7 参数化 `aarch64-add-emit` | VM codegen |
| S2 | `v4-slice2-scoped` | `state-v4.db` + gen5v2 锚点 | Lisp SQLite FFI |
| S3 | `v4-slice3-scoped` | `supervise` / `run-loop --once` | 完整 run-loop |
| S4 | `v4-slice4-scoped` | agent-team 契约 + commander complete smoke | 4× Lisp 并行 |
| S5 | `v4-slice5-scoped` | verify-before-done 样本 + wave10 四角色 smoke | `(squad-done)` Lisp |
| **S6** | `v4-slice6-scoped` | codegen **kickoff**（emit 路径清单 + 锚点） | 替换 `emit_aarch64_*` |
| **S7** | `v4-slice7-scoped` | **`aarch64.emit.profile=add-exit-v1`** + add11 样本 | IR 驱动 emit |
| **S8** | `v4-slice8-scoped` | insn 数组 lowering + add13 | opcode 枚举 |
| **S9** | `v4-slice9-scoped` | `A64_ADD_EXIT_OP_*` + add14 | VM emit |
| **S10–S15** | `v4-complete` scoped | IR entry/table v1–v4、terminal smoke | 零宿主 |
| **S16–S17** | post-v4 | plan-words 契约；**C 读 plan 字表校验**（add20） | VM emit |

**catalog 100% ≠ 终局 100%**：见 [`PROGRESS.md`](PROGRESS.md)（终局整体约 10–20%）。

**三层「全 Lisp」**：仍见 [`LISP-ONLY.md`](LISP-ONLY.md) — plan 层无 `.c`；codegen 层仍是 C stub。

---

## 2. 小队工具 — 实践反思

| 现象 | 根因 | **调整（已做 / 继续）** |
|------|------|-------------------------|
| 指挥长 wave 飙高 | `resume` 未重置 wave | ✅ `epoch++` + `wave=1` |
| signoff 100% 空转 | `ready` 仍 `wave++` | ✅ `team_ready` → `complete` |
| follower 签收后空等 | 仅 `standby` 才 `stand_down` | ✅ `team_ready` 即 `stand_down` |
| `auto-exec` 超时 | 嵌套全量 `run.sh` verify | ✅ `SQUAD_VERIFY=1` + `--no-auto-exec`；**默认**手跑或 `done` |
| commander smoke 红 | 新 wave 任务 pending 时 `outcome=continue` | ✅ smoke 接受 `ready=True` |
| assess 96% 瞬态 | `run.sh` 未写 `tests.pass` 就 assess | ✅ commander smoke **在** `run_end_summary` **之后** |
| 100% 不 dispatch | 仅 worker pending 才继续 | ✅ 新 wave 用 `resume` + `dispatch --force --include-meta` |

**并行标准流程**：见仓库技能 **[`skills/squad-parallel/`](../../skills/squad-parallel/)**（`run-wave.sh` / `poll-tasks.sh`）；Agent 须亲自执行，勿只给用户命令。

---

## 3. 设计与范围调整（wave11+）

1. **编排轨与 codegen 轨分离**：S0–S5 冻结 host Python 协议；S6+ 主攻 **C 层 emit 清单 → VM/AOT 切片**，不再扩 squad 特性面。
2. **证据写入**：短期仍允许 `run.sh` 追加 `.evidence`；中期迁入 **bootstrap plan 单步**（与 S5 叙事一致）。
3. **签收粒度**：每 slice 独立 `signoff.id`；gate **只增不删**，`min_pass` 随 `run.sh` 计数上调（当前 run ≥280）。
4. **plan 无 `.c` 扫描**：S6 允许 `(file-hash "…/nano_elf64.c")` 等 **清单锚点**；`run.sh` 排除 `(file-hash|file-size)` 行，避免误报。
5. **emit 版本化**：`add-exit-v1` 日志锁定当前 stub 契约；换指令序列时 bump profile（wave12）。
6. **下一硬目标**：`emit_aarch64_add_exit_file` 由 **IR lowering 表** 驱动（非 C 内手写 `movz` 序列）；见 [`SLICE7.md`](SLICE7.md)。

---

## 4. 风险与依赖

- **genesis aarch64 pin** 仍可能过期 → slice6 证据 **双锚**：add7 ELF hash + `nano_elf64.c` hash。
- **qemu** 可选；无 qemu 时 skip，不伪造 pass。
- **并行 touch**：`nano_bootstrap.c` / `nano_elf64.c` / `run.sh` — 仍按 [`../squad/PARALLEL.md`](../squad/PARALLEL.md) 分轨。

---

## 5. 变更日志

| 日期 | 摘要 |
|------|------|
| 2026-05-23 | **mindmap 调整**：ROADMAP v4 洋葱图改为三层诚实口径 + 双轨完成度表；澄清 S9≠终局自举 |
| 2026-05-23 | **wave14**：`v4-slice9-scoped` — opcode 序表 + `lowering.ops=5` + add14；`squad-parallel` 实跑 |
| 2026-05-23 | **方法学固化**：[`skills/squad-parallel/`](../../skills/squad-parallel/) Agent Skill（`.cursor/skills` 链接） |
| 2026-05-23 | **wave13**：**agent-team 四角色 tmux 实跑**（`--auto-exec --auto-done`）完成 lowering-table + add13；修复 `spawn_agent_team` tmux argv |
| 2026-05-23 | **wave12**：S7 emit profile + add11；`parse_add_operands` 已读 plan 内 `(i64 …)`，profile 标记可观测 |
| 2026-05-23 | **wave11**：本文件 + S6 codegen kickoff；调整 wave11+ 双轨策略 |
| 2026-05-23 | **wave30**：洋葱圈索引 + 四轨 supervise/contract 回归 |
| 2026-05-23 | **wave29**：四轨扩散 ≤4 并发；plan 双 results-min；`v4-plan-manifest-v1.lisp` |
| 2026-05-23 | **wave27–28**：扩散收敛（整表+words-v2 交叉验证）；反思固化 PARALLEL 禁止碎补；`EVAL.md` 合 main 进度 |
| 2026-05-23 | S0–S5 汇总入账；小队 §2 调整表与 `SQUAD_VERIFY` 实践 |
---

## 6. wave27–28 反思（扩散 vs 碎补）

| 做对 | 做错 / 已改 |
|------|-------------|
| 一波铺开 plan 族 + catalog/run.sh | wave26 逐 op 改 C = 假进度 |
| 整表 `plan-lisp-v1-full` 一次读入 | 勿再把「改 C」当终局交付 |
| `EVAL.md` 六维与 catalog 分离 | 勿用 ready=True 暗示零宿主 |
| 合 main 带进度评估 | — |

**下一扩散面（未开卷）**：Lisp VM emit；`build.pass≥119` 进 plan（需 cosmocc）；runner 非 C。
| wave31 | POST-V4 证据矩阵四轨 + add26 | catalog ready ≠ 零宿主 |
| wave32 | host-reduce 洋葱 + add27 + lisp-only tick | plan 无 .c ≠ runner 无 C |
| wave33 | build-graph 洋葱 + assess-chain + add28 | 仍非 Lisp VM emit |
| wave34 | plan-contract + terminal tick + add29 | scoped/终局分界在 DECISION |
| wave35–37 | 批量 3 波四轨（add30–32）| 提速：单回合收敛，仍非 VM emit |
| wave38–40 | 批量 add33–35 + IR/onion 锚点 | 终局 % 靠 emit 开卷 |
| wave41–43 | 批量 add36–38 + mindmap 收束 | 合 main 必带 EVAL §wave41–43 |
| wave44–46 | 批量 add39–41 | 合 main 带 EVAL §wave44–46 |
| wave47–49 | 批量 add42–44 | 合 main 必带 EVAL §wave47–49 |
| wave50–52 | 批量 add45–47 | 合 main 带 EVAL §wave50–52 |
