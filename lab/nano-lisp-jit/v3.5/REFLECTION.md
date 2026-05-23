# v3.5 反思（并行 track R · 持续更新）

**范围**：v3 完全 100% 之后、v3.5 **~100%** 当下（squad signoff 全绿）。与 [`../ROADMAP.md`](../ROADMAP.md) §「v3.5 洋葱 TDD mindmap」同步；开发轨最多三路并行，**反思轨单独入账**，不阻塞 slice 交付。小组模式见 [`SQUAD.md`](SQUAD.md)。

---

## 1. 技术债（尚未清理 · 跨版本）

| 债 | 来源 | 现状 | 偿还方向（洋葱） |
|----|------|------|------------------|
| **`lispjit.c` 单 TU 巨石** | v2 模块拆分半途 | 逻辑已拆 `nano_*.c` 但仍 `#include` 进一 TU | slice 2+：独立 `.o` 链接；长期 TU 探针 `verify_tu.sh` 扩面 |
| **Genesis pin 依赖** | v3 4b-3 | 日常零 `cc` 靠复制 `genesis/*`，非 nano-cc 生成全量 slice | slice 6 收紧 + 逐步用 nano-cc 子集替换 pin 字节 |
| **nano-cc 实为模式匹配** | v3.5 slice 0–2 | `strstr`/固定签名 + companion `.lisp` 绕道 | slice 1 真 lexer/IR；slice 2 真 `.o` 发射，删除 companion 依赖 |
| **`add` 路径双轨** | slice 2 | C 样例 + `nano-cc-add.lisp` + `compile-elf64-exe` | 单轨：`parse → lower → emit`，dump hash 与 lisp 路径对齐 |
| **AOT 双参 / VM 用户 `call`** | v2.5 反思 | AOT 有 `(param i64)`×2；VM `OP_CALL_FUNC` 仅 smoke | v3 已 scoped；v4 前不宜在 v3.5 扩面，避免 scope 漂移 |
| **`build-slice-lisp` aarch64 仅 exit-stub** | L3 签收 | min/add profile `emit_aarch64_exit`；**wave-squad-R2** add profile `aarch64-add-emit` + qemu 签收 | 加速 4：扩至 VM/AOT aarch64 codegen（非仅 exit-emit） |
| **`NANO_BUILD_SLICE_CODEGEN=1` 非默认** | slice 3 | 易忘 env，CI 与文档分裂 | slice 6：默认启用 + `NANO_CC_FALLBACK=1` 显式才 host `cc` |
| **aarch64「100%」与 x86 duplicate oracle** | v2.5/v3 | cosmocc 缺失时 payload 表可能 x86 填两行 | 文档化 + 门禁：禁止静默 duplicate（hash 必须 distinct 或 skip） |
| **`pack-ape` Mode A vs bare/stub** | v2.5 | 默认仍 shell 包装 | 产品化在 v4；v3.5 仅记录，不改默认 |
| **loader ≠ 纯 ELF** | v2 反思 | memfd+exec 路径；APE-v2 长期目标分层 | 边界探针 [`../../boundary-probes/`](../../boundary-probes/) 持续记账 |
| **`build_nano_jit.sh` 与 `run.sh` 双矩阵** | v3 | 语义相近但计数独立，cloud 易只跑其一 | 反思轨：CI 模板要求两脚本都跑（已实践） |
| **并行合并冲突热点** | v3/v3.5 | `nano_cc.c`、`run.sh`、`build_nano_jit.sh` | PARALLEL.md 已列；新 sample/新子命令优先减触碰 |
| **Squad 编排依赖 Python + shell** | v3.5 小组 | `tools/squad/*.py`、`squad.sh`、`agent-team` 调 tmux | **v4+**：nano lisp 原生 `run-loop` / `dispatch` / SQLite 或 `.lbin` 状态机，替代 host Python；与「构建图解释器」同轨 |

---

## 2. 设计与实现缺陷（v3.5 当下）

### 2.1 架构

