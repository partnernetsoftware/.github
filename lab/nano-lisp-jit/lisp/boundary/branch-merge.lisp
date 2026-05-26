; Boundary: block + branch (same pattern as control-flow.lisp prefix).
(module
  (main
    (block
      (bool true)
      (branch taken)
      (u64 0)
      (expect 999)
      (label taken)
      (u64 41)
      (add-u64 1)
      (expect 42))))
