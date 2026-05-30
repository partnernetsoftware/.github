# v4 wave180 — onion-emit-c

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：onion-emit-c 将 emit 证据推进到第三段收束。
- emit tick 关注 emitted bytes、profile/stdout 标记、退出路径三类证据。
- 不扩大指令覆盖，只把已存在 emit contract 纳入洋葱段批验证。
- 新增样本要能和 codegen、runner tick 的输出并排比对。
- wave180 证据命名沿用 bootstrap-v4-slice180 与 wave180 前缀。
- 收口以 emit 片段稳定、全批 PASS、无新增 FAIL 为准。
