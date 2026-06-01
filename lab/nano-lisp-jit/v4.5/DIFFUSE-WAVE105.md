# Wave105 — build_nano_jit 工厂 lisp-only 路径

**签收**：`v45.goal.factory_build_lisp_only_milestone=1`

| 槽 | 交付 |
|----|------|
| W1 | `build_nano_jit_lisp_only.sh` — COM 驱动 plan regenesis |
| W2 | `factory-build-lisp-only-regenesis.lisp` — 零 plan 内 lispjit.c |
| W3 | semantic-unified smoke on release COM |
| W4 | journal round 34 |

**诚实分层**（禁止混称工厂零 C DONE）：

| 面 | 状态 |
|----|------|
| plan regenesis | ✅ `build-slice-lisp` only |
| `build_nano_jit.sh` 种子 | C 编译 archive runner 仍在 |
| release promote | 仍走 manifest pin |

```bash
bash lab/nano-lisp-jit/build_nano_jit_lisp_only.sh
bash lab/nano-lisp-jit/retired/scripts/v45-wave105-factory-build-lisp-only-converge.sh
```

**下一刀**：Mach-O/PE 真实 slice · 工厂 C 种子退仓路径
