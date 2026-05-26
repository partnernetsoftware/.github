; Boundary: chained i64 add/sub (VM only).
(module
  (main
    (i64 100)
    (add-i64 50)
    (sub-i64 8)
    (expect 142)))
