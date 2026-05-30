# 副agent执行

契约: `onion-tdd.mindmap` → {A} 副agent执行

收到主agent派发(phase, task_node):

```
RED:   write(test) → shell(verify)
         fail→报告:RED_FAIL | 全pass→报告:RED_PASS

GREEN: write(src) → if build: shell(build) → shell(verify)
         全绿→shell(verify_all)→报告:REFACTOR
         失败≤3回退 >3→报告:BLOCKED

REFACTOR: 纯逻辑→去重 | 副作用→接口推外层
          shell(verify_all)→全绿→报告:DONE(+新[→])
          失败→回退
```

铁律: 不改白名单外 | 诊断先行 | skip不算绿灯 | ≤30ops
构建: zig build本地 podman跨平台 | 不感知逻辑节点
