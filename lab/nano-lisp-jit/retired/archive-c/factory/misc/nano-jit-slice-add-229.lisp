; wave234: add 212+17=229.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 212) (save-top-i64) (i64 17) (call add) (expect 229)))
