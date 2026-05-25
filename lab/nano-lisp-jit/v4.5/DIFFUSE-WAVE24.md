# Wave24 — 发行面继续（代际 full 矩阵 + scoped CI）

在 Wave23 之上：

| 轨 | 内容 |
|----|------|
| W1 | `next-lisp-only.com` → `verify-core` |
| W2 | `next-lisp-only.com` → `selfhost-modules-full`（13/13） |
| W3 | `chain-lo-next.com` → `verify-core` |
| W4 | `v45-scoped-ci.sh` 刷新 |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave24-release-converge.sh
grep v45.v45.release.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

证据：`v45.factory.next_lisp_only_full=1` · `v45.v45.release.100=1`
