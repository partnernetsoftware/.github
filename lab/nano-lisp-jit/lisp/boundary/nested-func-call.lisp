; Boundary: local func call (same pattern as multi-func.lisp).
(module
  (func helper
    (u64 40)
    (add-u64 2))
  (main
    (call helper)
    (expect 42)))
