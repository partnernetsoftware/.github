# v4.5 反思

## 做对了什么

| 点 | 说明 |
|----|------|
| **v4 当引擎** | 不重写 runner；`.com` + plan 即自举链 |
| **洋葱改载体** | 验收从 `run.sh` 纵切片迁到 `bootstrap-v45-*.lisp` |
| **tier 分期** | scoped 100% ≠ 全仓零 `.c`；DECISION 写死避免再混淆 |
| **genesis 环境** | tier2 必须 `env -u NANO_SELFHOST_REUSE_*`，否则 compare 打到 reuse 副本 |

## 踩过的坑

| 现象 | 根因 | 处理 |
|------|------|------|
| `compare` 失败 | selfhost-reuse 优先于 genesis-pin | com/genesis plan 前 unset reuse env |
| `multi-func` `(run)` 断 plan | 进程 exit=43 | 改用 `compile-elf64-exe` + `run-expect-exit` |
| boundary `store-load-u32` 红 | VM 未支持该 store 形态 | 改为 `store-load-u8` / const-ptr |
| 误以为 v4 不能开 v4.5 | 混淆 track DONE 与发行面 | handoff plan 明确锚定 gen60 |

## 目录整理（本波）

- **活跃**：`v4.5/`、`samples/boundary/`、`samples/bootstrap-v45-*`
- **仍活跃但臃肿**：`v4/SLICE*.md`（244 个）— 保留供 `run.sh` 引用，索引见 [`STRUCTURE.md`](../STRUCTURE.md)
- **归档**：`archive/` 继续收纳 v2–v3.5；新增强调「工厂 vs 发行面」分轨

## 下一刀（post–scoped-100）

1. tier3：runner 源码移出主路径（仅 seed `.com` + genesis）
2. 扩 `boundary/` 与负向 `(compile-expect-exit 2 …)` 矩阵
3. `run.sh` 瘦身为仅调用 `.com run-bootstrap-plan bootstrap-v45-onion-com-only`（工厂极简）
