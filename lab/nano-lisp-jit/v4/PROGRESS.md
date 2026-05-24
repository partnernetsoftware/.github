# v4 终局进度

| 维度 | 粗估 |
|------|------|
| 自举 | **~95%** |
| 终局整体 | **~95%** |

**phase5（regenesis 传播 · gen19–21）**
- `NANO_REGENESIS=1` 重编 genesis + `nano-jit.com`（新 runner 含 `selfhost-reuse`）
- **nano-jit.com** → gen19（reuse）→ **gen19.com** → gen20（reuse）→ **gen20.com** → terminal-edge gen21

证据（`.build/v4-zero-host-bootstrap.evidence`）：
- `zero.host.reuse_on_com=1`
- `zero.host.regenesis_propagated=1`
- `zero.host.terminal_on_gen20_com=1`
- `zero.host.chain.complete=1`

**scoped 100% 验收**：gen2→gen21 全链 gate + 摸到边 terminal 在 **gen20.com** 上复现。

**真·100% 未宣称**：`lispjit.c` 仍非「Lisp 源码编出」；reuse 为上一代 slice 拷贝。
