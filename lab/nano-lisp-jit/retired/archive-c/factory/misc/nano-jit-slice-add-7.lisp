; v4 slice-1: non-fixed add immediates (3+4=7) for aarch64-add-emit.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 3)
    (save-top-i64)
    (i64 4)
    (call add)
    (expect 7)))
