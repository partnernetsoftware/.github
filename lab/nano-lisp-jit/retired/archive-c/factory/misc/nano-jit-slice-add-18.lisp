; v4 slice-15: add 10+8=18 — table-only emit log.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 10)
    (save-top-i64)
    (i64 8)
    (call add)
    (expect 18)))
