; Probe: linear chain of blocks/branches (depth 8)
(module
  (main
    (block
      (bool true)
      (branch L1)
      (u64 1)
      (expect 999)
      (label L1)
      (block
        (bool true)
        (branch L2)
        (u64 2)
        (expect 999)
        (label L2)
        (block
          (bool true)
          (branch L3)
          (u64 3)
          (expect 999)
          (label L3)
          (block
            (bool true)
            (branch L4)
            (u64 4)
            (expect 999)
            (label L4)
            (i64 42)
            (expect 42)))))))
