; wave126: add 104+17=121.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 104) (save-top-i64) (i64 17) (call add) (expect 121)))
