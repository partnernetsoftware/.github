; wave201: add 179+17=196.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 179) (save-top-i64) (i64 17) (call add) (expect 196)))
