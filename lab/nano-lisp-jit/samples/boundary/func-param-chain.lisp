; Boundary: i64 param + load-arg + call (same as func-param-vm-i64).
(module
  (func inc
    (param i64)
    (load-arg-i64 0)
    (add-i64 1))
  (main
    (i64 41)
    (call inc)
    (expect 42)))
