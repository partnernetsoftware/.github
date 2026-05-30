#!/usr/bin/env bash
# Wave23: v4.5 继续 — wave22 工厂 + 代际矩阵 + v4 握手 + /goal 复核.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_LO="$ROOT/lab/nano-lisp-jit/.build/v45-next-lisp-only.com"
CHAIN_LO="$ROOT/lab/nano-lisp-jit/.build/v45-chain-lo-next.com"
SMOKE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp"
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave23-continue-converge=skip missing_com"
  exit 0
fi
echo "v45-wave23-continue-converge=begin"
bash "$(dirname "$0")/v45-wave22-factory-lisp-only-converge.sh" || fail=$((fail + 1))

smoke_ok() {
  local com=$1 name=$2
  local out ec=0
  out=$("$com" run-bootstrap-plan "$SMOKE" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1' && return 0
  [ "$ec" = 0 ] || [ "$ec" = 42 ]
}

matrix_ok=1
pids=()
for spec in "next-lo:$NEXT_LO" "chain-lo:$CHAIN_LO"; do
  name=${spec%%:*}
  com=${spec#*:}
  if [ ! -x "$com" ]; then
    echo "v45-wave23=fail missing $name"
    matrix_ok=0
    continue
  fi
  ( smoke_ok "$com" "$name" && echo "v45-wave23=ok matrix $name" ) \
    || { echo "v45-wave23=fail matrix $name"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || matrix_ok=0; done
if [ "$matrix_ok" = 1 ]; then
  echo "v45.factory.next_lisp_only_matrix=1" >>"$EV"
fi

python3 - <<'PY' || fail=$((fail + 1))
import json
from pathlib import Path
v4 = Path("lab/nano-lisp-jit/v4/mindmap-frontier.json")
d = json.loads(v4.read_text())
done = sum(1 for n in d["nodes"] if n["status"] == "done")
total = len(d["nodes"])
print(f"v45-wave23=v4_frontier {done}/{total}")
if done != total or total != 69:
    raise SystemExit(1)
PY
echo "v45.v4.handoff.verified=1" >>"$EV"
echo "v45.v4.handoff.nodes_done=69" >>"$EV"
echo "v45.v4.handoff.nodes_total=69" >>"$EV"

"$COM" run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-v4-handoff.lisp >/dev/null \
  && echo "v45-wave23=ok v4-handoff" || { echo "v45-wave23=fail v4-handoff"; fail=$((fail + 1)); }

for p in factory-next-lisp-only-matrix mindmap-v4-handoff-bridge goal-v45-continue-100; do
  "$COM" run-bootstrap-plan "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" >/dev/null \
    && echo "v45-wave23=ok plan=$p" \
    || { echo "v45-wave23=fail plan=$p"; fail=$((fail + 1)); }
done

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$matrix_ok" = 1 ]; then
  {
    echo "v45.wave23.diffuse=1"
    echo "v45.wave23.rollup=1"
    echo "v45.v45.continue.100=1"
  } >>"$EV"
  echo "v45-wave23-continue-converge=done fail=0"
  exit 0
fi
echo "v45-wave23-continue-converge=done fail=$fail matrix=$matrix_ok"
exit 1
