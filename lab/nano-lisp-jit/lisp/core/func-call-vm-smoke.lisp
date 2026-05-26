(module
  (func helper
    (add-u64 2))
  (main
    (u64 40)
    (call helper)
    (expect 42)))
