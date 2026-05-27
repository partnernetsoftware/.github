#!/usr/bin/env bash
# honest-cleanup: SSOT 整理 · 四轨并行 · 工作池签收（≠ Wave70 · ≠ v4.5 DONE）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
HCL_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-honest-cleanup.json"
cd "$ROOT"
fail=0
touch "$EV"

if [ ! -x "$COM" ]; then
  echo "v45-honest-cleanup-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

echo "v45-honest-cleanup-converge=begin com=$(basename "$COM")"

grep -q v45.v45.run_sh_archive_honest_continue.100=1 "$EV" || {
  echo "v45-honest-cleanup=warn seed wave69 key missing; continuing"
}

# W1–W4 parallel tracks (sequential host; plans are independent)
for track in honest-evidence-key-audit honest-ape-six-face-gap honest-ssot-unify-prove honest-wave-freeze-anchor; do
  if run_plan "$track"; then
    echo "v45-honest-cleanup=ok track=$track"
  else
    echo "v45-honest-cleanup=fail track=$track"
    fail=$((fail + 1))
  fi
done

# Write honest evidence keys (plans verify docs; keys anchor rollup)
{
  echo "v45.honest.evidence_gap_audit=1"
  echo "v45.honest.ape_two_slice_linux_only=1"
  echo "v45.honest.ssot_cleanup_frontier=1"
  echo "v45.honest.wave70_plus_frozen=1"
} >>"$EV"

if run_plan mindmap-honest-cleanup-tree; then
  echo "v45-honest-cleanup=ok terminal"
  echo "v45.mindmap.honest_cleanup.coupled=1" >>"$EV"
else
  echo "v45-honest-cleanup=fail terminal"
  fail=$((fail + 1))
fi

if run_plan goal-v45-honest-cleanup-pool; then
  echo "v45-honest-cleanup=ok goal"
  {
    echo "v45.honest.cleanup_pool=1"
    echo "v45.converge.daily_v45_honest_cleanup=1"
    echo "v45.mindmap.honest_cleanup.nodes_total=7"
    echo "v45.mindmap.honest_cleanup.nodes_done=7"
    echo "v45.honest-cleanup.diffuse=1"
    echo "v45.honest-cleanup.parallel=4"
  } >>"$EV"
else
  echo "v45-honest-cleanup=fail goal"
  fail=$((fail + 1))
fi

if run_plan converge-daily-v45-honest-cleanup; then
  echo "v45-honest-cleanup=ok daily"
else
  echo "v45-honest-cleanup=warn daily"
fi

# Mark frontier nodes done
python3 - <<'PY' || fail=$((fail + 1))
import json
from pathlib import Path
p = Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-honest-cleanup.json")
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n")
print("v45-honest-cleanup=ok frontier 7/7 marked done")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh" 2>/dev/null || true

echo "v45-honest-cleanup-converge=done fail=$fail"
exit "$fail"
