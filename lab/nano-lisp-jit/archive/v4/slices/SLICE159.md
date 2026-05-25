# v4 wave159 — emit-diffuse-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：emit-diffuse-b 把 emit 侧字节与文本证据继续铺开。
- 样本应暴露 emit tick 的可观察输出，而不是隐藏在聚合日志里。
- catalog 条目保持单 slice 可追踪，方便回退到 wave159。
- 不改 C，所有变化落在 Lisp 证据和批处理索引。
- diffusion 文件需说明 emit contract 与前波保持一致。
- 以 runner 可重复执行作为本层洋葱的封口条件。
