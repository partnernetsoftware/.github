; AOT i64 function parameter smoke: rdi arg 41, callee adds 1, main exits 42.
(module
  (func func-with-param
    (param i64)
    (load-arg-i64 0)
    (add-i64 1))
  (main
    (i64 41)
    (call func-with-param)
    (expect 42)))
