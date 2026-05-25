# v4 wave157 — codegen-lisp-bridge

长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。

§洋葱
- 外层目标：让 codegen-lisp-bridge 以最小可证样本接入 v4 波次。
- 保持 Lisp 侧证据可重复，优先记录输入、桥接产物、输出三点。
- 不碰 C 层，只扩散样本、catalog、runner 可观察痕迹。
- codegen tick 需能说明 bridge 前后 contract 未漂移。
- 证据命名沿用 bootstrap-v4-slice157 与 wave157 前缀。
- 通过 PASS/FAIL 计数与 stdout 片段封住本 slice。
