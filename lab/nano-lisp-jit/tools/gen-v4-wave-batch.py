#!/usr/bin/env python3
"""Generate v4 wave batch samples. Usage: gen-v4-wave-batch.py 68 73"""
from __future__ import annotations
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLES = ROOT / "samples"

WAVES = {
    68: dict(
        title="ir-table-recap",
        a=46,
        b_track="irtable",
        c_track="chain",
        b_files=[
            "samples/bootstrap-v4-wave56-irtable-tick.lisp",
            "samples/bootstrap-v4-wave56-host-reduce-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
        ],
        c_files=[
            "samples/bootstrap-v4-wave55-diffusion.lisp",
            "v4/SLICE56.md",
            "samples/bootstrap-v4-wave56-diffusion.lisp",
        ],
        b_test="samples/bootstrap-v4-wave56-irtable-tick.lisp",
        c_test="v4/SLICE56.md",
    ),
    69: dict(
        title="build-graph-deep",
        a=47,
        b_track="buildgraph",
        c_track="gates",
        b_files=[
            "samples/bootstrap-v4-build-graph-wave27.lisp",
            "samples/bootstrap-v4-wave44-build-graph-tick.lisp",
            "samples/bootstrap-v4-wave31-diffusion.lisp",
        ],
        c_files=[
            "samples/bootstrap-v4-build-gates-plan.lisp",
            "v4/SLICE31.md",
            "samples/bootstrap-v4-wave44-diffusion.lisp",
        ],
        b_test="samples/bootstrap-v4-build-graph-wave27.lisp",
        c_test="v4/SLICE31.md",
    ),
    70: dict(
        title="host-reduce-chain",
        a=48,
        b_track="hostreduce",
        c_track="wave33",
        b_files=[
            "samples/bootstrap-v4-wave32-diffusion.lisp",
            "samples/bootstrap-v4-wave32-host-reduce-tick.lisp",
            "v4/SLICE32.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave33-diffusion.lisp",
            "samples/bootstrap-v4-build-graph-wave27.lisp",
            "v4/SLICE33.md",
        ],
        b_test="samples/bootstrap-v4-wave32-host-reduce-tick.lisp",
        c_test="v4/SLICE33.md",
    ),
    71: dict(
        title="plan-contract-recap",
        a=49,
        b_track="contract",
        c_track="manifest",
        b_files=[
            "samples/bootstrap-v4-plan-contract-tick.lisp",
            "samples/bootstrap-v4-wave34-diffusion.lisp",
            "v4/SLICE34.md",
        ],
        c_files=[
            "samples/v4-plan-manifest-v1.lisp",
            "samples/bootstrap-v4-wave29-diffusion.lisp",
            "v4/SLICE29.md",
        ],
        b_test="samples/bootstrap-v4-plan-contract-tick.lisp",
        c_test="v4/SLICE34.md",
    ),
    72: dict(
        title="evidence-matrix-deep",
        a=50,
        b_track="evmatrix",
        c_track="resume",
        b_files=[
            "samples/bootstrap-v4-wave48-manifest-tick.lisp",
            "samples/bootstrap-v4-wave48-contract-tick.lisp",
            "v4/SLICE48.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave60-evidence-tick.lisp",
            "samples/bootstrap-v4-squad-resume-tick.lisp",
            "v4/SLICE60.md",
        ],
        b_test="samples/bootstrap-v4-wave48-manifest-tick.lisp",
        c_test="v4/SLICE48.md",
    ),
    73: dict(
        title="four-track-milestone",
        a=51,
        b_track="fourtrack",
        c_track="onion",
        b_files=[
            "samples/bootstrap-v4-wave57-fourtrack-tick.lisp",
            "samples/bootstrap-v4-wave57-contract-tick.lisp",
            "v4/SLICE57.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave58-onion-tick.lisp",
            "samples/bootstrap-v4-wave58-postv4-tick.lisp",
            "v4/SLICE58.md",
        ],
        b_test="samples/bootstrap-v4-wave57-fourtrack-tick.lisp",
        c_test="v4/SLICE58.md",
    ),
    74: dict(
        title="lisp-runner-scout",
        a=52,
        b_track="runner",
        c_track="lisponly",
        b_files=[
            "samples/bootstrap-v4-wave62-runner-tick.lisp",
            "v4/LISP-ONLY.md",
            "v4/DECISION.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave64-lisponly-tick.lisp",
            "samples/bootstrap-v4-lisp-only-tick.lisp",
            "v4/LISP-ONLY.md",
        ],
        b_test="samples/bootstrap-v4-wave62-runner-tick.lisp",
        c_test="v4/LISP-ONLY.md",
    ),
    75: dict(
        title="codegen-emit-deep",
        a=53,
        b_track="emit",
        c_track="codegen",
        b_files=[
            "samples/bootstrap-v4-wave65-emit-tick.lisp",
            "samples/bootstrap-v4-codegen-kickoff.lisp",
            "v4/SLICE41.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave61-codegen-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
            "v4/SLICE61.md",
        ],
        b_test="samples/bootstrap-v4-wave65-emit-tick.lisp",
        c_test="v4/SLICE61.md",
    ),
    76: dict(
        title="mindmap-autonomous",
        a=54,
        b_track="mindmap",
        c_track="eval",
        b_files=[
            "samples/bootstrap-v4-wave52-mindmap-tick.lisp",
            "v4/MINDMAP.md",
            "v4/PARALLEL.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave52-progress-tick.lisp",
            "v4/EVAL.md",
            "v4/PROGRESS.md",
        ],
        b_test="v4/MINDMAP.md",
        c_test="v4/EVAL.md",
    ),
    77: dict(
        title="squad-commander-resume",
        a=55,
        b_track="commander",
        c_track="resume",
        b_files=[
            "samples/bootstrap-v4-wave66-commander-tick.lisp",
            "samples/bootstrap-v4-squad-commander-tick.lisp",
            "v4/SLICE66.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave72-resume-tick.lisp",
            "samples/bootstrap-v4-squad-resume-tick.lisp",
            "v4/SLICE72.md",
        ],
        b_test="samples/bootstrap-v4-squad-commander-tick.lisp",
        c_test="v4/SLICE72.md",
    ),
    78: dict(
        title="build-graph-onion",
        a=56,
        b_track="buildgraph",
        c_track="gates",
        b_files=[
            "samples/bootstrap-v4-wave69-buildgraph-tick.lisp",
            "samples/bootstrap-v4-build-graph-wave27.lisp",
            "v4/SLICE69.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave69-gates-tick.lisp",
            "samples/bootstrap-v4-build-gates-plan.lisp",
            "v4/SLICE31.md",
        ],
        b_test="samples/bootstrap-v4-build-graph-wave27.lisp",
        c_test="v4/SLICE31.md",
    ),
    79: dict(
        title="longrun-milestone",
        a=57,
        b_track="longrun",
        c_track="parallel",
        b_files=[
            "v4/LONG-RUN-TODO.md",
            "v4/DECISION.md",
            "v4/REFLECTION.md",
        ],
        c_files=[
            "v4/PARALLEL.md",
            "samples/bootstrap-v4-wave55-autonomous-tick.lisp",
            "v4/SLICE55.md",
        ],
        b_test="v4/LONG-RUN-TODO.md",
        c_test="v4/PARALLEL.md",
    ),
    80: dict(
        title="ir-table-scout-deep",
        a=58,
        b_track="irtable",
        c_track="hostreduce",
        b_files=[
            "samples/bootstrap-v4-wave56-irtable-tick.lisp",
            "samples/bootstrap-v4-wave68-irtable-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
        ],
        c_files=[
            "samples/bootstrap-v4-wave32-diffusion.lisp",
            "samples/bootstrap-v4-wave70-hostreduce-tick.lisp",
            "v4/SLICE32.md",
        ],
        b_test="samples/bootstrap-v4-wave68-irtable-tick.lisp",
        c_test="samples/bootstrap-v4-wave70-hostreduce-tick.lisp",
    ),
    81: dict(
        title="emit-manifest-chain",
        a=59,
        b_track="emit",
        c_track="manifest",
        b_files=[
            "samples/bootstrap-v4-wave65-emit-tick.lisp",
            "samples/bootstrap-v4-codegen-kickoff.lisp",
            "v4/SLICE41.md",
        ],
        c_files=[
            "samples/v4-plan-manifest-v1.lisp",
            "samples/bootstrap-v4-wave48-manifest-tick.lisp",
            "v4/SLICE48.md",
        ],
        b_test="samples/bootstrap-v4-wave65-emit-tick.lisp",
        c_test="samples/v4-plan-manifest-v1.lisp",
    ),
    82: dict(
        title="four-track-autonomous",
        a=60,
        b_track="fourtrack",
        c_track="contract",
        b_files=[
            "samples/bootstrap-v4-wave57-fourtrack-tick.lisp",
            "samples/bootstrap-v4-wave73-fourtrack-tick.lisp",
            "v4/SLICE57.md",
        ],
        c_files=[
            "samples/bootstrap-v4-plan-contract-tick.lisp",
            "samples/bootstrap-v4-wave71-contract-tick.lisp",
            "v4/SLICE34.md",
        ],
        b_test="samples/bootstrap-v4-wave73-fourtrack-tick.lisp",
        c_test="samples/bootstrap-v4-wave71-contract-tick.lisp",
    ),
    83: dict(
        title="reflection-resume-deep",
        a=61,
        b_track="reflection",
        c_track="resume",
        b_files=[
            "samples/bootstrap-v4-wave63-mindmap-tick.lisp",
            "v4/REFLECTION.md",
            "v4/SLICE63.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave72-resume-tick.lisp",
            "samples/bootstrap-v4-squad-resume-tick.lisp",
            "v4/SLICE72.md",
        ],
        b_test="samples/bootstrap-v4-wave63-mindmap-tick.lisp",
        c_test="samples/bootstrap-v4-wave72-resume-tick.lisp",
    ),
    84: dict(
        title="lisp-only-terminal",
        a=62,
        b_track="lisponly",
        c_track="terminal",
        b_files=[
            "samples/bootstrap-v4-wave64-lisponly-tick.lisp",
            "v4/LISP-ONLY.md",
            "v4/SLICE64.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave67-terminal-tick.lisp",
            "samples/bootstrap-v4-terminal-build-evidence.lisp",
            "v4/SLICE58.md",
        ],
        b_test="samples/bootstrap-v4-wave64-lisponly-tick.lisp",
        c_test="samples/bootstrap-v4-wave67-terminal-tick.lisp",
    ),
    85: dict(
        title="codegen-emit-milestone",
        a=63,
        b_track="codegen",
        c_track="emit",
        b_files=[
            "samples/bootstrap-v4-wave61-codegen-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
            "v4/SLICE61.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave65-emit-tick.lisp",
            "samples/bootstrap-v4-codegen-kickoff.lisp",
            "v4/SLICE41.md",
        ],
        b_test="samples/bootstrap-v4-wave61-codegen-tick.lisp",
        c_test="samples/bootstrap-v4-wave65-emit-tick.lisp",
    ),
    86: dict(
        title="runner-plan-deep",
        a=64,
        b_track="runner",
        c_track="plan",
        b_files=[
            "samples/bootstrap-v4-wave62-runner-tick.lisp",
            "v4/LISP-ONLY.md",
            "v4/DECISION.md",
        ],
        c_files=[
            "samples/bootstrap-v4-plan-contract-tick.lisp",
            "v4/SLICE34.md",
            "v4/DECISION.md",
        ],
        b_test="samples/bootstrap-v4-wave62-runner-tick.lisp",
        c_test="v4/SLICE34.md",
    ),
    87: dict(
        title="squad-evidence-chain",
        a=65,
        b_track="assess",
        c_track="evmatrix",
        b_files=[
            "samples/bootstrap-v4-wave42-assess-bundle-tick.lisp",
            "samples/bootstrap-v4-squad-assess-once.lisp",
            "v4/SLICE42.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave48-manifest-tick.lisp",
            "samples/bootstrap-v4-evidence-matrix.lisp",
            "v4/SLICE48.md",
        ],
        b_test="samples/bootstrap-v4-squad-assess-once.lisp",
        c_test="v4/SLICE48.md",
    ),
    88: dict(
        title="onion-mindmap-close",
        a=66,
        b_track="onion",
        c_track="mindmap",
        b_files=[
            "samples/bootstrap-v4-wave58-onion-tick.lisp",
            "v4/MINDMAP.md",
            "v4/PARALLEL.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave52-mindmap-tick.lisp",
            "v4/EVAL.md",
            "v4/PROGRESS.md",
        ],
        b_test="v4/MINDMAP.md",
        c_test="v4/EVAL.md",
    ),
    89: dict(
        title="host-reduce-recap",
        a=67,
        b_track="hostreduce",
        c_track="buildgraph",
        b_files=[
            "samples/bootstrap-v4-wave56-host-reduce-tick.lisp",
            "samples/bootstrap-v4-wave70-hostreduce-tick.lisp",
            "v4/SLICE32.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave33-diffusion.lisp",
            "samples/bootstrap-v4-build-graph-wave27.lisp",
            "v4/SLICE33.md",
        ],
        b_test="samples/bootstrap-v4-wave56-host-reduce-tick.lisp",
        c_test="v4/SLICE33.md",
    ),
    90: dict(
        title="ir-table-chain",
        a=68,
        b_track="irtable",
        c_track="chain",
        b_files=[
            "samples/bootstrap-v4-wave56-irtable-tick.lisp",
            "samples/bootstrap-v4-wave80-irtable-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
        ],
        c_files=[
            "samples/bootstrap-v4-wave55-diffusion.lisp",
            "v4/SLICE56.md",
            "samples/bootstrap-v4-wave56-diffusion.lisp",
        ],
        b_test="samples/v4-ir-table-v1.lisp",
        c_test="v4/SLICE56.md",
    ),
    91: dict(
        title="four-track-recap",
        a=69,
        b_track="fourtrack",
        c_track="contract",
        b_files=[
            "samples/bootstrap-v4-wave73-fourtrack-tick.lisp",
            "samples/bootstrap-v4-wave82-fourtrack-tick.lisp",
            "v4/SLICE73.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave71-contract-tick.lisp",
            "samples/bootstrap-v4-plan-contract-tick.lisp",
            "v4/SLICE71.md",
        ],
        b_test="samples/bootstrap-v4-wave73-fourtrack-tick.lisp",
        c_test="v4/SLICE71.md",
    ),
    92: dict(
        title="longrun-skill-anchor",
        a=70,
        b_track="longrun",
        c_track="parallel",
        b_files=[
            "v4/LONG-RUN-TODO.md",
            "v4/longrun-state.json",
            "v4/MINDMAP.md",
        ],
        c_files=[
            "v4/PARALLEL.md",
            "samples/bootstrap-v4-wave55-autonomous-tick.lisp",
            "v4/MINDMAP.md",
        ],
        b_test="v4/LONG-RUN-TODO.md",
        c_test="v4/MINDMAP.md",
    ),
    93: dict(
        title="squad-commander-chain",
        a=71,
        b_track="commander",
        c_track="assess",
        b_files=[
            "samples/bootstrap-v4-squad-commander-tick.lisp",
            "samples/bootstrap-v4-wave66-commander-tick.lisp",
            "v4/SLICE66.md",
        ],
        c_files=[
            "samples/bootstrap-v4-squad-assess-once.lisp",
            "samples/bootstrap-v4-wave42-assess-bundle-tick.lisp",
            "v4/SLICE42.md",
        ],
        b_test="samples/bootstrap-v4-squad-commander-tick.lisp",
        c_test="samples/bootstrap-v4-squad-assess-once.lisp",
    ),
    94: dict(
        title="codegen-table-deep",
        a=72,
        b_track="codegen",
        c_track="emit",
        b_files=[
            "samples/bootstrap-v4-wave61-codegen-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
            "v4/SLICE61.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave65-emit-tick.lisp",
            "samples/bootstrap-v4-codegen-kickoff.lisp",
            "v4/SLICE41.md",
        ],
        b_test="samples/v4-ir-table-v1.lisp",
        c_test="samples/bootstrap-v4-codegen-kickoff.lisp",
    ),
    95: dict(
        title="runner-lisp-only",
        a=73,
        b_track="runner",
        c_track="lisponly",
        b_files=[
            "samples/bootstrap-v4-wave62-runner-tick.lisp",
            "v4/LISP-ONLY.md",
            "v4/DECISION.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave64-lisponly-tick.lisp",
            "samples/bootstrap-v4-lisp-only-tick.lisp",
            "v4/LISP-ONLY.md",
        ],
        b_test="v4/LISP-ONLY.md",
        c_test="v4/DECISION.md",
    ),
    96: dict(
        title="build-graph-recap",
        a=74,
        b_track="buildgraph",
        c_track="gates",
        b_files=[
            "samples/bootstrap-v4-build-graph-wave27.lisp",
            "samples/bootstrap-v4-wave69-buildgraph-tick.lisp",
            "v4/SLICE69.md",
        ],
        c_files=[
            "samples/bootstrap-v4-build-gates-plan.lisp",
            "samples/bootstrap-v4-wave69-gates-tick.lisp",
            "v4/SLICE31.md",
        ],
        b_test="samples/bootstrap-v4-build-graph-wave27.lisp",
        c_test="v4/SLICE31.md",
    ),
    97: dict(
        title="mindmap-eval-close",
        a=75,
        b_track="mindmap",
        c_track="eval",
        b_files=[
            "v4/MINDMAP.md",
            "samples/bootstrap-v4-wave52-mindmap-tick.lisp",
            "v4/PARALLEL.md",
        ],
        c_files=[
            "v4/EVAL.md",
            "v4/PROGRESS.md",
            "samples/bootstrap-v4-wave52-progress-tick.lisp",
        ],
        b_test="v4/MINDMAP.md",
        c_test="v4/EVAL.md",
    ),
    98: dict(
        title="evidence-matrix-recap",
        a=76,
        b_track="evmatrix",
        c_track="resume",
        b_files=[
            "samples/bootstrap-v4-evidence-matrix.lisp",
            "samples/bootstrap-v4-wave72-evmatrix-tick.lisp",
            "v4/SLICE72.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave72-resume-tick.lisp",
            "samples/bootstrap-v4-squad-resume-tick.lisp",
            "v4/SLICE60.md",
        ],
        b_test="samples/bootstrap-v4-evidence-matrix.lisp",
        c_test="v4/SLICE72.md",
    ),
    99: dict(
        title="terminal-onion",
        a=77,
        b_track="terminal",
        c_track="onion",
        b_files=[
            "samples/bootstrap-v4-wave67-terminal-tick.lisp",
            "samples/bootstrap-v4-terminal-build-evidence.lisp",
            "v4/SLICE58.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave58-onion-tick.lisp",
            "samples/bootstrap-v4-wave40-onion-tick.lisp",
            "v4/SLICE40.md",
        ],
        b_test="samples/bootstrap-v4-terminal-build-evidence.lisp",
        c_test="v4/SLICE58.md",
    ),
    100: dict(
        title="ir-words-scout",
        a=78,
        b_track="irwords",
        c_track="irtable",
        b_files=[
            "samples/bootstrap-v4-wave44-diffusion.lisp",
            "samples/v4-ir-words-v2.txt",
            "v4/SLICE44.md",
        ],
        c_files=[
            "samples/bootstrap-v4-wave56-irtable-tick.lisp",
            "samples/v4-ir-table-v1.lisp",
            "v4/SLICE56.md",
        ],
        b_test="samples/v4-ir-words-v2.txt",
        c_test="samples/v4-ir-table-v1.lisp",
    ),
    101: dict(
        title="post-v4-anchor",
        a=79,
        b_track="postv4",
        c_track="scoped",
        b_files=[
            "samples/bootstrap-v4-wave49-postv4-tick.lisp",
            "samples/bootstrap-v4-wave58-postv4-tick.lisp",
            "v4/POST-V4.md",
        ],
        c_files=[
            "v4/COMPLETE-SCOPED.md",
            "samples/bootstrap-v4-wave46-kickoff-tick.lisp",
            "v4/SLICE46.md",
        ],
        b_test="v4/POST-V4.md",
        c_test="v4/COMPLETE-SCOPED.md",
    ),
    102: dict(
        title="autonomous-milestone-2",
        a=80,
        b_track="autonomous",
        c_track="longrun",
        b_files=[
            "samples/bootstrap-v4-wave55-autonomous-tick.lisp",
            "v4/DECISION.md",
            "v4/SLICE55.md",
        ],
        c_files=[
            "v4/LONG-RUN-TODO.md",
            "v4/longrun-state.json",
            "v4/MINDMAP.md",
        ],
        b_test="v4/DECISION.md",
        c_test="v4/LONG-RUN-TODO.md",
    ),
    103: dict(
        title="orchestration-bundle",
        a=81,
        b_track="orchestration",
        c_track="dispatch",
        b_files=[
            "samples/bootstrap-v4-squad-orchestration-bundle.lisp",
            "samples/bootstrap-v4-wave36-orchestration-tick.lisp",
            "v4/SLICE36.md",
        ],
        c_files=[
            "samples/bootstrap-v4-squad-dispatch.lisp",
            "samples/bootstrap-v4-squad-run-loop-once.lisp",
            "v4/SQUAD.md",
        ],
        b_test="samples/bootstrap-v4-squad-orchestration-bundle.lisp",
        c_test="v4/SQUAD.md",
    ),
}


