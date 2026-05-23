# v4 小组派单板

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml assess
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team
```

见 [`README.md`](README.md)、[`../v3.5/DECISION.md`](../v3.5/DECISION.md)。

<!-- SQUAD_STATE_BEGIN -->
### 派单板（SQLite state 导出 · 勿手改）

- **project**: `/workspace/lab/nano-lisp-jit`
- **state.db**: `/workspace/lab/nano-lisp-jit/.squad/state-v4.db`
- **signoff_id**: `v4-kickoff`
- **updated_at**: 2026-05-23T08:01:28.936569+00:00
- **signoff_auto**: 100%
- **halt**: False

| role | task | status |
|------|------|--------|
| reviewer | wave-v4-R0 | in_progress |
| commander | — | idle |
| engineer-a | — | idle |
| engineer-b | — | idle |

| task_id | status | commit |
|---------|--------|--------|
| v4-aarch64-aot-plan | done | cd88032 |
| v4-squad-lisp-sketch | done | e371c01 |
| wave-v4-R0 | in_progress | — |
<!-- SQUAD_STATE_END -->
