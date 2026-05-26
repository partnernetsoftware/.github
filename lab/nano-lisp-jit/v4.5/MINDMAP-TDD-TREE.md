# 洋葱 TDD × tree-mind-map 耦合（v4.5 SSOT）

> **活图**：[`mindmap-frontier-v45.json`](mindmap-frontier-v45.json) · **DP**：`tools/mindmap-dp-v45.py`  
> **洋葱真源**：[`ONION-TDD.md`](ONION-TDD.md)

## 扩散循环（广度 × 并发）

```text
主对话：广度设计活图 → DP ready ≤4 槽 → 编排后台 agents 四轨并行实现 → 一次 wave converge → 回写 evidence → 下一圈
```

```text
读 frontier-v45 → DP ready ≤4 槽 → 四轨 bootstrap 并行 → 一次 wave16/17 converge → 回写 evidence
```

```bash
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
```

## 洋葱圈 ↔ mindmap 层

| 洋葱圈 | mindmap layer | v45 节点 |
|--------|---------------|----------|
| 0 seed | L0 gate | `v45-onion-gate` |
| 1 VM | L1 | `v45-mindmap-verify-smoke` |
| 2 AOT/APE | L1 | `v45-mindmap-com-lbin` · `v45-mindmap-ir-exit` |
| 3 build | L2 | `v45-mindmap-onion-tree` |
| 5 DONE | L3 | `v45-goal-mindmap-tree` |

## 证据键（goal 100%）

| 键 | 含义 |
|----|------|
| `v45.mindmap.tree.coupled=1` | 洋葱 + frontier 耦合落地 |
| `v45.mindmap.parallel=4` | 四轨并发绿 |
| `v45.goal.mindmap_tree.100=1` | Wave17 基础树 100% |
| `v45.goal.onion_mindmap.unified.100=1` | **Wave18 全 frontier 14/14** |
| `v45.selfhost.100=1` | Wave19 完全自举 |
| `v45.goal.lisp_selfhost.unified.100=1` | Wave20 洋葱×mindmap×自举 20/20 |
| `v45.goal.onion_tdd_tree_mindmap.100=1` | **Wave21 /goal 总签收 26/26** |
| `v45.mindmap.nodes_done` / `nodes_total` | 活图覆盖率（终局 **26**） |
| `v45.mindmap.codegen.nodes_done` / `nodes_total` | **扩展活图**（Wave27 · 终局 **7**） |
| `v45.mindmap.factory.nodes_done` / `nodes_total` | **工厂物理活图**（Wave28 · **7**） |
| `v45.mindmap.selfhost_deep.nodes_done` / `nodes_total` | **selfhost 深度**（Wave29 · **7**） |
| `v45.mindmap.goal_factory.nodes_done` / `nodes_total` | **/goal×工厂**（Wave30 · **7**） |
| `v45.mindmap.boundary_next.nodes_done` / `nodes_total` | **边界代际**（Wave31 · **7**） |
| `v45.mindmap.rollup.nodes_done` / `nodes_total` | **工厂 rollupy**（Wave32 · **7**） |
| `v45.mindmap.codegen_deep.nodes_done` / `nodes_total` | **codegen 代际**（Wave33 · **7**） |
| `v45.mindmap.runner_codegen.nodes_done` / `nodes_total` | **runner 广面**（Wave34 · **7**） |
| `v45.mindmap.lisp_com_only.nodes_done` / `nodes_total` | **lisp-com-only**（Wave35 · **7**） |
| `v45.mindmap.plan_converge.nodes_done` / `nodes_total` | **plan-converge**（Wave36 · **7**） |
| `v45.mindmap.zero_sh.nodes_done` / `nodes_total` | **zero-sh**（Wave37 · **7**） |
| `v45.mindmap.host_orchestrator.nodes_done` / `nodes_total` | **host-orchestrator**（Wave38 · **7**） |
| `v45.mindmap.runner_physical.nodes_done` / `nodes_total` | **runner-physical**（Wave39 · **7** · 诚实卷） |
| `v45.mindmap.daily_plan.nodes_done` / `nodes_total` | **daily-plan**（Wave40 · **7**） |
| `v45.mindmap.compose_modules.nodes_done` / `nodes_total` | **compose-modules**（Wave41 · **7**） |
| `v45.mindmap.compose_deep.nodes_done` / `nodes_total` | **compose-deep**（Wave42 · **7**） |
| `v45.mindmap.semantic_terminal.nodes_done` / `nodes_total` | **semantic-terminal**（Wave43 · **7**） |
| `v45.mindmap.nano_lisp_com_terminal.nodes_done` / `nodes_total` | **nano-lisp-com-terminal**（Wave44 · **7**） |
| `v45.mindmap.physical_zero_c_honest.nodes_done` / `nodes_total` | **physical-zero-c-honest**（Wave45 · **7**） |
| `v45.mindmap.runner_codegen_terminal.nodes_done` / `nodes_total` | **runner-codegen-terminal**（Wave46 · **7**） |
| `v45.mindmap.zero_host_sh_terminal.nodes_done` / `nodes_total` | **zero-host-sh-terminal**（Wave47 · **7**） |
| `v45.mindmap.lisp_com_bootstrap_terminal.nodes_done` / `nodes_total` | **lisp-com-bootstrap-terminal**（Wave48 · **7**） |
| `v45.mindmap.endgame_honest_rollup.nodes_done` / `nodes_total` | **endgame-honest-rollup**（Wave49 · **7**） |
| `v45.mindmap.lispjit_codegen_dedicated.nodes_done` / `nodes_total` | **lispjit-codegen-dedicated**（Wave50 · **7**） |
| `v45.mindmap.v45_terminal_complete.nodes_done` / `nodes_total` | **v45-terminal-complete**（Wave51 · **7**） |
| `v45.mindmap.physical_zero_cpysh_continue.nodes_done` / `nodes_total` | **physical-zero-cpysh-continue**（Wave52 · **7**） |
| `v45.mindmap.lispjit_154kb_codegen_expand.nodes_done` / `nodes_total` | **lispjit-154kb-codegen-expand**（Wave53 · **7**） |
| `v45.mindmap.ci_plan_only_converge.nodes_done` / `nodes_total` | **ci-plan-only-converge**（Wave54 · **7**） |

