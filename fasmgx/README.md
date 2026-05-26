# fasmgx — 工厂物理 / codegen 续推卷

> **定位**：与 v4.5 **/goal 26/26** 分离的「工厂 ASM + codegen 扩散」SSOT。  
> **真源耦合**：[`lab/nano-lisp-jit/v4.5/`](../lab/nano-lisp-jit/v4.5/) · 洋葱 TDD · tree-mind-map。

## 命名

| 字母 | 含义 |
|------|------|
| **F** | Factory（`run.sh` · `archive/runner` · 代际 com） |
| **ASM** | 机器码 / VM emit / slice 探针轨 |
| **GX** | 代际扩散（selfhost-next · codegen 扩面） |

## 目录

| 文件 | 用途 |
|------|------|
| [`REFLECTION.md`](REFLECTION.md) | Wave25–33 反思 · 误读清单 |
| [`CLEANUP.md`](CLEANUP.md) | 物理清单 · 不归档项 |
| [`NEXT-ONION-TDD-TREE.md`](NEXT-ONION-TDD-TREE.md) | **Wave34+** 洋葱×活图下一步 |
| [`mindmap-frontier-runner-codegen.json`](mindmap-frontier-runner-codegen.json) | 第九张扩展活图（7 节点 · **ready**） |

## 日常（不改 /goal 口径）

```bash
# 当前默认收敛（Wave33）
bash lab/nano-lisp-jit/scripts/v45-wave33-codegen-deep-continue-converge.sh

# Wave34 runner 广面（默认）
bash lab/nano-lisp-jit/scripts/v45-wave34-runner-codegen-continue-converge.sh

# 清洗 + /goal 复核
bash lab/nano-lisp-jit/scripts/v45-cleanup-reflect.sh
```

## 签收分层（勿混）

| 卷 | 节点 | 键示例 |
|----|------|--------|
| /goal 总签收 | **26** | `v45.goal.onion_tdd_tree_mindmap.100=1` |
| v4.5 扩展活图 ×8 | 各 **7** | `codegen_deep_continue.100` 等 |
| **fasmgx Wave34** | **7** | `v45.v45.runner_codegen_continue.100` |
