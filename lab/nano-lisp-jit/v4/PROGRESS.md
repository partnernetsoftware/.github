# v4 终局进度（与 catalog 100% 分离）

| 维度 | 粗估 | 说明 |
|------|------|------|
| 自举 | **~85%** | gen2→**gen16**；gen15 `.com` 嵌套跑 gen16 |
| 终局整体 | **~85%** | phase3：repack 无 lispjit · lispjit=**genesis-pin**（非 stage0-bridge） |

**phase3 证据**（`.build/v4-zero-host-bootstrap.evidence`）：
- `zero.host.repack_no_lispjit=1` — gen14-fat 仅 pack 既有 slice
- `zero.host.lispjit_genesis_pin=1` — gen15 全量 JIT，零 host `cc`
- `zero.host.nested_com_runner=1` — gen15.com → gen16 plan

**未达 100%**：`NANO_REGENESIS=1` / `NANO_SLICE_ALLOW_HOST_CC=1` 仍会 stage0-bridge；genesis pin 非「Lisp 编出 lispjit」。
