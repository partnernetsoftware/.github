; v4 slice-16: add 9+10=19 — plan-words-v1 contract log.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 9)
    (save-top-i64)
    (i64 10)
    (call add)
    (expect 19)))
