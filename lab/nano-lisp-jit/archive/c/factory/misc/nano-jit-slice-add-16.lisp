; v4 slice-11: add 8+8=16 — IR table v2 partial fixed-word emit.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 8)
    (save-top-i64)
    (i64 8)
    (call add)
    (expect 16)))
