; wave231: add 209+17=226.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 209) (save-top-i64) (i64 17) (call add) (expect 226)))
