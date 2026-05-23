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
- **signoff_id**: `v4-complete-scoped`
- **updated_at**: 2026-05-23T13:22:34.546390+00:00
- **signoff_auto**: 98%
- **halt**: False

| role | task | status |
|------|------|--------|
| reviewer | wave10-v4-R | in_progress |
| commander | — | idle |
| engineer-a | wave10-v4-add7-regression | in_progress |
| engineer-b | wave9-squad-follower-team-ready | assigned |

| task_id | status | commit |
|---------|--------|--------|
| v4-aarch64-aot-plan | done | cd88032 |
| v4-squad-lisp-sketch | done | e371c01 |
| wave-practice-R1 | done | f2a5fdd |
| wave-practice-auto-exec-doc | done | cbef46b |
| wave-practice-v4-squad-md | done | cbef46b |
| wave-v4-R0 | done | adb3bd1 |
| wave10-v4-R | in_progress | — |
| wave10-v4-add7-regression | in_progress | — |
| wave2-squad-triple-exit | done | 6287cd7 |
| wave2-v4-R | done | 6287cd7 |
| wave2-v4-s0-assess-sample | done | 6287cd7 |
| wave3-v4-R | done | 56788ff |
| wave3-v4-slice0-evidence | done | 56788ff |
| wave3-v4-squad-samples | done | 56788ff |
| wave4-v4-R | done | ece6998 |
| wave4-v4-slice1-add7 | done | ece6998 |
| wave4-v4-squad-signal | done | ece6998 |
| wave5-v4-R | done | 7203594 |
| wave5-v4-gen5-regression | done | 7203594 |
| wave5-v4-lisp-only-honesty | done | 7203594 |
| wave6-v4-R | done | c6fa877 |
| wave6-v4-gen5v2-regression | done | c6fa877 |
| wave6-v4-squad-s2-state | done | c6fa877 |
| wave7-v4-R | done | 05a6584 |
| wave7-v4-s3-member-once | done | 05a6584 |
| wave7-v4-s3-supervise-once | done | 05a6584 |
| wave8-squad-stuck-fix | done | 0e38ef9 |
| wave8-v4-R | done | ac6379f |
| wave8-v4-s4-doc | done | 0fe395d |
| wave9-squad-follower-team-ready | assigned | — |
| wave9-v4-R | done | 4dbed7b |
| wave9-v4-s4-agent-team | done | 4dbed7b |

**pending**: wave10-v4-s5-verify-plan, wave11-v4-reflection, wave11-v4-codegen-kickoff, wave11-v4-R, wave12-v4-emit-profile, wave12-v4-add11-slice, wave12-v4-R, wave13-v4-lowering-table, wave13-v4-add13-slice, wave13-v4-R, wave14-v4-opcode-lowering, wave14-v4-add14-slice, wave14-v4-R, wave15-v4-ir-entry, wave15-v4-squad-assess, wave15-v4-R, wave16-v4-ir-table-v2, wave16-v4-squad-dispatch, wave16-v4-R, wave17-v4-ir-table-v3, wave17-v4-squad-signal, wave18-v4-emit-manifest, wave18-v4-squad-resume, wave19-v4-product-probe, wave20-v4-complete-R

**path_locks**:
- `.build/bootstrap-v4-slice1-add7.elf` → engineer-a
- `.build/v4-slice5.evidence` → engineer-a
- `run.sh` → engineer-a
- `samples/bootstrap-v4-slice1-add7.lisp` → engineer-a
<!-- SQUAD_STATE_END -->
