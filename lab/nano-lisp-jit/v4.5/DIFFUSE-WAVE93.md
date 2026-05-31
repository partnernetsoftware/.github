# Wave93 — semantic diverge（compose15 expand 门控 · modules 真路径）

**签收**：`v45.goal.semantic_bulk_diverge=1`

## 根因（Wave92 同 hash）

`lispjit_from_lisp_build_compose_15link` **未门控** `compose15_expand_path_for_tag` — `compose-15link` semantic 误走 bulk-expand。

## 修复

```c
const char *expand =
    compose15_use_expand_modules() ? compose15_expand_path_for_tag(tag) : NULL;
```

## 结果

| 路径 | code_bytes | linked | hash |
|------|------------|--------|------|
| semantic (`compose-15link`) | **489** | 4096 | 900858bb… |
| bulk (`bulk-scale`) | **154559** | 155648 | c8688f39… |

## modules 更新

- `lisp-tu-main.lisp` — stage_a/stage_b call chain
- `04-vm.lisp` / `09-run.lisp` — func 内 call chain

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave93-semantic-diverge-converge.sh
```

**下一波**：semantic code_bytes 阶梯扩面（真实模块语义，非 bulk stub）
