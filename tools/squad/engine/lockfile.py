"""Cross-process lock for verify / evidence writes."""
from __future__ import annotations

import os
from contextlib import contextmanager
from pathlib import Path


@contextmanager
def flock(path: Path, *, exclusive: bool = True):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd = os.open(str(path), os.O_CREAT | os.O_RDWR, 0o644)
    try:
        import fcntl

        op = fcntl.LOCK_EX if exclusive else fcntl.LOCK_SH
        fcntl.flock(fd, op)
        yield
    finally:
        try:
            import fcntl

            fcntl.flock(fd, fcntl.LOCK_UN)
        except Exception:
            pass
        os.close(fd)
