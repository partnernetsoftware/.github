; v4 slice-8: add 8+5=13 — squad wave13 engineer-b delivery.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 8)
    (save-top-i64)
    (i64 5)
    (call add)
    (expect 13)))
