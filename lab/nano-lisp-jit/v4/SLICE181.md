# v4 wave181 — onion-runner-c

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：onion-runner-c 将 runner 证据推进到第三段收束。
- runner tick 关注执行入口、退出码、stdout 断言三件事。
- 样本必须可批量运行，也要能单独复现，避免只在全批里成立。
- catalog 与 wave index 需要标出 runner-c 与前序 runner-a/b 的连续性。
- 不改 C，只扩散 runner 可观察痕迹和批处理证据。
- 收口以全批 PASS、tests.pass 增量、失败归因为零为准。
