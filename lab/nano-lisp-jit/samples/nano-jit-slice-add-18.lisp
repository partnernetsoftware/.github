; v4 slice-13: add 11+7=18 — lisp encode regression.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 11)
    (save-top-i64)
    (i64 7)
    (call add)
    (expect 18)))
