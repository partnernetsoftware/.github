; wave103: add 81+17=98.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 81) (save-top-i64) (i64 17) (call add) (expect 98)))
