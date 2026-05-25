# v4 归档区

**活跃 v4 文档**仍在 [`../../v4/`](../../v4/)（约 15 个 SSOT 文件）。

## 子目录

| 路径 | 内容 | 数量 |
|------|------|------|
| [`slices/`](slices/) | 历史波次 `SLICE*.md`（run.sh / catalog 仍引用） | 244 |
| [`factory-docs/`](factory-docs/) | 长程队列、扩散工作流、dev-agents 说明 | 3 |

## 为何归档

- `v4/` 根目录只保留 **决策 / 进度 / mindmap / 终局** 真源
- SLICE 文档是 wave 记账，不是发行面；路径统一为 `archive/v4/slices/SLICE{N}.md`

## 勿删

`run.sh` 与大量 `bootstrap-v4-slice*-evidence.lisp` 仍 `file-size` 或 `test -f` 这些路径。
