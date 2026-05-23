---
name: squad-parallel
description: >-
  Runs v3.5/v4 parallel squad work via tools/squad (four fixed roles, one process
  per role). Use when the user asks for 并行小组、小队、agent-team、squad 实践、wave 推进,
  or catalog-v4 dispatch — the agent must execute squad itself, not hand scripts to the user.
paths:
  - "tools/squad/**"
  - "lab/nano-lisp-jit/squad/**"
  - "lab/nano-lisp-jit/v4/**"
  - "skills/squad-parallel/**"
---

# Squad parallel（并行角色小队）

## 成熟度

本技能对应的方法论已在 **nano-lisp-jit v4** 多波（wave8–wave13）实跑验证：`agent-team` + `--auto-exec --auto-done` + `catalog-v4.yaml` 签收闭环。适用于 **host Python squad** 阶段；Lisp 原生 `run-loop` 替换 host 层属后续 slice，协议字段不变。

## 铁律（给 Agent）

1. **你必须亲自跑 squad**，完成 `resume` → `dispatch` → `agent-team`（或四路 `run-loop`），并把代码/证据合入 `main`。禁止只把 bash 命令贴给用户执行。
2. **一进程一角色**：commander / engineer-a / engineer-b / reviewer 各一条 `run-loop`，禁止每角色一套自定义 shell/py。
3. **队员禁止 `supervise`**；禁止因 `assess.ready` 自行退出；跟 `signals.supervisor` 三态走。
4. **每波先 `resume`**（`wave=1`、`epoch++`），再 `dispatch --force --include-meta`。
5. **不要提交** `.squad/*.db`、`verify.lock`、本地漂移的 `state.json`；可提交 `sync-md` 生成的 `v4/SQUAD.md`。
6. **`auto-exec` 走 `verify --quick`**：catalog 第一条应为 **`squad/verify-v4-fast.sh`**（~30s）；全量 `run.sh` 标 `optional: true`，仅 `squad verify`（无 `--quick`）或签收前手跑。
7. **签收前必跑一次全量 `run.sh`** 写 `.build/results.txt`，再 `assess`（assess 不跑 verify）。

## 标准波次（Agent 执行）

从仓库根 `/workspace`（或项目根）：

```bash
# 推荐：技能附带脚本（传 catalog 相对路径）
skills/squad-parallel/scripts/run-wave.sh lab/nano-lisp-jit/squad/catalog-v4.yaml wave17
skills/squad-parallel/scripts/poll-tasks.sh lab/nano-lisp-jit/squad/catalog-v4.yaml wave17
# 开发环：lab/nano-lisp-jit/squad/verify-v4-fast.sh  →  签收前：cd lab/nano-lisp-jit && bash run.sh
```

或等价手工：

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume --reason <wave>
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team --auto-exec --auto-done --max-iter 40 --poll-interval 4
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml sync-md
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml assess
```

## 并行分工（catalog 任务）

| 角色 | 职责 |
|------|------|
| **commander** | `supervise` 循环：assess → dispatch → `signals.supervisor`；`team_ready` 时 `complete` |
| **engineer-a / engineer-b** | `member_tick`：claim → verify → done（`touch_paths` 锁） |
| **reviewer** | 依赖型 meta 任务、`sync-md`、assess 签收 |

开新波前在 `catalog-v4.yaml` 增加 `waveN-*` 任务与 `signoff.id` 门禁；实现落在工程师 `touch_paths` 内。

## 实现与签收顺序

1. 在 feature 分支写代码 + `verify-v4-fast.sh` 迭代 + evidence 样本。
2. **签收前** 一次全量 `bash run.sh`（更新 `results.txt`）。
3. **再** `run-wave.sh` 启动四角色（队员 verify 仅 fast）；轮询至本波 `wave*-v4-*` 为 `done`。
4. `sync-md`、`assess` 100% → `git commit` → `push` → 合入 `main`。
5. 更新 `v4/REFLECTION.md` 变更日志一行（可选）。

## 指挥长 / 门禁

- signoff 100% 但仍有 wave 任务：`supervise --once` 可能 `outcome=continue`（正常）；全任务 terminal 后才是 `complete`。
- `run.sh` 的 commander smoke 放在 `run_end_summary` **之后**，否则 `tests.pass` 未写入会导致 assess 暂时 &lt;100%。

## 参考

- 工具 README：`tools/squad/README.md`
- 协议：`lab/nano-lisp-jit/squad/PROTOCOL.md`
- 实践反思：`lab/nano-lisp-jit/v4/REFLECTION.md` §2
- 排障表：`references/troubleshooting.md`
- 协议摘要：`references/protocol-summary.md`
