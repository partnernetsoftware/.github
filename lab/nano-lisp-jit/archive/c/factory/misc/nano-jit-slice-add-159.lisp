; wave164: add 142+17=159.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 142) (save-top-i64) (i64 17) (call add) (expect 159)))
