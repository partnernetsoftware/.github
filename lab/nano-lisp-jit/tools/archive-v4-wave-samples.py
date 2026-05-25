#!/usr/bin/env python3
"""One-shot: move bootstrap-v4-wave*.lisp → archive/samples/v4-waves/ and rewrite run.sh paths."""
from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLES = ROOT / "samples"
ARCHIVE = ROOT / "archive" / "samples" / "v4-waves"
RUN_SH = ROOT / "run.sh"
OLD = "samples/bootstrap-v4-wave"
NEW = "archive/samples/v4-waves/bootstrap-v4-wave"


def main() -> None:
    ARCHIVE.mkdir(parents=True, exist_ok=True)
    moved = 0
    for path in sorted(SAMPLES.glob("bootstrap-v4-wave*.lisp")):
        dest = ARCHIVE / path.name
        if dest.exists():
            continue
        shutil.move(path, dest)
        moved += 1
    text = RUN_SH.read_text(encoding="utf-8")
    count = text.count(OLD)
    if count:
        text = text.replace(OLD, NEW)
        RUN_SH.write_text(text, encoding="utf-8")
    readme = ARCHIVE / "README.md"
    readme.write_text(
        "# v4 wave factory samples (archived)\n\n"
        f"Moved {moved} files from `samples/`. `run.sh` paths use `archive/samples/v4-waves/`.\n",
        encoding="utf-8",
    )
    print(f"archive-v4-wave: moved={moved} run_sh_replacements={count}")


if __name__ == "__main__":
    main()
