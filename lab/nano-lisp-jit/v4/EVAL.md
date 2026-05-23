# v4 进度评估（合 main · wave27）

**评估日**：2026-05-23  
**分支**：`cursor/v4-wave15-parallel-108a` → **main**  
**catalog**：`v4-complete` scoped=100% terminal=100% ready=True  

## 六维终局（与 catalog 分离）

| 维度 | 终局目标 | wave27 后 | Δ（相对 wave25） |
|------|----------|-----------|------------------|
| Plan | bootstrap 无 `.c` | ✅ 常绿 | — |
| Runner | Lisp 执行 plan | C `nano-lisp-jit` | — |
| Codegen | Lisp IR 整表 → blob | 五 op 契约 + stub 整表读 | **+7%** → **~25%** |
| 编排 | Lisp `(squad-*)` | assess + 编排束样本 | **+6%** → **~18%** |
| 构建 | plan 内 build 图 | wave27 图 + results-min | **+8%** → **~30%** |
| 自举 | `.com` 下一代 | 未开卷 | — |

**整体终局**：约 **15–22%**（外圈满 ≠ 内圈替换完成）。

## 本波方法

```text
扩散：整表 + 3 plan 样本 + run.sh/catalog 一批登记
收敛：一次 run.sh → assess
洋葱：先 emit/契约 → runner → plan 文档
```

## 签收

- `bash lab/nano-lisp-jit/run.sh`
- `tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml assess`

**未声称**：零 `.c` / `.py` / `.sh`（见 [`DECISION.md`](DECISION.md) 终局未开卷）。
