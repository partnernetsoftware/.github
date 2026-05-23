; v4 slice-12: add 9+8=17 — IR table v3 movz bases.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 9)
    (save-top-i64)
    (i64 8)
    (call add)
    (expect 17)))
