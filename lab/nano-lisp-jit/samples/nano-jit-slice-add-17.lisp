; v4 slice-12: add 10+7=17 — plan-lisp ir_source regression.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 10)
    (save-top-i64)
    (i64 7)
    (call add)
    (expect 17)))
