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
- **signoff_id**: `v4-slice13-scoped`
- **updated_at**: 2026-05-23T13:14:16.592713+00:00
- **signoff_auto**: 98%
- **halt**: True

| role | task | status |
|------|------|--------|
| reviewer | — | idle |
| commander | — | idle |
| engineer-a | — | idle |
| engineer-b | — | idle |

| task_id | status | commit |
|---------|--------|--------|
| v4-aarch64-aot-plan | done | — |
| v4-squad-lisp-sketch | done | — |
| wave-practice-R1 | done | — |
| wave-practice-auto-exec-doc | done | — |
| wave-practice-v4-squad-md | done | — |
| wave-v4-R0 | done | — |
| wave10-v4-R | done | wave10r |
| wave10-v4-add7-regression | done | f0ca348 |
| wave10-v4-s5-verify-plan | done | f0ca348 |
| wave11-v4-R | done | wave11r |
| wave11-v4-codegen-kickoff | done | wave11a |
| wave11-v4-reflection | done | wave11b |
| wave12-v4-R | done | w12r |
| wave12-v4-add11-slice | done | w12b |
| wave12-v4-emit-profile | done | w12a |
| wave13-v4-R | done | 60ccd58 |
| wave13-v4-add13-slice | done | 60ccd58 |
| wave13-v4-lowering-table | done | 60ccd58 |
| wave14-v4-R | done | afd5039 |
| wave14-v4-add14-slice | done | afd5039 |
| wave14-v4-opcode-lowering | done | afd5039 |
| wave15-v4-R | done | 5b8b26f |
| wave15-v4-add15-slice | done | 5b8b26f |
| wave15-v4-manifest-ir | done | 5b8b26f |
| wave16-v4-R | done | b88097e |
| wave16-v4-add16-slice | done | b88097e |
| wave16-v4-manifest-encode | done | b88097e |
| wave17-v4-R | done | 00a4de0 |
| wave17-v4-add17-slice | done | 00a4de0 |
| wave17-v4-plan-ir-lisp | done | 00a4de0 |
| wave18-v4-R | done | 56f61e6 |
| wave18-v4-add18-slice | done | 56f61e6 |
| wave18-v4-lisp-encode | done | 56f61e6 |
| wave2-squad-triple-exit | done | — |
| wave2-v4-R | done | — |
| wave2-v4-s0-assess-sample | done | — |
| wave3-v4-R | done | — |
| wave3-v4-slice0-evidence | done | — |
| wave3-v4-squad-samples | done | — |
| wave4-v4-R | done | — |
| wave4-v4-slice1-add7 | done | — |
| wave4-v4-squad-signal | done | — |
| wave5-v4-R | done | — |
| wave5-v4-gen5-regression | done | — |
| wave5-v4-lisp-only-honesty | done | — |
| wave6-v4-R | done | — |
| wave6-v4-gen5v2-regression | done | — |
| wave6-v4-squad-s2-state | done | — |
| wave7-v4-R | done | — |
| wave7-v4-s3-member-once | done | — |
| wave7-v4-s3-supervise-once | done | — |
| wave8-squad-stuck-fix | done | — |
| wave8-v4-R | done | — |
| wave8-v4-s4-doc | done | — |
| wave9-squad-follower-team-ready | done | — |
| wave9-v4-R | done | — |
| wave9-v4-s4-agent-team | done | — |

**path_locks**:
- `.build/v4-slice4.evidence` → engineer-a
- `samples/bootstrap-v4-squad-s4-agent-team.lisp` → engineer-a
- `v4/SLICE4.md` → engineer-a
<!-- SQUAD_STATE_END -->