- **目标/证据错位**：mindmap 写「nano-cc 译 `lispjit.c`」，实现仍是 hello/add/build-slice **smoke**；需在 mindmap 标明 **scoped 与终局** 两栏，避免「55% = 能编编译器」误解。
- **C-subset 无契约文件**：缺 machine-readable「支持构造 BNF + 版本号」；`nano-cc parse` dump 应升级为 **golden file**（`add-parse.dump`）而非 grep 关键字。
- **错误码分裂**：parse 用 `add_parse_fail`，compile 用 `unsupported_source`；应统一 reason 枚举并写入 [`ERROR-CODES.md`](ERROR-CODES.md)。
- **无 `#include` / 多 TU**：`link-elf64-exe` 已有多 object，nano-cc 未接入；slice 2 若只做单文件 `.o` 仍不够编 `lispjit.c` 子集。

### 2.3 Squad 工具实践暴露（2026-05-23 · 已部分修复）

| 现象 | 根因 | 状态 |
|------|------|------|
| 派单一轮就停、未到 100% | 无 `supervise` while；`dispatch` 一轮即结束 | 已加 `run-loop` + leader |
| 4 个 Agent 秒退 | 队员自己跑 `supervise`，见 `assess.ready` 即退出 | 已改 follower 只 `await_leader` |
| 审查员从未派单 | `dispatch` 只遍历 `engineer-*` | 已加 `--include-meta` |
| 签收 100% 后 wave 卡死 | `assess` / `dispatch` 遇 ready 即 `halt` | `team_mode` + `resume` |
| 每角色一套 shell/py | `run-role-loop.sh` 与 reviewer 内联 bash 分叉 | 已统一 `squad run-loop --role` |
| `squad verify` 路径双份 | catalog 写 `lab/.../run.sh` 而 `work_root` 已在 `nano-lisp-jit` | 已改为 `run.sh` |
| 门禁与叙事不一致 | `findings` 仍留 warn，auto gate 已 pass | **已清** wave-squad-R3：`reflect` pass + 去 stale warn |
| 并行 verify 竞态 | `run.sh` 与 `build_nano_jit.sh` 同写 `v35-signoff.evidence` / `.build` | **wave-4 暴露**：assess 间歇 85%→100%；应串行 verify 或 evidence 分文件 |
| 签收证据旁路 | `v35-signoff.evidence` 由 run.sh 写入，非 bootstrap 步骤 | **scoped 可接受**；长期应 plan 内 `(evidence …)` |
| `run-loop` 不代劳 claim/done | 只提示 action，实现仍靠 Agent 手跑 CLI | **待办**：Lisp 化后内嵌到 slice runner |
| 多机 Cloud 难共享锁 | SQLite `state.db` 本机 WAL | 预期；远程需单 orchestrator 或导出 JSON 合并 |

### 2.2 实现

- **`nano_cc_parse_main_return` 扫描全文件**：注释里 `main` 曾触发误匹配（已部分修复）；缺词法器，**误报/漏报**风险仍在。
- **`build_slice_use_nano_cc` 白名单**：`nano-cc-hello.c`、`nano-cc-add.c` 硬编码 + 前缀规则；扩展性差，应改为 capability 表或 `nano-cc.can_compile` 探测唯一入口。
- **gen3 仍 pack genesis pin**：`bootstrap-v35-selfhost-gen3` 不通过 nano-cc 编 `lispjit.c`；自举故事在 B 层仍 **半真实**。
- **静态链接 / qemu**：aarch64 exit ELF 需 `-static` 才可靠 qemu；与 genesis aarch64 pin 策略需一致（见 [`AARCH64.md`](AARCH64.md)）。

### 2.3 测试

- **缺「禁止 host cc」的 build 级硬失败**：slice 6 仅有 plan grep，未 hook `cc` 包装或日志审计为 **exit 1**。
- **缺 nano-cc vs host cc 符号表 diff**：slice 2 验收写「对齐符号表」，无自动化 diff 工具。
- **235+ case 运行时长 ~15s**：可接受；但无分层 tag（v35-only / v3 / v2）不利于并行轨快速反馈。

---

## 3. 实质性底层应用（值得用 nano-jit 做实验）

