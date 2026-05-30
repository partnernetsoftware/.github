; v4 slice-17: add 11+9=20 — C verifies plan-words file at emit.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 11)
    (save-top-i64)
    (i64 9)
    (call add)
    (expect 20)))
