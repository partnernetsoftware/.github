; wave135: add 113+17=130.
(module
  (func add (param i64) (param i64) (load-arg-i64 0) (add-arg-i64 1))
  (main (i64 113) (save-top-i64) (i64 17) (call add) (expect 130)))
