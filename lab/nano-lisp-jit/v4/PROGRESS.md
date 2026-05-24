# v4 终局进度

| 维度 | 粗估 |
|------|------|
| 自举 | **~90%** |
| 终局整体 | **~90%** |

**phase4（gen17–18）**
- `NANO_BUILD_SLICE_SELFHOST_REUSE=1`：`lispjit.c` → **`build-slice.role=selfhost-reuse`**（复制 gen15 slice，**非 genesis/**）
- **gen17.com** 跑 **ir-table-lisp** + aarch64 emit → gen18（`zero.host.ir_table_on_com=1`）

证据：`zero.host.selfhost_reuse=1` · `zero.host.chain=g2-g18`

**未达 100%**：selfhost-reuse 需新 `lispjit` 在 runner 内；`.com` 内嵌旧 slice 时 plan 内 reuse 需 **NANO_REGENESIS** 重编 slice 后才进新 runner。
