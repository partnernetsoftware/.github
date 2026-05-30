; Boundary: le-i64 / ge-i64 compares.
(module
  (main
    (i64 -42)
    (le-i64 -42)
    (expect true)
    (i64 43)
    (ge-i64 42)
    (expect true)
    (i64 42)
    (expect 42)))
