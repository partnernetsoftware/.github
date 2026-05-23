; v4 slice-11: add 9+7=16 — manifest encode table regression.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 9)
    (save-top-i64)
    (i64 7)
    (call add)
    (expect 16)))
