; v4 slice-7: add 5+6=11 for aarch64-add-emit (parsed operands, not hardcoded).
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 5)
    (save-top-i64)
    (i64 6)
    (call add)
    (expect 11)))
