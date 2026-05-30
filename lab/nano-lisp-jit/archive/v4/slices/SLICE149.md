# v4 wave149 — emit-diffuse-a

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

## §emit profile v2-diffuse

- `emit_aarch64_add_exit_file` 成功路径追加 `aarch64.emit.profile=add-exit-v2-diffuse`。

## §洋葱

- 圈：Plan 外圈先扩散 wave149 骨架，Codegen 推进 codegen tick，Runner 保持 emit tick 可跑。
- TDD：扩散骨架 → cc 填肉 → 一次 gate。
- 工作流：[`DIFFUSE-WORKFLOW.md`](../DIFFUSE-WORKFLOW.md)。
