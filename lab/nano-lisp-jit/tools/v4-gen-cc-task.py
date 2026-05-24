#!/usr/bin/env python3
"""Generate cc task file for a wave batch. Usage: v4-gen-cc-task.py LO HI [out.txt]"""
from __future__ import annotations
import sys
from pathlib import Path

# Wave themes — extend before each longrun batch (Composer or cc prep)
THEMES: dict[int, tuple[str, int, str, str, str, str, str, str, str, str, str, str]] = {
    # wave: title, a, b_track, b_refs..., c_track, c_refs..., b_test, c_test
    86: (
        "runner-plan-deep",
        64,
        "runner",
        "samples/bootstrap-v4-wave62-runner-tick.lisp",
        "v4/LISP-ONLY.md",
        "v4/DECISION.md",
        "plan",
        "samples/bootstrap-v4-plan-contract-tick.lisp",
        "v4/SLICE34.md",
        "v4/DECISION.md",
        "samples/bootstrap-v4-wave62-runner-tick.lisp",
        "v4/SLICE34.md",
    ),
    87: (
        "squad-evidence-chain",
        65,
        "assess",
        "samples/bootstrap-v4-wave42-assess-bundle-tick.lisp",
        "samples/bootstrap-v4-squad-assess-once.lisp",
        "v4/SLICE42.md",
        "evmatrix",
        "samples/bootstrap-v4-wave48-manifest-tick.lisp",
        "samples/bootstrap-v4-evidence-matrix.lisp",
        "v4/SLICE48.md",
        "samples/bootstrap-v4-squad-assess-once.lisp",
        "v4/SLICE48.md",
    ),
    88: (
        "onion-mindmap-close",
        66,
        "onion",
        "samples/bootstrap-v4-wave58-onion-tick.lisp",
        "v4/MINDMAP.md",
        "v4/PARALLEL.md",
        "mindmap",
        "samples/bootstrap-v4-wave52-mindmap-tick.lisp",
        "v4/EVAL.md",
        "v4/PROGRESS.md",
        "v4/MINDMAP.md",
        "v4/EVAL.md",
    ),
}


def gen_wave_block(w: int) -> str:
    if w not in THEMES:
        raise SystemExit(f"wave {w} not in THEMES — add to tools/v4-gen-cc-task.py first")
    title, a, bt, bf1, bf2, bf3, ct, cf1, cf2, cf3, btest, ctest = THEMES[w]
    expect = a + 17
    return f"""  {w}: dict(
        title="{title}",
        a={a},
        b_track="{bt}",
        c_track="{ct}",
        b_files=["{bf1}", "{bf2}", "{bf3}"],
        c_files=["{cf1}", "{cf2}", "{cf3}"],
        b_test="{btest}",
        c_test="{ctest}",
    ),"""


def main() -> None:
    lo = int(sys.argv[1])
    hi = int(sys.argv[2])
    out = Path(sys.argv[3]) if len(sys.argv) > 3 else Path(__file__).parent / f"cc-task-wave{lo}-{hi}.txt"
    blocks = "\n".join(gen_wave_block(w) for w in range(lo, hi + 1))
    body = f"""Implement v4 wave{lo}-{hi} batch for lab/nano-lisp-jit.

/goal: onion TDD batch; ≤4 tracks per wave; do NOT stop until CC_DONE or hard failure.
/loop: fix gate failures and re-run run.sh (max 2 retries).

1. Add to tools/gen-v4-wave-batch.py WAVES dict (before closing `}}`):
{blocks}

2. Run: python3 lab/nano-lisp-jit/tools/gen-v4-wave-batch.py {lo} {hi}

3. Update v4/EVAL.md §wave{lo}–{hi}, PROGRESS.md, LONG-RUN-TODO.md (mark done, pointer {hi + 1}), REFLECTION.md, MINDMAP.md if needed.

4. Run: export NANO_SLICE_COMPILER=native && bash lab/nano-lisp-jit/build_nano_jit.sh && bash lab/nano-lisp-jit/run.sh
   On failure: diagnose, fix, retry (max 2).

5. Do NOT git commit.

Final line MUST be exactly: CC_DONE tests.pass=N
"""
    out.write_text(body)
    print(out)


if __name__ == "__main__":
    main()
