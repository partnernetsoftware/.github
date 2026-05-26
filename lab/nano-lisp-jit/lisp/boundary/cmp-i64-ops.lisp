; Boundary: i64 compare ops (eq/lt/gt/ne).
(module
  (main
    (i64 -3)
    (lt-i64 0)
    (expect true)
    (i64 7)
    (gt-i64 0)
    (expect true)
    (i64 7)
    (eq-i64 7)
    (expect true)
    (i64 7)
    (ne-i64 8)
    (expect true)))
