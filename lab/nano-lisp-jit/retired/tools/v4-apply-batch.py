#!/usr/bin/env python3
"""Deterministic wave batch apply — no cc. Usage: v4-apply-batch.py LO HI"""
from __future__ import annotations
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / "tools" / "gen-v4-wave-batch.py"
EVAL = ROOT / "v4" / "EVAL.md"


def waves_in_gen(lo: int, hi: int) -> list[int]:
    t = GEN.read_text()
    missing = [w for w in range(lo, hi + 1) if f"    {w}: dict(" not in t]
    if missing:
        raise SystemExit(f"WAVES missing in gen-v4-wave-batch.py: {missing}")
    return list(range(lo, hi + 1))


def append_eval(lo: int, hi: int) -> None:
    sec = f"wave{lo}–{hi}" if lo != hi else f"wave{lo}"
    if sec in EVAL.read_text():
        return
    block = f"""
## {sec}（longrun apply · ≤4 轨/波）

| 维度 | wave{hi} 后 | 说明 |
|------|-------------|------|
| Codegen | ~49% | add 续批 verified |
| 终局整体 | **15–22%** | deterministic apply |

**方法**：`v4-apply-batch.py {lo} {hi}` → `run.sh` gate。
"""
    EVAL.write_text(EVAL.read_text().rstrip() + "\n" + block)


def main() -> None:
    lo, hi = int(sys.argv[1]), int(sys.argv[2])
    waves_in_gen(lo, hi)
    subprocess.run([sys.executable, str(GEN), str(lo), str(hi)], check=True, cwd=ROOT)
    append_eval(lo, hi)
    print(f"APPLY_OK {lo}-{hi}")


if __name__ == "__main__":
    main()
