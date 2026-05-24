; v4 slice-10: add 7+8=15 — IR entry v1 regression.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 7)
    (save-top-i64)
    (i64 8)
    (call add)
    (expect 15)))
