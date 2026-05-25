# v4 wave161 — emit-ir-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：emit-ir-b 将 emit 结果与 IR 形态并排留证。
- 样本要能说明 IR 片段如何落到 emit 可观察字节或文本。
- catalog 中保持 slice161 独立条目，避免被后续 close 波次吞掉。
- 不改 C，仅扩散 IR/emit 证据与执行索引。
- emit tick 需要带上足够上下文判断 contract 未破坏。
- 以同一 runner 命令可重复通过作为封口。
