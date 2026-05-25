# v4 wave158 — runner-diffuse-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：runner-diffuse-b 继续把 runner 证据向批处理层扩散。
- 每个样本保留可独立运行的最小断言，不依赖手工排序。
- runner tick 关注执行路径、退出码、stdout 三件事。
- 不改 C，只用 Lisp 样本和 catalog 条目扩大覆盖。
- wave158 diffusion 需要能和上一波输出并排比较。
- 收口时记录 tests.pass 增量和失败为零的证据行。
