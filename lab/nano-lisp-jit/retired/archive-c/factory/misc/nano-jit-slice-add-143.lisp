; wave148: add 126+17=143.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 126) (save-top-i64) (i64 17) (call add) (expect 143)))
