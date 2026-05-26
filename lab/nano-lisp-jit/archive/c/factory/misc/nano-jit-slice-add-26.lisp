; wave31 track-A: add 9+17=26.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 9)
    (save-top-i64)
    (i64 17)
    (call add)
    (expect 26)))
