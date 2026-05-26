; Boundary: two funcs + call (VM-safe; AOT exit 43).
(module
  (func bump
    (u64 42))
  (main
    (call bump)
    (add-u64 1)
    (expect 43)))
