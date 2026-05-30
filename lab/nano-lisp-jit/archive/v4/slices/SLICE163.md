# v4 wave163 — codegen-terminal-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：codegen-terminal-b 为 codegen 链路补上终端可见证据。
- 终端层关注最终 stdout、退出码、样本名三者是否一致。
- diffusion 不引入新语义，只把已有 codegen 行为推到边界。
- 不改 C，避免终端证据和运行时变更混在一起。
- wave163 条目应能被单独重跑并定位到同名样本。
- 封口条件是终端 tick 稳定输出且批处理全绿。
