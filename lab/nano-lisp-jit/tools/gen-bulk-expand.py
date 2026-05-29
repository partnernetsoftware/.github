#!/usr/bin/env python3
"""Generate bulk .text expand lisp modules with N funcs; main exits 42."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def func_body(i: int) -> str:
    add = (i % 7) + 1
    name = f"f{i:03d}"
    return (
        f"  (func {name}\n"
        f"    (u64 {i})\n"
        f"    (add-u64 {add}))"
    )


def main_calls(n: int, call_limit: int | None = None) -> list[str]:
    limit = min(n, call_limit if call_limit is not None else 20)
    return [f"    (call f{i:03d})" for i in range(limit)]


def render(header: str, n: int, call_limit: int | None = None) -> str:
    funcs = "\n".join(func_body(i) for i in range(n))
    calls = "\n".join(main_calls(n, call_limit))
    return (
        f"; {header}\n"
        f"(module\n"
        f"{funcs}\n"
        f"  (main\n"
        f"{calls}\n"
        f"    (u64 41)\n"
        f"    (add-u64 1)\n"
        f"    (expect 42)))\n"
    )


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("-n", "--count", type=int, default=80, help="number of funcs")
    p.add_argument(
        "--main-calls",
        type=int,
        default=20,
        help="how many funcs main calls before exit 42 (default 20)",
    )
    p.add_argument(
        "--header",
        default="bulk expand auto-gen",
        help="leading semicolon comment",
    )
    p.add_argument(
        "-o",
        "--output",
        type=Path,
        help="write to file (default stdout)",
    )
    return p.parse_args()


def main() -> int:
    args = parse_args()
    if args.count < 1:
        print("count must be >= 1", file=sys.stderr)
        return 2
    if args.main_calls < 0:
        print("main-calls must be >= 0", file=sys.stderr)
        return 2

    text = render(args.header, args.count, args.main_calls)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text, encoding="utf-8")
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