前置：`/goal` 26/26 · 扩展活图 **21 张** · **v4.5 目标未达**（`HONEST-REMAINING.md`）

## 编排协议（主对话 × 后台 team）

| 角色 | 职责 |
|------|------|
| **主对话** | 维护洋葱-TDD 活图、广度拆节点、写 DIFFUSE-WAVE*.md、跑 converge、合 evidence |
| **W1–W4 agents** | 各实现一个 `bootstrap-v45-*.lisp`（plan 内零 `.c`/`.sh`/`.py`） |
| **reviewer** | T/G plan + 活图终局树 + rollup |
| **converge** | `v45-waveN-*-converge.sh` 链式上游 + 四轨 host 并行 |

```bash
# 主对话：读活图
NANO_V45_FRONTIER=mindmap-frontier-v45-host-orchestrator.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready

# 后台四轨（squad-parallel 或 agents team）
skills/squad-parallel/scripts/fast-wave.sh lab/nano-lisp-jit/squad/catalog-v45.yaml wave38
```

## 扩展活图（工厂 codegen · Wave27+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave27-codegen-coupled-converge.sh
```

## 扩展活图（工厂物理 · Wave28+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-factory.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave28-factory-physical-continue-converge.sh
```

## 扩展活图（selfhost 深度 · Wave29+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-selfhost-deep.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave29-selfhost-deep-continue-converge.sh
```

## 扩展活图（/goal×工厂 · Wave30+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-goal-factory.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave30-goal-factory-unified-converge.sh
```

## 扩展活图（边界代际 · Wave31+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-boundary-next.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave31-terminal-continue-converge.sh
```

## 扩展活图（工厂 rollupy · Wave32+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-rollup.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave32-factory-rollup-continue-converge.sh
```

