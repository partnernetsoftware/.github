# lab/nano-lisp-jit 维护约定

供并行开发 v4 时保持目录卫生；**签收口径**仍以 [`v4/EVAL.md`](v4/EVAL.md) 为准。

## 活跃区（勿归档）

| 路径 | 用途 |
|------|------|
| [`v4/`](v4/) | 终局进度、SLICE、LONG-RUN 队列 |
| [`samples/bootstrap-v4-*`](samples/) | plan / tick / evidence 样本 |
| [`samples/nano-jit-slice-add-*`](samples/) | addNN 切片（与 `run.sh` 同步） |
| [`squad/catalog-v4.yaml`](squad/catalog-v4.yaml) | v4 门禁 |
| [`run.sh`](run.sh) · [`build_nano_jit.sh`](build_nano_jit.sh) | 收敛入口 |
| [`tools/gen-v4-wave-batch.py`](tools/gen-v4-wave-batch.py) | 批量生波 |
| [`tools/v4-longrun-loop.sh`](tools/v4-longrun-loop.sh) | `/loop` 长驱 |
| [`tools/v4-gen-cc-task.py`](tools/v4-gen-cc-task.py) | 生 cc 任务 |
| [`tools/v4-read-pointer.py`](tools/v4-read-pointer.py) | 读 LONG-RUN 指针 |
| [`tools/cc-task-*.txt`](tools/) + `cc-huoshan1-ds4pro` | 编程下手 |

## 归档区

见 [`archive/README.md`](archive/README.md)（v2–v3.5 文档、APE spec、v3.5 catalog 快照）。

## 可清理（随时）

```bash
bash lab/nano-lisp-jit/tools/clean-lab.sh
```

删除 `.build/*`、`.squad` 下 **可再生成** 的 db/json/lock；**不**删 `samples/`、`v4/`。

## 勿提交

已由 [`.gitignore`](.gitignore) / 仓库根 `lab/**/.build/` 覆盖：

- `.build/*.elf`、`.build/v4*.evidence`、`results.txt`
- `.squad/state-v4.db`、`state-v4.json`、`verify.lock`

## 样本

- 新增波次只增 `bootstrap-v4-wave*` / `nano-jit-slice-add-*`，勿删旧样本（`run.sh` 全量回归）。
- 孤立样本（未进 catalog/run）应接入门禁或移入 `archive/samples-orphan/`（需改 `run.sh` 再移）。

## 长程队列

[`v4/LONG-RUN-TODO.md`](v4/LONG-RUN-TODO.md) — 每批合 main 后更新指针与打勾。
