#!/usr/bin/env bash
# Regenerate archive/c/runner/nano_shell_embed.c from shell-script.lbin (hash-match rs embed).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SRC="$ROOT/lab/nano-lisp-jit/archive/c/embed/shell-script.lbin"
RS="$ROOT/lab/nano-jit-rs/embed/shell-script.lbin"
OUT="$ROOT/lab/nano-lisp-jit/archive/c/runner/nano_shell_embed.c"
OUT_RETIRED="$ROOT/lab/nano-lisp-jit/retired/archive-c/runner/nano_shell_embed.c"

[ -f "$SRC" ] || { echo "gen-shell-embed-c=fail missing $SRC"; exit 1; }
cmp -s "$SRC" "$RS" || { echo "gen-shell-embed-c=fail embed_mismatch c=$SRC rs=$RS"; exit 1; }

python3 - "$SRC" "$OUT" "$OUT_RETIRED" <<'PY'
import sys
from pathlib import Path
src = Path(sys.argv[1]).read_bytes()
lines = []
for i in range(0, len(src), 12):
    chunk = src[i : i + 12]
    hexes = ", ".join(f"0x{b:02x}" for b in chunk)
    lines.append(f"  {hexes},")
body = "\n".join(lines)
text = f"""/* Generated from archive/c/embed/shell-script.lbin — regen: retired/scripts/gen-shell-embed-c.sh */
#include <stddef.h>
static const unsigned char nano_shell_script_lbin[] = {{
{body}
}};
static const size_t nano_shell_script_lbin_len = {len(src)};
"""
for out in sys.argv[2:]:
    Path(out).write_text(text)
print(f"gen-shell-embed-c=ok bytes={len(src)}")
PY
