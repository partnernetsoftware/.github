# fasmgx 反思（Wave25–33 收束 → Wave34 开卷）

## 一、我们在哪

| 层 | 状态 | 说明 |
|----|------|------|
| /goal 洋葱×tree-mind-map | **100%** | `mindmap-frontier-v45.json` **26/26** |
| 发行面 scoped / tier5 | **100%** | `nano-jit.com` + `bootstrap-v45-*.lisp` |
| 工厂物理（诚实） | **~99.5%** | 154KB runner 全量 Lisp codegen **未达** |
| 扩展活图 Wave25–33 | **各 7/7** | 8 张 JSON · 独立签收键 |

## 二、做对了什么

- **活图分卷**：扩展卷不再挤进 26 节点，避免误报 /goal 100%。
- **代际四轨**：Wave33 在 `v45-selfhost-next.com` 上绿 slice/vm/ir，与 host 探针解耦。
- **rollup 复核**：Wave32 一次复核 Wave25–31 键，降低证据漂移。
- **append-only evidence + canonical**：审计路径稳定。

## 三、踩坑（fasmgx 口径）

| 现象 | 根因 | 调整 |
|------|------|------|
| 探针绿 = 全量 codegen | 仅 4 条 plan 跑通 | Wave34 开 **runner 广面** 活图 |
| 扩展 7/7 = 工厂 100% | 签收键分卷 | `HONEST-REMAINING` 单独陈述 |
| onion exit 42 | `run-expect-exit` 语义 | 用 `smoke_ok` / grep `run-expect-exit.ok=1` |
| 小 com 跑完整 onion 无输出 | plan 体量 | 大 plan 绑 `nano-jit.com` / `selfhost-next.com` |

## 四、清理结论

1. **不删** `run.sh` / `archive/runner` — 仅 scoped CI + `v45-release-run.sh` 锚。
2. **不并** v4 全图 69 节点进 v45 %。
3. **fasmgx/** 只承载工厂续推 SSOT；样例仍放 `lab/nano-lisp-jit/samples/`。
4. Wave34 已落地：`v45-wave34-runner-codegen-continue-converge.sh` · 活图 **7/7**。

## 五、与 v4.5 文档关系

| v4.5 | fasmgx |
|------|--------|
| `ONION-TDD.md` · `MINDMAP-TDD-TREE.md` | 耦合方法 · 下一步卷 |
| `DIFFUSE-WAVE33.md` | 上一波终局 |
| `HONEST-REMAINING.md` | 物理未达清单（共享口径） |
