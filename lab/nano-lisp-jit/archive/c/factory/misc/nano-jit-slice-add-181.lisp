; wave186: add 164+17=181.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 164) (save-top-i64) (i64 17) (call add) (expect 181)))
