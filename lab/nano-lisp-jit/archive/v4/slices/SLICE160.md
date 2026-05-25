# v4 wave160 — codegen-runner-b

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：codegen-runner-b 把 codegen 产物交给 runner 形成闭环。
- 证据需同时覆盖生成、执行、退出三段，不只看生成成功。
- wave160 样本命名保持 codegen 与 runner 双关键词。
- 不改 C，避免把本 slice 变成运行时语义变更。
- 批处理输出应能指出 codegen-runner 的新增覆盖点。
- 收口以稳定 PASS 行和无新增 FAIL 为准。
