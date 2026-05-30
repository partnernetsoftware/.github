# v4 wave182 — onion-tdd-milestone

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：onion-tdd-milestone 汇总 175–182 的洋葱段闭环。
- SLICE182 必须明确标记 onion-tdd-milestone，不只是普通 wave 追加。
- 里程碑证据要并排覆盖 plan、IR、Lisp、codegen、emit、runner、gates。
- TDD 顺序以先最小断言、再 cc 填肉、最后一次 gate 收口为准。
- 不改 C，milestone 只收敛样本、catalog、wave index 与批处理证据。
- 收口以全批 PASS、tests.pass 增量、无新增 FAIL 三项为准。
