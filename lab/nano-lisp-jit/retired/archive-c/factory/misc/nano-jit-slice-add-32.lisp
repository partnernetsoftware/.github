; wave37 track-A: add 15+17=32.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 15)
    (save-top-i64)
    (i64 17)
    (call add)
    (expect 32)))
