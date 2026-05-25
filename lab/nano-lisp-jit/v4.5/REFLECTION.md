# v4.5 反思与梳理

## 一、我们在建什么（一句话）

**发行面**：`nano-jit.com` + `*.lisp` 完成编译、运行、打包、自举验收。  
**工厂**：`run.sh` + C 源码 + 历史 wave 样本 — 仅维护者全量回归，不是用户接口。

## 二、版本线（别混）

| 版本 | 签收什么 | 载体 |
|------|----------|------|
| v4 scoped | catalog S0–S15 · squad | `run.sh` + catalog-v4 |
| v4 lispjit-from-lisp | gen60 · genesis compare | zero-host plans |
| **v4.5 scoped 100%** | 洋葱 TDD · com-only verify | `bootstrap-v45-*.lisp` |

**v4.5 scoped 100% ≠ 全仓零 `.c/.sh`** — 见 [`PROGRESS.md`](PROGRESS.md)。

## 三、做对了什么

| 点 | 说明 |
|----|------|
| v4 当引擎 | 不重写 runner；`.com` 跑 plan 即自举 |
| 洋葱改载体 | 验收迁到 `bootstrap-v45-*.lisp` |
| tier 分期 | 避免「DONE = 删光 C」误解 |
| genesis 环境 | `env -u NANO_SELFHOST_REUSE_*` 再 compare |
| **目录清理** | `v4/` 从 260+ md 收到 16；SLICE → `archive/v4/slices/` |

## 四、踩过的坑

| 现象 | 根因 | 处理 |
|------|------|------|
| compare 失败 | selfhost-reuse 盖过 genesis-pin | unset reuse |
| multi-func `(run)` 断 plan | exit≠0 | `compile-elf64-exe` + `run-expect-exit` |
| boundary store-u32 红 | VM 未支持 | 改 store-load-u8 |
| v4 能否开 v4.5 | 混淆子轨与发行面 | handoff 锚 gen60 |
| SLICE 塞满 v4/ | wave 记账当活跃区 | 归档 + 路径批量改 |

## 五、清理后目录（真源）

```
lab/nano-lisp-jit/
├── v4.5/          ← 发行面 SSOT（ONION-TDD · EVAL · REFLECTION · CLEANUP）
├── v4/            ← v4 决策/进度/mindmap（16 个 md + INDEX）
├── samples/
│   ├── bootstrap-v45-*   ← 洋葱验收
│   ├── boundary/         ← 边界样例
│   └── bootstrap-v4-*    ← 工厂（勿误删）
├── archive/v4/slices/    ← 244× SLICE 历史
├── archive/v4/factory-docs/
├── run.sh                ← 工厂全量回归
└── STRUCTURE.md          ← 地图
```

详见 [`CLEANUP.md`](CLEANUP.md)、[`../samples/README.md`](../samples/README.md)。

## 六、洋葱 TDD 怎么用（替代 .sh 纵切片）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-onion-tdd.lisp
grep v45.scoped.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

`run.sh` 仅在 CI/维护时落盘 `.evidence`；**签收看 plan + .com**。

## 七、下一刀

1. tier3：runner 源码移出主路径  
2. 扩 `boundary/` + 负向样例  
3. `run.sh` 瘦身为单条 onion-com-only 委托  
4. wave 样本分批迁入 `archive/samples/`（需改 run.sh 变量表 — 未做）
