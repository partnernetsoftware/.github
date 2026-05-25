#!/usr/bin/env python3
"""Replace v4.5 run_case wall with single wave3 converge case."""
from pathlib import Path

RUN = Path(__file__).resolve().parents[1] / "run.sh"
lines = RUN.read_text(encoding="utf-8").splitlines(keepends=True)
start = end = None
for i, line in enumerate(lines):
    if line.startswith("# --- v4.5 tier0:"):
        start = i
    if start is not None and line.startswith("# --- layer4 zero-host:"):
        end = i
        break
if start is None or end is None:
    raise SystemExit("v4.5 block markers not found")
block = """# --- v4.5: Wave6 single converge (replaces per-plan run_case blocks) ---
V45_WAVE6_CONVERGE="$LAB_DIR/scripts/v45-wave6-converge.sh"
if [ -f "$NANO_JIT_COM" ] && host_is_linux_x86_64 && [ -x "$V45_WAVE6_CONVERGE" ]; then
  run_case "run-bootstrap-v45-wave6-converge-plan" bash -c '
    cd "'"$ROOT_DIR"'" && bash "'"$V45_WAVE6_CONVERGE"'"
    grep -q v45.scoped.100=1 "'"$V45_ENTRY_EVIDENCE"'"
    grep -q v45.wave6.diffuse=1 "'"$V45_ENTRY_EVIDENCE"'"
    grep -q v45.onion.primary_lisp_only=1 "'"$V45_ENTRY_EVIDENCE"'"
    grep -q v45.w3_com.minimal_probe=1 "'"$V45_ENTRY_EVIDENCE"'"
  '
else
  skip_case "run-bootstrap-v45-wave6-converge-plan" "nano-jit.com or v45-wave6-converge.sh missing"
fi

"""
lines[start:end] = [block]
RUN.write_text("".join(lines), encoding="utf-8")
print(f"replaced run.sh lines {start+1}-{end} ({end-start} lines -> {block.count(chr(10))} lines)")
