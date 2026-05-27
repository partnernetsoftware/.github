; wave227: add 205+17=222.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 205) (save-top-i64) (i64 17) (call add) (expect 222)))
