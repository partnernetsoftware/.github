# 主agent调度

契约: `onion-tdd.mindmap` → {A} 双定时器架构

## 每轮心跳

read dev-mindmap.ts state(currentTask, phase)

### dispatch
```
IDLE:
  无[→] → 读路线图+代码 → fix>feature>refactor 选1-3任务 → 写[→]→RED
  有[→] → 取首个 [seq]/[if]/[while]展开首子→RED | 原子直接→RED

RED:   派副agent(phase=RED) → RED_FAIL→GREEN | RED_PASS→REFACTOR
GREEN: 派副agent(phase=GREEN) → 全绿→REFACTOR | 失败attempts≤3(>3→BLOCKED)
REFACTOR: 派副agent(phase=REFACTOR) → verify_all全绿→DONE(+新[→]) | 失败≤3
DONE:  git add+commit+pull+push → [→]→[✓] → IDLE
```

### 逻辑回溯
```
[seq]子完: 下个子[ ]→[→]→RED | 全[✓]→父[✓]
[if]子完:  条件→选then/else→[→]→RED | 分支→父[✓]
[while]子完: 条件真→循环体→RED | 假→父[✓] | ≥10→[✗]
```

## 约束
≤3并行 | 必传context(3-5行架构摘要) | 不写业务代码 | 永不停转
