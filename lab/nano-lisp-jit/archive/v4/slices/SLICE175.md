# v4 wave175 — onion-codegen-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：onion-codegen-b 继续把 codegen 证据从单点 tick 推向洋葱段覆盖。
- 保持 C 层最小扰动，优先用 Lisp 样本、catalog、wave index 记录可重复路径。
- codegen tick 需要说明输入形状、生成边界、stdout 证据三点未漂移。
- 和 166–174 的 onion-a/b 链路对齐，避免只追加计数不追加 contract。
- 证据命名沿用 bootstrap-v4-slice175 与 wave175 前缀。
- 收口以全批 PASS、tests.pass 增量、无新增 FAIL 为准。
