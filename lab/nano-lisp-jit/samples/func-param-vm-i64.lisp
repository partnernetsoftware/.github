; VM .lbin parity for func-param-i64 (param + load-arg + call).
(module
  (func func-with-param
    (param i64)
    (load-arg-i64 0)
    (add-i64 1))
  (main
    (i64 41)
    (call func-with-param)
    (expect 42)))
