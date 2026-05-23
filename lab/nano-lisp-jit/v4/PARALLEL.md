# v4 并行推进（不必等 signoff 100%）

## 扩散 → 收敛 → 洋葱修正（硬约束）

**禁止**：按「一条 op / 一个 cmd / 一个 gate」顺序补 C、补 plan、补 `run.sh`（wave26 式碎补 = 长周期、假进度）。

**每波只做一轮大循环**：

```text
① 扩散（并发 + 广度，先出内容）
   同一 wave 内同时铺开 touch_paths（多轨并行）：
   · Plan：整表 / 整图 bootstrap（非单步）
   · 编排：一批 squad-* 样本 + catalog tasks
   · Codegen：契约文件一次写全（如整份 ir-table / words），stub 可暂红
   · 门禁：run.sh cases + signoff gates 一次登记
   目标：最短时间内「面」上有完整草稿，允许局部未绿。

② 收敛（一次真源）
   单 Agent 或 reviewer：一次 bash lab/nano-lisp-jit/run.sh
   → assess → 只修失败项（不新开 wave 补一刀）

③ 洋葱 TDD（由内向外修）
   先修最内圈失败（emit/契约不一致）→ 再 runner → 再 plan 措辞 → 最后文档
```

与 [`MINDMAP.md`](MINDMAP.md) 洋葱圈一致：**先广后深**，不是「深一点提交一次」。

## 口径

| 层 | 含义 | 推进条件 |
|----|------|----------|
| **scoped** | 本 slice 计划 + 证据 + 样本 | `assess` → `scoped_ready=True` 即可开下一波 |
| **terminal** | 全量 `run.sh` / `build_nano_jit.sh` 回归 | 合 `main` 前拉绿，不阻塞下一 slice 设计 |

`catalog-v4.yaml`：`signoff.id=v4-complete`；`v35-regression-*` 在 `terminal_gates`。

## 多轨并行（每波 ≥2 工程兵 + reviewer）

```text
轨 A · codegen/契约  engineer-a  → ir-table/words + 样本族 +（若开卷）stub 读表
轨 B · 编排/plan     engineer-b  → bootstrap 图 + squad-* + v4/*.md
轨 C · 构建/门禁     （可选）    → run.sh + catalog gates 批量
轨 R · 签收          reviewer    → 一次 run.sh → assess → sync-md
```

**禁止**：两轨同改 `run.sh` 同一 case 块；新 case 由收敛轮统一追加。

## Agent 快路径（单进程等价四角色）

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume --reason waveN
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
# 扩散：并行写完 A/B/C touch_paths → 一次 run.sh → 洋葱修 → assess
```

勿在未写代码时长期挂 `agent-team`（见 [`skills/squad-parallel/SKILL.md`](../../skills/squad-parallel/))。

## 下一波模板（wave27+ · 扩散面）

| 面 | 一次铺开（示例） | 收敛时验 |
|----|------------------|----------|
| Plan | 整份 `v4-ir-table-v1.lisp` 五 op + `bootstrap-v4-build-graph.lisp` | plan 无 `.c` |
| 编排 | `squad-assess` / `dispatch` / `member` 样本齐 | assess 步骤真跑 |
| Codegen | stub **一次**读整表（非 per-op 提交） | 表版本 + addN 族 |
| 构建 | `results-min` + build 步骤进同一 plan | `build.pass≥26` |

wave24–26 已签收；后续按上表 **一波扩散**，不再「svc0 一刀、assess 一刀」。
