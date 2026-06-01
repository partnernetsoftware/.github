#!/usr/bin/env python3
"""Mirror lisp/modules + lisp/core into modules-semantic (Wave98 · 15-slot real semantics)."""

from __future__ import annotations

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEM_DIR = ROOT / "lisp" / "modules-semantic"

TAG_SOURCES: dict[str, Path] = {
    "main": ROOT / "lisp" / "core" / "lisp-tu-main.lisp",
    "callee": ROOT / "lisp" / "core" / "lisp-tu-callee.lisp",
    "extra": ROOT / "lisp" / "modules" / "01-runtime-extra.lisp",
    "core": ROOT / "lisp" / "modules" / "00-runtime-core.lisp",
    "mf": ROOT / "lisp" / "core" / "multi-func.lisp",
    "boot": ROOT / "lisp" / "modules" / "03-bootstrap-stub.lisp",
    "vm": ROOT / "lisp" / "modules" / "04-vm.lisp",
    "aot": ROOT / "lisp" / "modules" / "05-aot.lisp",
    "elf": ROOT / "lisp" / "modules" / "06-elf.lisp",
    "abi": ROOT / "lisp" / "modules" / "07-abi.lisp",
    "manifest": ROOT / "lisp" / "modules" / "08-manifest.lisp",
    "run": ROOT / "lisp" / "modules" / "09-run.lisp",
    "pack": ROOT / "lisp" / "modules" / "10-pack.lisp",
    "ape": ROOT / "lisp" / "modules" / "11-ape.lisp",
    "parse": ROOT / "lisp" / "modules" / "12-parse.lisp",
}


def mirror_tag(tag: str, src: Path) -> Path:
    if not src.is_file():
        raise FileNotFoundError(f"missing source for tag={tag}: {src}")
    rel = src.relative_to(ROOT)
    body = src.read_text(encoding="utf-8")
    header = f"; Wave98 modules-semantic mirror · tag={tag} · source={rel}\n"
    out = SEM_DIR / f"sem-{tag}.lisp"
    out.write_text(header + body.lstrip(), encoding="utf-8")
    return out


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "--tag",
        choices=[*TAG_SOURCES.keys(), "all"],
        default="all",
    )
    return p.parse_args()


def main() -> int:
    args = parse_args()
    tags = TAG_SOURCES.keys() if args.tag == "all" else [args.tag]
    SEM_DIR.mkdir(parents=True, exist_ok=True)
    for tag in tags:
        out = mirror_tag(tag, TAG_SOURCES[tag])
        print(f"gen-semantic-modules15=ok tag={tag} path={out} bytes={out.stat().st_size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
