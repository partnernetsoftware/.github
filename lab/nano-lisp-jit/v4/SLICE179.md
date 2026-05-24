# v4 wave179 — onion-lisp-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：onion-lisp-b 继续把 Lisp 侧样本作为洋葱段的可读证据。
- 每个样本保留最小输入、断言、stdout 标记，避免把测试意图藏进 runner。
- Lisp 层只扩散可证明行为，不引入新的 C 侧依赖。
- catalog 条目需要能说明样本属于 onion-lisp-b 而非普通 smoke。
- wave179 与前序 onion 段并排时，应能覆盖计划到执行的中间层。
- 收口以样本可独立运行、批处理 PASS、tests.pass 增量为准。
