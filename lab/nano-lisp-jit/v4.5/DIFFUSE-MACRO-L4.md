# Macro L4 — 抓大放小

## 大（宏观）

| 轨 | 状态 | 动作 |
|----|------|------|
| **A L4 codegen** | 开卷 | `link.code.bytes` → 154KB，零 host cc |
| **B release guard** | ✅ 维持 | manifest pin + 矩阵，promote 时自动跑 |
| **C honest gate** | 常开 | continue.100 ≠ strict_done |

## 小（并行微操，4 槽）

- W1: `compose15_link.code_bytes` 探针写入 evidence
- W2: modules-expand **bulk .text**（非 object 元数据膨胀）
- W3: `v45-manifest-pin.sh` 守门
- W4: verify-smoke 快矩阵

## 弃用虚荣指标

- ~~object_bytes_total~~（ELF 元数据）
- ~~linked_bytes / wc -c~~（4096 页对齐）

**SSOT**: `link.code.bytes`（Wave81 round10 ≈1630，stub ≈445，目标 ≥154000）

## Wave82 里程碑（bulk-scale）

| 指标 | Wave81 (round 10) | Wave82 目标 |
|------|-------------------|-------------|
| `link.code.bytes` | 1630 | **≥3000**（3K 中间里程碑） |
| bulk 槽 | 单槽 13-bulk-text | **core+extra+vm+mf** 四槽 (13–16) |
| frontier | `l4-codegen-parallel` | `l4-bulk-scale` |

**路径**: 1630 → **3K** → … → 154KB

- 探针: `bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp`
- converge: `retired/scripts/v45-l4-bulk-scale-converge.sh`
- `NANO_L4_CODE_BYTES_THRESHOLD` 默认 3000，可 env 覆盖
