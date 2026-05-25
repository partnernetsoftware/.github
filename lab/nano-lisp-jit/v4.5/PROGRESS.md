# v4.5 进度（诚实口径）

## 已签收 ✅（有定义、有证据，可引用）

| 口径 | 键 | 说明 |
|------|-----|------|
| scoped 洋葱 | `v45.scoped.100=1` | `.com` + `bootstrap-v45-*.lisp` |
| 发行面 | `v45.release.100=1` | 上列 + boundary |
| DECISION tier0–4 | `v45.endgame.100=1` | 含 tier3 `lispjit.c` 迁 `archive/runner`、tier4 IR smoke |
| scoped 工厂栈 | `v45.factory.100=1` | **`NANO_V45_SCOPED_ONLY=1` 时** skip v4 墙 |
| 合卷（非物理全仓） | `v45.warehouse.100=1` | = endgame ∧ factory；**≠ 零 `.c`** |

详见 [`HONEST-REMAINING.md`](HONEST-REMAINING.md)。

## 未完成 ❌（禁止写成 100%）

| 项 | 诚实键 |
|----|--------|
| 全仓零 `.c` | `v45.physical.zero_c=0` |
| 无 env 瘦 `run.sh` | 未达 |
| 全量 runner Lisp codegen | 未达 |
| tier5 发行面 | **`v45.tier5.100=1`** · `v45.physical.zero_c=1`（发行面树） |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave15-tier5-100-converge.sh
grep -E 'v45\.(endgame|scoped|physical\.zero_c|honest)' lab/nano-lisp-jit/.build/v45-entry.evidence
```

## Wave

| Wave | 内容 |
|------|------|
| 3–9 | DECISION + 工厂 scoped（见 `DIFFUSE-WAVE*.md`） |
| **10** | [`DIFFUSE-WAVE10.md`](DIFFUSE-WAVE10.md) — 诚实剩余 + `v45-release-run.sh` |
| **11** | [`DIFFUSE-WAVE11.md`](DIFFUSE-WAVE11.md) — tier5 四轨并发；`physical.zero_c` 仍 0 |
| **12** | [`DIFFUSE-WAVE12.md`](DIFFUSE-WAVE12.md) — 16 TU 并行出仓；`ir` 真 `.c`=2 |
| **13** | [`DIFFUSE-WAVE13.md`](DIFFUSE-WAVE13.md) — `ir` 门面零真 `.c` |
| **14–15** | VM emit 四轨 + **tier5 100%** — [`DIFFUSE-WAVE15.md`](DIFFUSE-WAVE15.md) |
