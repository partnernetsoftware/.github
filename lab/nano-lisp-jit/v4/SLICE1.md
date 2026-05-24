# v4 slice-1 — aarch64 add 参数化（scoped）

**前置**：[`v4-slice0-scoped`](README.md) 已完成。

## 目标

证明 `build-slice-lisp … aarch64` 对 **非 40+2** 的 add 切片可解析并 `aarch64-add-emit`（仍为 scoped codegen，非 VM/AOT）。

## 交付

| 项 | 路径 |
|----|------|
| 切片源 | `samples/nano-jit-slice-add-7.lisp`（3+4→7） |
| bootstrap | `bootstrap-v4-slice1-add7.lisp` |
| 证据 | `.build/v4-slice1.evidence` |
| S1 样本 | `bootstrap-v4-squad-signal.lisp` |
| 回归 | `run.sh`（含可选 qemu v4 scout / slice1 add7） |

## 非目标

- 全 VM/AOT aarch64（slice-2+）
- 替换 genesis aarch64 pin

## 签收

`catalog-v4` → `signoff.id=v4-slice1-scoped`（保留 slice-0 回归 + slice-1 门禁）。