def write_tick(wave: int, track: str, label: str, files: list[str]) -> str:
    name = f"bootstrap-v4-wave{wave}-{track}-tick.lisp"
    lines = [f"; wave{wave} track-{label}: {track}."]
    lines.append("(bootstrap")
    for i, f in enumerate(files):
        op = "file-hash" if i == len(files) - 1 else "file-size"
        lines.append(f'  ({op} "lab/nano-lisp-jit/{f}")')
    lines.append(")\n")
    (SAMPLES / name).write_text("\n".join(lines))
    return name


def gen_wave(wave: int, cfg: dict) -> dict:
    a = cfg["a"]
    expect = a + 17
    title = cfg["title"]
    (SAMPLES / f"nano-jit-slice-add-{expect}.lisp").write_text(
        f"; wave{wave}: add {a}+17={expect}.\n"
        "(module\n"
        "  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))\n"
        f"  (main (i64 {a}) (save-top-i64) (i64 17) (call add) (expect {expect})))\n"
    )
    (SAMPLES / f"bootstrap-v4-wave{wave}-diffusion.lisp").write_text(
        f"; wave{wave} track-A: {title}.\n"
        "(bootstrap\n"
        '  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")\n'
        f'  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-{expect}.lisp"\n'
        f'                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice{wave}-add{expect}.elf"\n'
        '                    "aarch64")\n'
        '  (squad-assess "lab/nano-lisp-jit/squad/catalog-v4.yaml")\n'
        '  (results-min "lab/nano-lisp-jit/.build/nano-jit/bootstrap-report.txt" "build.pass" "26")\n'
        '  (results-min "lab/nano-lisp-jit/.build/results.txt" "tests.pass" "270")\n'
        f'  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice{wave}-add{expect}.elf"))\n'
    )
    b_file = write_tick(wave, cfg["b_track"], "B", cfg["b_files"])
    c_file = write_tick(wave, cfg["c_track"], "C", cfg["c_files"])
    (SAMPLES / f"bootstrap-v4-slice{wave}-evidence.lisp").write_text(
        f"; wave{wave} evidence.\n"
        "(bootstrap\n"
        f'  (file-size "lab/nano-lisp-jit/v4/SLICE{wave}.md")\n'
        f'  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice{wave}-add{expect}.elf"))\n'
    )
    (ROOT / "v4" / f"SLICE{wave}.md").write_text(
        f"# v4 wave{wave} — {title}\n\n"
        "长程自主 · [`EVAL.md`](EVAL.md) · [`LONG-RUN-TODO.md`](LONG-RUN-TODO.md)。\n"
    )
    return dict(wave=wave, expect=expect, title=title, b_track=cfg["b_track"],
                c_track=cfg["c_track"], b_test=cfg["b_test"], c_test=cfg["c_test"])


