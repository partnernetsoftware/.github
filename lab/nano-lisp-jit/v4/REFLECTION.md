# v4 反思与调整（track R · 持续更新）

**范围**：v3.5-terminal 之后、v4 **S0–S5 scoped 已签收**（`catalog-v4` → `v4-slice5-scoped`）。与 [`../v3.5/REFLECTION.md`](../v3.5/REFLECTION.md) 互补：彼处跨版本债，此处 **v4 编排轨 + codegen 轨**。

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

**并行标准流程**（四角色一进程一角色）：

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume --reason <wave>
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team --auto-exec --auto-done
# 本地验证：SQUAD_VERIFY=1 lab/nano-lisp-jit/run.sh
```

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
| 2026-05-23 | **wave12**：S7 emit profile + add11；`parse_add_operands` 已读 plan 内 `(i64 …)`，profile 标记可观测 |
| 2026-05-23 | **wave11**：本文件 + S6 codegen kickoff；调整 wave11+ 双轨策略 |
| 2026-05-23 | S0–S5 汇总入账；小队 §2 调整表与 `SQUAD_VERIFY` 实践 |
