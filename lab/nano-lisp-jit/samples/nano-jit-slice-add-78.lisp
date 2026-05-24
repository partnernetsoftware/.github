; wave83: add 61+17=78.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 61) (save-top-i64) (i64 17) (call add) (expect 78)))
