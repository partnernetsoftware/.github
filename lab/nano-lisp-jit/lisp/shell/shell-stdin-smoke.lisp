; shell-stdin-smoke — resolve libc stdin as addr import (fgets pathfinder).
(module
  (import stdin "libc" "stdin" "addr")
  (main
    (resolve stdin)
    (expect nonnull)))
