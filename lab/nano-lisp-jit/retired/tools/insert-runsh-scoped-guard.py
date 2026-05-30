#!/usr/bin/env python3
"""Wrap v4+v35 factory block in run.sh with NANO_V45_SCOPED_ONLY guard."""
from pathlib import Path

RUN = Path(__file__).resolve().parents[1] / "run.sh"
lines = RUN.read_text(encoding="utf-8").splitlines(keepends=True)
start = end = None
for i, line in enumerate(lines):
    if line.startswith("# --- v4 kickoff ---"):
        start = i
    if start is not None and line.startswith("# --- v4.5:"):
        end = i
        break
if start is None or end is None:
    raise SystemExit("markers not found")
guard_open = (
    'if [ "${NANO_V45_SCOPED_ONLY:-0}" != 1 ]; then\n'
    '  log "v45.runsh.factory_block=active"\n'
)
guard_close = (
    "else\n"
    '  log "v45.runsh.factory_block=skipped NANO_V45_SCOPED_ONLY"\n'
    "fi\n\n"
)
block = lines[start:end]
lines[start:end] = [guard_open] + ["  " + ln if ln.strip() else ln for ln in block] + [guard_close]
RUN.write_text("".join(lines), encoding="utf-8")
print(f"wrapped lines {start + 1}-{end} ({end - start} lines)")