以下均可用现有 **`run-bootstrap-plan` + `.lbin` + AOT/pack** 闭环，且能反哺技术债偿还：

| 实验 | 用工具链什么 | 证明什么 | 首刀样例 |
|------|----------------|----------|----------|
| **A. 构建图解释器** | bootstrap DSL only | B 层编排可版本化、可审计 | 扩 `bootstrap-v35-build-slice` → 多步 DAG + `file-hash` 矩阵 |
| **B. libc resolver 生成器** | `gen-libc-resolve` + `.lisp` | 外部世界（glibc）→ 内部 FFI 表 | 已有 `strlen`；加 `open/read` 两函数 smoke |
| **C. 边界探针驱动** | `run` + `expect` + pack-app | 能力边界文档化、回归 | 接 [`boundary-probes/`](../../boundary-probes/) 最小 3 探针进 `run.sh` |
| **D. 单文件 APE 微工具** | `pack-app` + `run-app` | 无 shell 依赖分发 `.com` | `tools/nano-strlen.com`：内嵌 `strlen.lbin` only |
| **E. 配置 → `.lbin` VM** | compile + run | 数据驱动逻辑，非 C | `samples/config-rules.lisp`：读 u64 常量表分支 |
| **F. nano-cc 自举切片** | nano-cc + build-slice | 替换 genesis 前先 **自举最小 cc** | `nano-cc-hello.c` 已由 gen3 编；下一步 **gen4 只含 nano_cc.c 子集** |
| **G. IR dump 差分 CI** | `nano-cc parse` + `dump` | 前端变更可测 | golden：`nano-cc-add.parse.golden` |
| **H. 确定性重现包** | `file-hash` + self-pack | 供应链：同输入同 hash | gen2/gen3 hash 矩阵进 `build_nano_jit.sh` 失败即红 |

**不建议在 v3.5 做的实验**（scope 漂移）：全量 SQL/WASM 导入、完整 Cosmopolitan libc 克隆、用户态网络栈。

---

## 4. 偿还优先级（并入洋葱）

```text
P0（阻塞「真 nano-cc」）
  └─ slice 1 golden parse + slice 2 relocatable .o（去掉 companion lisp）
P1（阻塞「真零 genesis」）
  └─ slice 6 build 级禁 cc + nano-cc 扩到更大 C 子集
P2（证据与产品化桥梁）
  └─ 实验 C/D/G 进 run.sh 子集；aarch64 build-slice-lisp
P3（架构债，v4）
  └─ loader 纯 ELF、pack 默认 bare、通用 ABI descriptor
```

---

## 5. 与并行轨的关系

| 轨 | 类型 | 本文件作用 |
|----|------|------------|
| A–F | 开发（最多 3 路并发） | 交付 slice；**若引入新债**在本文件 §1 增行 |
| **R** | 反思 | 每 wave 更新 §1–§4 + 推动 ROADMAP mindmap「反思 · v3.5」节点 |

**Wave3+ 开发建议**（与反思一致）：L2 去 companion ∥ L4 Lisp TU link-pack ∥ gen5 零 C 自举。

**North star**：AI 协同自主进化 — 见 [`LISP-ONLY.md`](LISP-ONLY.md) § North star / 加速通道。

---

## 6. 变更日志

