; wave65: add 43+17=60.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 43) (save-top-i64) (i64 17) (call add) (expect 60)))
