; wave131: add 109+17=126.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 109) (save-top-i64) (i64 17) (call add) (expect 126)))
