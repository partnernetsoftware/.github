; Negative AOT smoke: expect mismatch should compile but exit with 125.
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 43)))
