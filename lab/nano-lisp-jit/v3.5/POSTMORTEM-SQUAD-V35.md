# v3.5 + Squad 合并后复盘（自问自答）

> 合并目标：`main` @ wave-4 结束。本文档归纳 **设计 / 实现 / 测试 / 协同** 问题与改进共识，供 v4 与 Lisp 原生编排参考。

---

## 1. 设计层

### Q1：签收 100% 是否等于「Lisp-only 终局」？

**答：否。** 当前 `catalog.signoff` 验收的是 **scoped 证据**（gen5 双架构 pack、aarch64-add-emit、gen5-via-gen2），不是「全 VM/AOT aarch64」「gen2 跑完整 gen5 且无 pin 风险」。  
**改进**：signoff 拆两档——`v3.5-scoped`（现有）与 `v3.5-terminal`（终局门禁）；mindmap 与 gate 命名禁止用「real」暗示已完成终局。

### Q2：签收证据放在 `run.sh` 还是 bootstrap plan？

**答：plan 为真相源，run.sh 为聚合器。** wave-4 已加 `bootstrap-v35-signoff-evidence.lisp`，但 `v35-signoff.evidence` 仍可由 run.sh 追加，存在双写。  
**改进**：门禁只读 plan 日志或单一 `evidence` 文件；run.sh 仅 `grep` 汇总，不再 `echo >>` 竞争写入。

### Q3：Squad 协议应稳定什么、替换什么？

**答：稳定**——`catalog` 任务图、`signals.supervisor` 三态出口、`run-loop --role`、leader/follower 分离。  
**替换**——Python/SQLite/shell/tmux（见 PROTOCOL §演进笔记）。v4 用 bootstrap 子命令实现同等状态机，而非再叠 host 脚本。

### Q4：genesis pin 在架构里是什么角色？

**答：救生艇，非进化产物。** wave-4 证明 **过期 pin 会静默拖垮 gen2**（add slice parse=fail），与「自举链可编 add」叙事冲突。  
**改进**：pin 入 `manifest` + hash 门禁；gen1/gen2 重建纳入 `run.sh` 固定 wave；文档写明「改 parser 后必须 regenesis pin」。

---

## 2. 实现层

### Q5：aarch64-add-emit 算不算「真实 codegen」？

**答：相对 exit-stub 进了一步，仍是 scoped。** 硬编码 `movz/add/svc` 路径，未走 VM/AOT。gate 名 `aarch64-real-codegen` 易误导。  
**改进**：重命名为 `aarch64-add-emit-scoped`；终局 gate 要求 `build-slice-lisp.mode=compile-*` 且 qemu 对非固定立即数用例通过。

### Q6：gen2 为何一度不能编 `nano-jit-slice-add.lisp`？

**答：gen2-slice 来自旧 genesis x86 pin，非当前树编译产物。** 刷新 pin + 重跑 gen1/gen2 bootstrap 后恢复。  
**改进**：`build_nano_jit.sh` 在 `NANO_REGENESIS=1` 或 parser 变更时自动刷新 pin；CI 比对 pin hash 与 native runner hash。

### Q7：`run-loop` 为何仍不够「自主」？

**答：只决策不执行。** `member_tick` 返回 `claim/work`，claim/verify/done 仍靠外部 Agent 手敲。  
**改进**：短期在 `run-loop` 内嵌可选 `--auto-exec`（调 verify、模板化 done）；长期由 Lisp runner 执行工单步骤。

---

## 3. 测试与门禁

### Q8：为何 assess 会在 85% 与 100% 间跳变？

**答：并行竞态。** `run.sh` 与 `squad verify`（触发 build）同写 `.build/results.txt`、`v35-signoff.evidence`。  
**改进**：`verify.commands` 串行；evidence 按 gate 分文件；assess 前 `flock` 或 commander 独占 verify。

### Q9：`run.sh` 与 `build_nano_jit.sh` 双矩阵够吗？

**答：对 v3.5 够，对 cloud 易漏。** squad 曾只跑其一即宣称通过。  
**改进**：catalog.verify 强制两者；assess 同时读 `tests.pass` 与 `build.pass`（已做）；CI 模板写死双跑。

### Q10：缺少哪类测试？

| 缺口 | 改进 |
|------|------|
| squad 本身无单元测试 | `pytest` 测 `supervisor.team_ready_to_release`、`member_tick` 状态机 |
| 无 leader/follower 时序测试 | 假 clock + 内存 SQLite 跑 4 角色单进程集成测 |
| aarch64 仅 exit 42 | 增加非 42 立即数用例 + golden code bytes |
| gen2×gen5 无回归 | 固定 case：`gen2 run-bootstrap-plan gen5.lisp` |

---

## 4. 协同（Squad 实践）

### Q11：为何 Agent 会「秒退」？

**答：队员误用 `supervise` 或把 `assess.ready` 当解散信号。**  
**改进**：已用 `team_mode` + `await_leader`；文档与 Agent 提示词只写 `run-loop --role`。

### Q12：审查员为何长期派不到单？

**答：`dispatch` 最初只填 `engineer-*`。**  
**改进**：`--include-meta` + supervise tick 派 reviewer；catalog 里 meta 任务独立 `assign_role`。

### Q13：多 Cloud Agent 如何共队？

**答：当前不行——SQLite WAL 本机单写。**  
**改进**：单 commander 进程持库；队员只读 JSON 导出 + `signal` 经 HTTP/文件队列；或 v4 单进程 Lisp 调度器。

---

## 5. 改进路线图（共识）

```text
P0  命名与文档：scoped vs terminal；gate 改名；REFLECTION/findings 与 assess 同步
P1  证据单源：bootstrap evidence plan；取消 run.sh 竞争写 evidence
P1  pin 契约：parser 变更 → regenesis pin；gen2×gen5 回归 case
P2  squad 测试：状态机 pytest；verify 串行
P3  run-loop --auto-exec 或 Lisp 编排替代 Python
P4  aarch64 VM/AOT 真路径；signoff v3.5-terminal
```

---

## 6. 合并结论

- **main** 已纳入：v3.5 Lisp-only 线、gen5、aarch64-add-emit、L4 TU link、squad `run-loop`、wave-4 genesis pin 修复、signoff bootstrap plan。
- **可对外说**：v3.5 **scoped 签收** 完成；**自主进化终局** 仍在 v4（真 aarch64、零 pin 日常、Lisp 原生编排）。

---

*生成：wave-4 合并 main 后 · 与 [`REFLECTION.md`](REFLECTION.md) §2.3、[`squad/PROTOCOL.md`](../squad/PROTOCOL.md) 互补*
