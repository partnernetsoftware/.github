---
name: nano-lisp-jit-v4-longrun
description: >-
  v4 长程自循环：state SSOT → 确定性 apply → gate → cc repair → bump → commit。
  Use when 长程、longrun、wave 批量、不到 100% 继续、/goal /loop、cc-huoshan 下手。
paths:
  - "skills/nano-lisp-jit-v4-longrun/**"
  - "lab/nano-lisp-jit/v4/longrun-state.json"
  - "lab/nano-lisp-jit/v4/LONG-RUN-TODO.md"
  - "lab/nano-lisp-jit/tools/gen-v4-wave-batch.py"
---

# nano-lisp-jit v4 longrun（可执行 skill · Bun TS）

## 铁律

1. **Agent 须亲自跑 skill**，禁止只贴命令给用户。
2. **真源** [`lab/nano-lisp-jit/v4/longrun-state.json`](../../lab/nano-lisp-jit/v4/longrun-state.json)；`LONG-RUN-TODO.md` 仅展示。
3. **apply 确定性**（`gen-v4-wave-batch.py`）；**cc 仅 gate 失败 repair**。
4. 每批 3 波 × ≤4 轨；未达 `/goal` **禁止**早停总结。
5. 扩波次：先改 `gen-v4-wave-batch.py` WAVES，再 `apply`。

## 入口（Bun TS，非 shell）

```bash
export PATH="$HOME/.bun/bin:$PATH"

# 读指针
bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts show

# 单批 apply + gate
bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts apply 92 94
bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts gate

# 长驱 /loop
bun run skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop \
  --batches 3 --goal wave95 --timeout 7200
```

## 分工

| 角色 | 工具 |
|------|------|
| Composer | 本 skill 编排、扩 WAVES、commit/PR |
| cc 下手 | `~/.local/bin/cc-huoshan1-ds4pro`（loop 内 repair 自动调） |

## 阶段

```text
state → apply → gate → [cc repair → gate] → bump state → [commit]
```

## 与旧脚本

`lab/nano-lisp-jit/tools/v4-longrun-loop.sh` 已委托本 skill；新逻辑只改 `skills/nano-lisp-jit-v4-longrun/`。