def patch_bootstrap(expects: list[int]) -> None:
    import re

    c = Path("/workspace/lab/lispjit-ir/nano_bootstrap.c")
    t = c.read_text()
    last = max(expects)
    if f'add-{last})' in t:
        return
    nums = [int(x) for x in re.findall(r'strstr\(base, "add-(\d+)"\)', t)]
    if not nums:
        raise SystemExit("bootstrap add-N pattern not found")
    hi = max(nums)
    new_adds = [e for e in sorted(set(expects)) if e > hi]
    if not new_adds:
        return
    anchor = f'        strstr(base, "add-{hi}")) {{'
    if anchor not in t:
        raise SystemExit(f"bootstrap anchor add-{hi} not found")
    extra = " ||\n        ".join(f'strstr(base, "add-{e}")' for e in new_adds)
    t = t.replace(anchor, f'        strstr(base, "add-{hi}") ||\n        {extra}) {{')
    c.write_text(t)


def patch_run(meta: list[dict]) -> None:
    run = RUN.read_text()
    vars_lines = []
    cases = []
    for m in meta:
        w, e = m["wave"], m["expect"]
        bt, ct = m["b_track"], m["c_track"]
        vars_lines += [
            f'BOOTSTRAP_V4_WAVE{w}_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave{w}-diffusion.lisp"',
            f'BOOTSTRAP_V4_WAVE{w}_{bt.upper()}_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave{w}-{bt}-tick.lisp"',
            f'BOOTSTRAP_V4_WAVE{w}_{ct.upper()}_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave{w}-{ct}-tick.lisp"',
            f'BOOTSTRAP_V4_SLICE{w}_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice{w}-evidence.lisp"',
            f'V4_SLICE{w}_ADD{e}_ELF="$BUILD_DIR/bootstrap-v4-slice{w}-add{e}.elf"',
            f'V4_SLICE{w}_EVIDENCE="$BUILD_DIR/v4-slice{w}.evidence"',
        ]
        btest, ctest = m["b_test"], m["c_test"]
        cases.append(f'''
run_case "run-bootstrap-v4-wave{w}-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE{w}_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s\\n" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE{w}_ADD{e}_ELF"'"
'
run_case "run-bootstrap-v4-wave{w}-{bt}-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE{w}_{bt.upper()}_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/{btest}"
'
run_case "run-bootstrap-v4-wave{w}-{ct}-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE{w}_{ct.upper()}_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/{ctest}"
'
run_case "run-bootstrap-v4-slice{w}-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE{w}_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE{w}.md"
  {{ echo "v4.slice{w}=1"; }} >> "'"$V4_SLICE{w}_EVIDENCE"'"
'
''')
    block = "\n".join(vars_lines) + "\n"
    if f"V4_SLICE{meta[0]['wave']}_ADD" not in run:
        for anchor in (
            'V4_SLICE97_EVIDENCE="$BUILD_DIR/v4-slice97.evidence"\n',
            'V4_SLICE91_EVIDENCE="$BUILD_DIR/v4-slice91.evidence"\n',
            'V4_SLICE88_EVIDENCE="$BUILD_DIR/v4-slice88.evidence"\n',
            'V4_SLICE85_EVIDENCE="$BUILD_DIR/v4-slice85.evidence"\n',
            'V4_SLICE82_EVIDENCE="$BUILD_DIR/v4-slice82.evidence"\n',
            'V4_SLICE79_EVIDENCE="$BUILD_DIR/v4-slice79.evidence"\n',
            'V4_SLICE76_EVIDENCE="$BUILD_DIR/v4-slice76.evidence"\n',
            'V4_SLICE73_EVIDENCE="$BUILD_DIR/v4-slice73.evidence"\n',
            'V4_SLICE67_EVIDENCE="$BUILD_DIR/v4-slice67.evidence"\n',
        ):
            if anchor in run:
                run = run.replace(anchor, anchor + block)
                break
    ins = "".join(cases)
    if f"run-bootstrap-v4-wave{meta[0]['wave']}-diffusion-plan" not in run:
        for marker in (
            'run_case "run-bootstrap-v4-slice97-evidence-plan"',
            'run_case "run-bootstrap-v4-slice91-evidence-plan"',
            'run_case "run-bootstrap-v4-slice88-evidence-plan"',
            'run_case "run-bootstrap-v4-slice85-evidence-plan"',
            'run_case "run-bootstrap-v4-slice82-evidence-plan"',
            'run_case "run-bootstrap-v4-slice79-evidence-plan"',
            'run_case "run-bootstrap-v4-slice76-evidence-plan"',
            'run_case "run-bootstrap-v4-slice16-plan-words-plan"',
            'run_case "run-bootstrap-v4-slice73-evidence-plan"',
        ):
            if marker in run:
                run = run.replace(marker, ins + marker)
                break
    RUN.write_text(run)