## 扩展活图（codegen 代际深潜 · Wave33+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-codegen-deep.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave33-codegen-deep-continue-converge.sh
```

## 扩展活图（lisp-com-only · Wave35+）

目标：`*.lisp` 自举 `nano-lisp.com`，plan 面无 `.c`/`.sh`/`.py`。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-lisp-com-only.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

扩散循环（不变）：

```text
读活图 → DP ready ≤4 → 四轨 bootstrap 并行 → wave 收敛 → evidence → 未 100% 则下一圈
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.lisp_com_only.nodes_done` / `nodes_total` | Wave35 · **7** |
| `v45.v45.lisp_com_only_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE35.md`](DIFFUSE-WAVE35.md)

## 扩展活图（plan-converge · Wave36+）

目标：plan 内收敛 + 默认洋葱 + `nano-lisp.com` 矩阵。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-plan-converge.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.plan_converge.nodes_done` / `nodes_total` | Wave36 · **7** |
| `v45.v45.plan_converge_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE36.md`](DIFFUSE-WAVE36.md)

## 扩展活图（zero-sh · Wave37+）

目标：plan 面零 `.sh` 步骤编排 + `nano-lisp.com` 产物名统一。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-zero-sh.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.zero_sh.nodes_done` / `nodes_total` | Wave37 · **7** |
| `v45.v45.zero_sh_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE37.md`](DIFFUSE-WAVE37.md)

## 扩展活图（host-orchestrator · Wave38+）

目标：用户日常入口 plan-only；host 外层 `.sh` 退 CI。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-host-orchestrator.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.host_orchestrator.nodes_done` / `nodes_total` | Wave38 · **7** |
| `v45.v45.host_orchestrator_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE38.md`](DIFFUSE-WAVE38.md)

## 扩展活图（runner-physical · Wave39+ · 诚实卷）

目标：154KB runner 全 Lisp codegen 深潜（≠ 发行面终局 100%）。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-runner-physical.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.runner_physical.nodes_done` / `nodes_total` | Wave39 · **7** |
| `v45.v45.runner_physical_continue.100=1` | 物理卷签收 |

见 [`DIFFUSE-WAVE39.md`](DIFFUSE-WAVE39.md)

## 扩展活图（daily-plan · Wave40+）

目标：用户日常 `$COM run-bootstrap-plan converge-daily-plan.lisp`。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-daily-plan.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.daily_plan.nodes_done` / `nodes_total` | Wave40 · **7** |
| `v45.v45.daily_plan_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE40.md`](DIFFUSE-WAVE40.md)

## 扩展活图（compose-modules · Wave41+）

目标：模块 07–12 全量 + compose-Nlink plan-only 深潜。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-compose-modules.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.compose_modules.nodes_done` / `nodes_total` | Wave41 · **7** |
| `v45.v45.compose_modules_continue.100=1` | 深潜签收 |

见 [`DIFFUSE-WAVE41.md`](DIFFUSE-WAVE41.md)

## 扩展活图（compose-deep · Wave42+）

目标：compose 9/15link plan-only + daily 并入。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-compose-deep.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.compose_deep.nodes_done` / `nodes_total` | Wave42 · **7** |
| `v45.v45.compose_deep_continue.100=1` | 深潜签收 |

见 [`DIFFUSE-WAVE42.md`](DIFFUSE-WAVE42.md)

## 扩展活图（semantic-terminal · Wave43+）

目标：13 模块 VM 全绿 + semantic-terminal 证明 + daily 升维。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-semantic-terminal.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.semantic_terminal.nodes_done` / `nodes_total` | Wave43 · **7** |
| `v45.v45.semantic_terminal_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE43.md`](DIFFUSE-WAVE43.md)

## 扩展活图（nano-lisp-com-terminal · Wave44+）

目标：`nano-lisp.com` 代际 semantic + 终局 daily 入口 + 诚实零 C 卷。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-nano-lisp-com-terminal.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.nano_lisp_com_terminal.nodes_done` / `nodes_total` | Wave44 · **7** |
| `v45.v45.nano_lisp_com_terminal_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE44.md`](DIFFUSE-WAVE44.md)

## 扩展活图（physical-zero-c-honest · Wave45+）

目标：154KB runner codegen 深探 + archive 诚实卷（**独立键**，≠ 全仓 zero_c DONE）。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-physical-zero-c-honest.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.physical_zero_c_honest.nodes_done` / `nodes_total` | Wave45 · **7** |
| `v45.v45.physical_zero_c_honest_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE45.md`](DIFFUSE-WAVE45.md)

## 扩展活图（runner-codegen-terminal · Wave46+）

目标：15link 全链 codegen + host 编排 plan-only 深链。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-runner-codegen-terminal.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.runner_codegen_terminal.nodes_done` / `nodes_total` | Wave46 · **7** |
| `v45.v45.runner_codegen_terminal_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE46.md`](DIFFUSE-WAVE46.md)

