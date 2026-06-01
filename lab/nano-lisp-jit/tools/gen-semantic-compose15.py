#!/usr/bin/env python3
"""Generate semantic compose15 expand modules (lisp/modules-semantic, not bulk-expand)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEM_DIR = ROOT / "lisp" / "modules-semantic"

SLOTS = {
    "tu-main-8k": ("Wave94 semantic TU main · compose15 8K ladder", 700, 20),
    "tu-main-32k": ("Wave95 semantic TU main · compose15 32K ladder", 2765, 20),
    "mf-semantic-40": ("Wave94 semantic multi-func module", 40, 15),
    "core-semantic-40": ("Wave94 semantic runtime-core module", 40, 15),
}


def func_body(i: int) -> str:
    add = (i % 7) + 1
    return f"  (func f{i:03d}\n    (u64 {i})\n    (add-u64 {add}))"


def main_calls(n: int, call_limit: int) -> list[str]:
    return [f"    (call f{i:03d})" for i in range(min(n, call_limit))]


def render(header: str, n: int, call_limit: int) -> str:
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
    p.add_argument(
        "--slot",
        choices=[*SLOTS.keys(), "all"],
        default="all",
    )
    return p.parse_args()


def main() -> int:
    args = parse_args()
    slots = SLOTS.keys() if args.slot == "all" else [args.slot]
    SEM_DIR.mkdir(parents=True, exist_ok=True)
    for name in slots:
        header, n, mc = SLOTS[name]
        out = SEM_DIR / f"{name}.lisp"
        out.write_text(render(header, n, mc), encoding="utf-8")
        print(f"gen-semantic-compose15=ok path={out} funcs={n}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
