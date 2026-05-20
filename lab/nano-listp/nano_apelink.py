#!/usr/bin/env python3
import argparse
import os
from pathlib import Path


STUB = """#!/bin/sh
set -eu
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) off=0; size={x86_size}; suffix=x86_64 ;;
  aarch64|arm64) off={arm_off}; size={arm_size}; suffix=aarch64 ;;
  *) echo "nano-apelink: unsupported arch $arch" >&2; exit 126 ;;
esac
payload_line=$(awk '/^__NANO_APE_PAYLOAD_BELOW__$/ {{ print NR + 1; exit }}' "$0")
if [ -z "${{payload_line:-}}" ]; then
  echo "nano-apelink: payload marker missing" >&2
  exit 126
fi
tmp="${{TMPDIR:-/tmp}}/nano-ape-$$-$suffix"
trap 'rm -f "$tmp"' EXIT HUP INT TERM
tail -n +"$payload_line" "$0" | dd bs=1 skip="$off" count="$size" of="$tmp" 2>/dev/null
chmod +x "$tmp"
exec "$tmp" "$@"
exit 127
__NANO_APE_PAYLOAD_BELOW__
"""


def read(path: str) -> bytes:
    data = Path(path).read_bytes()
    if not data.startswith(b"\x7fELF"):
        raise SystemExit(f"input.not_elf path={path}")
    return data


def main() -> int:
    ap = argparse.ArgumentParser(description="tiny stage0 APE packer for nano-listp")
    ap.add_argument("-o", "--output", required=True)
    ap.add_argument("--x86_64", required=True)
    ap.add_argument("--aarch64", required=True)
    args = ap.parse_args()

    x86 = read(args.x86_64)
    arm = read(args.aarch64)
    stub = STUB.format(x86_size=len(x86), arm_off=len(x86), arm_size=len(arm)).encode()
    out = stub + x86 + arm
    Path(args.output).write_bytes(out)
    os.chmod(args.output, 0o755)
    print(f"nano_apelink.output={args.output}")
    print(f"nano_apelink.bytes={len(out)}")
    print(f"nano_apelink.x86_64.bytes={len(x86)}")
    print(f"nano_apelink.aarch64.bytes={len(arm)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
