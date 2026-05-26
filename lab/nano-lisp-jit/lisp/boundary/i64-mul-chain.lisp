; Boundary: i64 mul + compare (signed arithmetic depth).
(module
  (main
    (i64 -7)
    (mul-i64 -6)
    (eq-i64 42)
    (expect true)
    (i64 42)
    (expect 42)))