| 日期 | 摘要 |
|------|------|
| 2026-05-23 | squad assess auto=100% ready=True |
| 2026-05-23 | 初版：技术债表、缺陷、实验 H、P0–P3；入 ROADMAP mindmap track R |
| 2026-05-23 | **L0 签收**：`LISP-ONLY.md`、gen4、`.lisp` build-slice 路由、`build-slice-lisp` AOT fallback |
| 2026-05-23 | **L1/L3 wave4**：pack x86 Lisp slice；`build-slice-lisp` aarch64；`NANO_V35_CODEGEN_DEFAULT` |
| 2026-05-23 | **gen5 scoped**：双架构 Lisp pack 零 genesis；`run.sh` 249 / `build` 117 pass |
| 2026-05-23 | **wave-squad-R1**：小组模式 [`SQUAD.md`](SQUAD.md)；评估 **~85%**（gen5 scoped on branch）；阻塞 L2 去 companion、L4 多 TU link、aarch64 非 stub、gen5 全功能 Lisp runner；派单 A=`L2-companion`、B=`L4-tu-kickoff` |
| 2026-05-23 | **wave-squad-R2**：L2/L4/aarch64 签收；**aarch64-add-emit**（`build-slice-lisp.mode=aarch64-add-emit` + qemu）；**gen5-via-gen2**（`bootstrap-v35-selfhost-gen5-via-gen2.lisp` + `v35-signoff.evidence`）；squad assess **100%** ready |
| 2026-05-23 | **wave4-selfhost-refresh**：gen2 `build-slice-lisp` add 曾 `parse=fail` — 根因 genesis x86 pin（`638236d6…`）缺 `(module (func …))` 解析；刷新 pin 自 native `nano-lisp-jit`（`76fb499f…`）+ 重跑 gen1/gen2 bootstrap 后 gen2 可编 `nano-jit-slice-add.lisp`；`run.sh` 255 pass |
| 2026-05-23 | **wave4-signoff-bootstrap**：`bootstrap-v35-signoff-evidence.lisp` plan（aarch64-add-emit + x86 min smoke）；`v35-signoff.evidence` 含 `signoff_bootstrap_plan` marker |
| 2026-05-23 | **wave-squad-R3**：wave-4 四角色并行 `run-loop`（reviewer 等 A/B 依赖完成）；§2.3 入账 run-loop 统一、verify 竞态、findings 同步；squad assess **100%** ready；`run.sh` 255 / `build` 119 |
| 2026-05-23 | **wave-4 小队复盘**：指挥长 `run-loop` 持 `standby` 至 A/B `done` 后 `release`；新发现 **genesis x86 pin 过期** 致 gen2 编不了 add（已刷新 pin）；签收证据迁入 `bootstrap-v35-signoff-evidence.lisp`；终局 aarch64 AOT / 全 plan gen2 跑 gen5 仍属 v4 |
| 2026-05-23 | **合并 main**：见 [`POSTMORTEM-SQUAD-V35.md`](POSTMORTEM-SQUAD-V35.md)（设计/实现/测试/协同自问自答 + P0–P4 改进共识） |
| 2026-05-23 | **v3.5-terminal 签收**：`terminal_gates`（gen2×gen5 full、pin=runner）；**v4 kickoff** 小队 `catalog-v4` 全绿 → 见 [`DECISION.md`](DECISION.md)、[`../v4/README.md`](../v4/README.md) |
| 2026-05-23 | **v4 slice-0 kickoff**：`bootstrap-v4-aarch64-aot-plan.lisp` scout（仍 `aarch64-add-emit` stub）；真 VM/AOT aarch64 属 v4 slice — 见 [`AARCH64.md`](AARCH64.md) § v4 slice-0 |
| 2026-05-23 | **wave-practice-R1**：v4 `wave-practice-*` 验证 `--auto-exec` + `verify.lock` + follower `run-loop`（POSTMORTEM Q7–Q8 短程闭环）；assess v4-kickoff **100%** ready |
| 2026-05-23 | **wave2-v4-R**：v4 `run-loop` 三态退出（complete/failed/timeout）+ `auto_done` + `bootstrap-v4-squad-assess.lisp` S0；reviewer `--auto-exec` 259 pass assess **100%** ready |
| 2026-05-23 | **wave3-v4-R**：`v4-slice0-scoped` **scoped 签收** — S0–S3 样本（dispatch/run-loop-once/slice0-evidence）+ `.build/v4-slice0.evidence`；assess **100%** ready；[`v4/README.md`](../v4/README.md) 记 slice-0 完成 |
| 2026-05-23 | **wave4-v4-R**：`v4-slice1-scoped` **scoped 签收** — add7 参数化 aarch64（`bootstrap-v4-slice1-add7.lisp` + `.build/v4-slice1.evidence`）+ `bootstrap-v4-squad-signal.lisp` S1；reviewer `--auto-exec` 267 pass assess **100%** ready；[`v4/README.md`](../v4/README.md) 记 slice-1 完成 |
