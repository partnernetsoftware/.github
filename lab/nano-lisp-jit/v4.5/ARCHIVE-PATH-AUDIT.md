# bootstrap plan archive/c 路径审计（Wave70 SSOT）

> 生成：`v45-wave70-daily-zero-archive-audit-converge.sh` · 活图：[`mindmap-frontier-v45-daily-zero-archive-audit.json`](mindmap-frontier-v45-daily-zero-archive-audit.json)

## 活跃 daily 链（用户路径 · 须零 archive/c 步骤）

| plan | archive/c 步骤 | 状态 |
|------|----------------|------|
| `converge-daily-v45-zero-archive-audit-terminal.lisp` | 0 | ✅ Wave70 默认 |
| `converge-daily-v45-factory-honest-terminal.lisp` | 0 | ✅ 仅 lisp/core + modules |
| `converge-daily-v45-lisp-selfhost-bootstrap-chain.lisp` | 0 | ✅ |
| `converge-daily-v45-zero-archive-path.lisp` | 0 | ✅ |
| `converge-daily-v45-honest-cleanup.lisp` | 0 | ✅ 历史清理轨 |

## 活跃 prove 链（Wave70 修复）

| plan | 变更 |
|------|------|
| `lisp-selfhost-bootstrap-chain-prove.lisp` | `nano-jit-slice-add` → `lisp/core/`（原 `archive/c/` symlink） |

## 历史 plan（含 archive/c · 保留不删）

- 全量 `bootstrap-v45*.lisp` 含 `archive/c` 字面量：**~84** 文件
- 性质：**历史 wave / CI 复核 / 注释** — 禁止混称用户 daily DONE

## 物理 GAP（仍开卷）

| 项 | 说明 |
|----|------|
| `release/nano-lisp.com` | 仍 genesis 锚 ~819KB · 瘦 slice rebuild 不能替代 runner |
| `archive/c/` symlink | CI 工厂面只读 · 用户 plan 不依赖 |
| 6 面 APE | 2/6 Linux only |