## 扩展活图（zero-host-sh-terminal · Wave47+）

目标：用户路径 plan-only；host `.sh` 仅 CI/维护。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-zero-host-sh-terminal.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.zero_host_sh_terminal.nodes_done` / `nodes_total` | Wave47 · **7** |
| `v45.v45.zero_host_sh_terminal_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE47.md`](DIFFUSE-WAVE47.md)

## 扩展活图（lisp-com-bootstrap-terminal · Wave48+）

目标：`nano-lisp.com` 自举终局 + 工厂物理诚实卷闭合（**卷闭合 ≠ 154KB DONE**）。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-lisp-com-bootstrap-terminal.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.lisp_com_bootstrap_terminal.nodes_done` / `nodes_total` | Wave48 · **7** |
| `v45.v45.lisp_com_bootstrap_terminal_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE48.md`](DIFFUSE-WAVE48.md)

## 扩展活图（endgame-honest-rollup · Wave49+）

目标：Wave44–48 键 rollup + 诚实终局锚（**≠ 154KB DONE**）。

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-endgame-honest-rollup.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.endgame_honest_rollup.nodes_done` / `nodes_total` | Wave49 · **7** |
| `v45.v45.endgame_honest_rollup_continue.100=1` | 规划签收 |

见 [`DIFFUSE-WAVE49.md`](DIFFUSE-WAVE49.md)

## 扩展活图（v45-terminal-complete · Wave51 · 扩展 rollup）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-v45-terminal-complete.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

| 键 | 活图 |
|----|------|
| `v45.v45.v45_terminal_complete.100=1` | **扩展活图 Wave34–51 rollup**（≠ v4.5 目标达成） |
| `v45.mindmap.v45_terminal_complete.nodes_done` / `nodes_total` | Wave51 · **7** |

见 [`DIFFUSE-WAVE51.md`](DIFFUSE-WAVE51.md)

## 扩展活图（physical-zero-cpysh-continue · Wave52 · 物理续推）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-physical-zero-cpysh-continue.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

| 键 | 活图 |
|----|------|
| `v45.v45.physical_zero_cpysh_continue.100=1` | **零 cpysh 物理续推** |
| `v45.mindmap.physical_zero_cpysh_continue.nodes_done` / `nodes_total` | Wave52 · **7** |

见 [`DIFFUSE-WAVE52.md`](DIFFUSE-WAVE52.md)

## 扩展活图（lispjit-154kb-codegen-expand · Wave53 · 消 C 主路径）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-lispjit-154kb-codegen-expand.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

| 键 | 活图 |
|----|------|
| `v45.v45.lispjit_154kb_codegen_continue.100=1` | **154KB 扩面续推** |
| `v45.mindmap.lispjit_154kb_codegen_expand.nodes_done` / `nodes_total` | Wave53 · **7** |

见 [`DIFFUSE-WAVE53.md`](DIFFUSE-WAVE53.md)

## 扩展活图（ci-plan-only-converge · Wave54 · 消 sh）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-ci-plan-only-converge.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
```

| 键 | 活图 |
|----|------|
| `v45.v45.ci_plan_only_converge_continue.100=1` | **plan-only 收敛** |
| `v45.mindmap.ci_plan_only_converge.nodes_done` / `nodes_total` | Wave54 · **7** |

见 [`DIFFUSE-WAVE54.md`](DIFFUSE-WAVE54.md)

## 扩展活图（runner 广面 · Wave34+）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-runner-codegen.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh
```

| 键 | 活图 |
|----|------|
| `v45.mindmap.runner_codegen.nodes_done` / `nodes_total` | **7** · `mindmap-frontier-v45-runner-codegen.json` |
| `v45.v45.runner_codegen_continue.100=1` | Wave34 |

## 日常（/goal 终局）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh
python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py stats
grep v45.goal.onion_tdd_tree_mindmap.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## 合并 main（2026-05-25）

进度：[`EVAL.md`](EVAL.md) · 反思：[`REFLECTION.md`](REFLECTION.md) §二十二 · 清洗：[`CLEANUP.md`](CLEANUP.md)
