; shell-fgets-smoke — libc fgets via stdin addr (Phase 7).
(module
  (import fgets "libc" "fgets" "ptr(ptr,i32,ptr)")
  (import stdin "libc" "stdin" "addr")
  (const buf "                                                                                                                                ")
  (main
    (resolve fgets)
    (resolve stdin)
    (call fgets buf 128 stdin)
    (expect nonnull)))
