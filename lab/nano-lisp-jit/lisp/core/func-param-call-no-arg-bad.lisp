; Negative AOT smoke: call i64-param func without an i64 value on the stack.
(module
  (func func-with-param
    (param i64)
    (load-arg-i64 0)
    (add-i64 1))
  (main
    (call func-with-param)
    (expect 42)))
