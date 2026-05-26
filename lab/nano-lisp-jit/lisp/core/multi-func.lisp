; Multi-function AOT object smoke: main calls a local helper via relocation.
(module
  (func helper
    (u64 40)
    (add-u64 2))
  (main
    (call helper)
    (add-u64 1)
    (expect 43)))
