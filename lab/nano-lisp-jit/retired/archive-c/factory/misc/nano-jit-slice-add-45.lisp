; wave50: add 28+17=45.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 28) (save-top-i64) (i64 17) (call add) (expect 45)))
