# v4 slice-5 — 工单内嵌 verify plan（scoped）

**前置**：[`SLICE4.md`](SLICE4.md)、[`LISP-ONLY.md`](LISP-ONLY.md)。

## 目标

| 轨 | 交付 | 非目标 |
|----|------|--------|
| **S5 plan** | `bootstrap-v4-squad-s5-verify-plan.lisp` 锚定 `member_exec` + PROTOCOL | Lisp `(squad-done …)` FFI |
| **host auto_exec** | `SQUAD_VERIFY=1` 时 verify 用 `--once` + `--no-auto-exec` 防嵌套 | 每工单全量 `run.sh` 默认关 |
| **回归** | slice-1 add7 ELF hash 锚定 | 真 aarch64 VM/AOT（wave11+） |

## run.sh 门禁

- `run-bootstrap-v4-squad-s5-verify-plan`
- `run-bootstrap-v4-slice5-evidence-plan`
- `squad-v4-wave10-practice-smoke` — resume + 四角色 `run-loop --once`

## 证据

`.build/v4-slice5.evidence`（`v4.slice5=1`）

## 签收

`catalog-v4` → `signoff.id=v4-slice5-scoped`。

## 并行小队

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume --reason wave10
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml dispatch --force --include-meta
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team --auto-exec --auto-done
```
