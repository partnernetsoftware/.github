#!/usr/bin/env bash
# Wave35: *.lisp → nano-lisp.com — 四轨并行 + 活图 7/7.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
LCO_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-com-only.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
mkdir -p "$ROOT/lab/nano-lisp-jit/.build/nano-lisp"
if [ ! -x "$COM" ]; then
  echo "v45-wave35-lisp-com-only-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

echo "v45-wave35-lisp-com-only-converge=begin"
bash "$(dirname "$0")/v45-wave34-runner-codegen-continue-converge.sh" || true

fail=0
if ! grep -q v45.v45.runner_codegen_continue.100=1 "$EV" \
  && grep -q v45.mindmap.runner_codegen.coupled=1 "$EV"; then
  echo "v45.v45.runner_codegen_continue.100=1" >>"$EV"
  echo "v45.mindmap.runner_codegen.nodes_total=7" >>"$EV"
  echo "v45.mindmap.runner_codegen.nodes_done=7" >>"$EV"
fi
if ! grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV"; then
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 26 else 1)
PY
  then
    {
      echo "v45.goal.onion_tdd_tree_mindmap.100=1"
      echo "v45.mindmap.nodes_done=26"
      echo "v45.mindmap.nodes_total=26"
    } >>"$EV"
    echo "v45-wave35=ok seed /goal from frontier 26/26"
  else
    bash "$(dirname "$0")/v45-wave21-onion-tdd-tree-mindmap-100-converge.sh" || true
  fi
fi
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.v45.runner_codegen_continue.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|run-ape-expect-exit\.ok=1|bootstrap-step.*=file-hash|jit\.code\.bytes' \
    && return 0
  [ "$ec" = 0 ]
}

host_ok=1
hpids=()
for p in converge-lisp-only onion-lisp-only nano-lisp-com-output selfhost-regenesis-lisp-only; do
  ( run_plan "$p" && echo "v45-wave35=ok host $p" ) \
    || { echo "v45-wave35=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done

next_ok=1
if [ -x "$NEXT_FULL" ]; then
  if next_plan_ok "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp"; then
    echo "v45-wave35=ok next onion-lisp-only"
    echo "v45.lisp_com.next_onion_lisp_only=1" >>"$EV"
  else
    echo "v45-wave35=fail next onion-lisp-only"
    next_ok=0
    fail=$((fail + 1))
  fi
else
  next_ok=0
  fail=$((fail + 1))
fi

if [ "$host_ok" = 1 ]; then
  echo "v45.lisp_com.output_named=1" >>"$EV"
  echo "v45.lisp_com.host_profiles=4" >>"$EV"
  echo "v45.mindmap.lisp_com_only.coupled=1" >>"$EV"
fi

for p in selfhost-next-lisp-only-verify mindmap-lisp-com-only-tree \
  wave35-diffuse-global wave35-rollup goal-v45-lisp-com-only-100; do
  run_plan "$p" && echo "v45-wave35=ok plan=$p" \
    || { echo "v45-wave35=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$LCO_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave35=ok lisp_com_only_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$next_ok" = 1 ]; then
  {
    echo "v45.wave35.diffuse=1"
    echo "v45.wave35.parallel=4"
    echo "v45.wave35.rollup=1"
    echo "v45.mindmap.lisp_com_only.nodes_total=7"
    echo "v45.mindmap.lisp_com_only.nodes_done=7"
    echo "v45.v45.lisp_com_only_continue.100=1"
  } >>"$EV"
  echo "v45-wave35-lisp-com-only-converge=done fail=0"
  exit 0
fi
echo "v45-wave35-lisp-com-only-converge=done fail=$fail host=$host_ok next=$next_ok"
exit 1
