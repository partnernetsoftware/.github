# Squad 协议：状态机 + CLI（替代 .md 派单）

## 问题（.md 耦合）

| .md 派单 | 后果 |
|----------|------|
| 多人改 `SQUAD.md` | 冲突、状态过期 |
| 无锁 | A/B 同改 `nano_cc.c` |
| 100% 靠 prose | 指挥长/审查员标准不一致 |
| AI 读长文 | 信号噪声大 |

## 三层耦合（推荐）

```text
catalog.yaml     ← 契约（任务定义、签收门禁、touch_paths）  【少改、review】
.squad/state.json ← 运行时真相（派单、claim、done、assess） 【常改、可 commit】
*.md              ← 叙事/洋葱图（由 CLI 生成段落，不手改派单板）
```

## 角色微工作流

```bash
cd lab/nano-lisp-jit

# 查看本角色步骤清单（不执行）
python3 squad/squad_cli.py role run commander
python3 squad/squad_cli.py role run reviewer
python3 squad/squad_cli.py role run engineer --role A
```

### 审查员 R

1. `squad verify`（或 `--quick` 仅 run.sh）
2. `squad assess` → 写入 `state.last_assess`
3. `squad reflect --gate <id> --status warn --note "..."`（manual 门禁）
4. `squad sync-md --targets reflection-changelog`

### 指挥长 C

1. `squad assess` → exit 0 则 `squad halt`
2. 否则 `squad dispatch --max-tasks 2`
3. `squad sync-md --targets squad-board`
4. 通知 A/B：`squad status --role A`

### 工程兵 A|B

1. `squad status --role A` → 看到 `assignments.A`
2. `squad claim A <task_id>`
3. 按 `catalog.tasks.<id>.touch_paths` 改代码 + 洋葱验收
4. `squad verify` → `squad done A <task_id> --commit $(git rev-parse --short HEAD) --run-pass 250`
5. 指挥长再跑 `squad assess`

## 入口

```bash
./squad/squad.sh assess
./squad/squad.sh dispatch
```

## AI / Cloud Agent 约定

- **禁止**直接改 `<!-- SQUAD_STATE_BEGIN -->` 块；只改 `state.json` 后 `sync-md`
- **派单**只认 `state.assignments` 与 `catalog.yaml`
- **完成**必须 `squad done` + `verify` 通过，否则 assess 不涨
