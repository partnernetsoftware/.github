; v4 wave27: add 5+17=22 — full plan Lisp IR table at emit.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 5)
    (save-top-i64)
    (i64 17)
    (call add)
    (expect 22)))
