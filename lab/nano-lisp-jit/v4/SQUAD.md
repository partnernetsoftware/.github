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
- **updated_at**: 2026-05-23T08:14:05.651160+00:00
- **signoff_auto**: 100%
- **halt**: False

| role | task | status |
|------|------|--------|
| reviewer | wave-practice-R1 | in_progress |
| commander | — | idle |
| engineer-a | — | idle |
| engineer-b | — | idle |

| task_id | status | commit |
|---------|--------|--------|
| v4-aarch64-aot-plan | done | cd88032 |
| v4-squad-lisp-sketch | done | e371c01 |
| wave-practice-R1 | in_progress | — |
| wave-practice-auto-exec-doc | done | cbef46b |
| wave-practice-v4-squad-md | done | cbef46b |
| wave-v4-R0 | done | adb3bd1 |
<!-- SQUAD_STATE_END -->
