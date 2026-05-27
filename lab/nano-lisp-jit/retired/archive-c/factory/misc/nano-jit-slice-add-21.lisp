; v4 slice-18: add 5+16=21 — svc0 word from plan Lisp table.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 5)
    (save-top-i64)
    (i64 16)
    (call add)
    (expect 21)))