RUN = ROOT / "run.sh"
CAT = ROOT / "squad" / "catalog-v4.yaml"
INDEX = SAMPLES / "v4-wave-index-v1.lisp"


def patch_catalog(meta: list[dict], section: str) -> None:
    t = CAT.read_text()
    if "id: v4-slice9-scoped" in t and "terminal_gates:" not in t:
        # slim catalog: wave batch gates live in run.sh only; still append tasks
        gates = []
    gates = []
    tasks = []
    for m in meta:
        w, e = m["wave"], m["expect"]
        bt, ct = m["b_track"], m["c_track"]
        gates += [
            f"    - id: v4-slice{w}-doc",
            f'      check: artifact',
            f'      path_glob: "v4/SLICE{w}.md"',
            f"    - id: v4-wave{w}-diffusion-plan",
            f'      check: artifact',
            f'      path_glob: "samples/bootstrap-v4-wave{w}-diffusion.lisp"',
            f"    - id: v4-slice{w}-add{e}-elf",
            f'      check: artifact',
            f'      path_glob: ".build/bootstrap-v4-slice{w}-add{e}.elf"',
            f"    - id: v4-wave{w}-{bt}-b-tick",
            f'      check: artifact',
            f'      path_glob: "samples/bootstrap-v4-wave{w}-{bt}-tick.lisp"',
            f"    - id: v4-wave{w}-{ct}-c-tick",
            f'      check: artifact',
            f'      path_glob: "samples/bootstrap-v4-wave{w}-{ct}-tick.lisp"',
            f"    - id: v4-slice{w}-evidence",
            f'      check: results',
            f'      file: ".build/v4-slice{w}.evidence"',
            f"      results_key: v4.slice{w}",
            f"      min_pass: 1",
            "",
        ]
        tasks += [
            f"  wave{w}-v4-track-a-codegen:",
            f"    assign_role: engineer-a",
            f"    priority: P0",
            f"    touch_paths:",
            f'      - "samples/bootstrap-v4-wave{w}-diffusion.lisp"',
            f'      - "samples/nano-jit-slice-add-{e}.lisp"',
            f'      - "run.sh"',
            f"    accept:",
            f'      - "run-bootstrap-v4-wave{w}-diffusion-plan"',
            f"  wave{w}-v4-track-b-{bt}:",
            f"    assign_role: engineer-b",
            f"    priority: P0",
            f"    touch_paths:",
            f'      - "samples/bootstrap-v4-wave{w}-{bt}-tick.lisp"',
            f'      - "run.sh"',
            f"    accept:",
            f'      - "run-bootstrap-v4-wave{w}-{bt}-tick-plan"',
            f"  wave{w}-v4-track-c-{ct}:",
            f"    assign_role: engineer-b",
            f"    priority: P0",
            f"    touch_paths:",
            f'      - "samples/bootstrap-v4-wave{w}-{ct}-tick.lisp"',
            f'      - "run.sh"',
            f"    accept:",
            f'      - "run-bootstrap-v4-wave{w}-{ct}-tick-plan"',
            f"  wave{w}-v4-track-d-evidence:",
            f"    assign_role: engineer-b",
            f"    priority: P0",
            f"    touch_paths:",
            f'      - "v4/SLICE{w}.md"',
            f'      - "run.sh"',
            f"    accept:",
            f'      - "run-bootstrap-v4-slice{w}-evidence-plan"',
            f"  wave{w}-v4-R:",
            f"    assign_role: reviewer",
            f"    priority: meta",
            f"    depends: [wave{w}-v4-track-a-codegen, wave{w}-v4-track-b-{bt}, wave{w}-v4-track-c-{ct}, wave{w}-v4-track-d-evidence]",
            f"    accept:",
            f'      - "v4/EVAL.md {section}"',
            f'      - "assess v4-complete ready"',
            "",
        ]
    gblock = "\n".join(gates)
    if f"v4-slice{meta[0]['wave']}-doc" not in t:
        t = t.replace("\n  terminal_gates:", "\n" + gblock + "\n  terminal_gates:")
    tblock = "\n".join(tasks)
    if f"wave{meta[0]['wave']}-v4-track-a-codegen" not in t:
        t = t.replace("\n\nverify:", "\n" + tblock + "\n\nverify:")
    CAT.write_text(t)


def patch_index(meta: list[dict]) -> None:
    t = INDEX.read_text()
    for m in meta:
        w, title = m["wave"], m["title"]
        line = f'  (wave {w} "{title}")'
        if line not in t:
            pos = t.rfind("\n)")
            if pos == -1:
                raise SystemExit("wave index closing paren not found")
            t = t[:pos] + "\n" + line + t[pos:]
    INDEX.write_text(t)


if __name__ == "__main__":
    lo = int(sys.argv[1]) if len(sys.argv) > 1 else 68
    hi = int(sys.argv[2]) if len(sys.argv) > 2 else 73
    meta = [gen_wave(w, WAVES[w]) for w in range(lo, hi + 1)]
    expects = [m["expect"] for m in meta]
    patch_bootstrap([e for e in expects if e > 62])
    patch_run(meta)
    section = f"wave{lo}–{hi}" if lo != hi else f"wave{lo}"
    patch_catalog(meta, section)
    patch_index(meta)
    print("ok", [m["wave"] for m in meta], "add", expects)
