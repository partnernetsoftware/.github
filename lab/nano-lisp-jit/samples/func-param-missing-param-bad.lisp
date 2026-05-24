; Negative AOT smoke: load-arg-i64 without (param i64) on the callee.
(module
  (func func-with-param
    (load-arg-i64 0)
    (add-i64 1))
  (main
    (i64 41)
    (call func-with-param)
    (expect 42)))
