# nano-lisp-jit v2.5 — v2 retrospective hardening

v2 以 **100%（scoped）** 签收；v2.5 把 scoped 与 mindmap 之间的缺口变成**可重复证据**，不扩 v3 语义。

## 为何有 v2.5

| 类别 | 核心发现 |
|------|----------|
| 设计 | scoped 签收掩盖 VM 参数、双 arch self-pack 空洞、loader=exec 与「纯 ELF loader」表述需分层 |
| 实现 | 类型仍在 `lispjit.c`；include 顺序脆弱；native 无 aarch64 时 self-pack 整段跳过 |
| 测试 | `build_nano_jit.sh` 未进默认 `run.sh`；skip 分散；native 未测 pack→inspect→run 链 |

完整洋葱 TDD mindmap 见 [`../ROADMAP.md`](../ROADMAP.md)（`v2.5: v2 反思收口` 节点）。

## 当前切片

1. **slice 0** — `run.sh`：`build-nano-jit-native-smoke`
2. **slice 1** — `build_nano_jit.sh`：cosmocc 缺失时 x86-only self-pack oracle
3. **slice 2** — `nano_util.c`：`parse_size_arg`
4. **slice 3** — VM 与 AOT 参数路径对齐（待开工）

## 证据命令

```bash
bash lab/nano-lisp-jit/run.sh
NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
