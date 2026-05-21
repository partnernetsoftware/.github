; Probe: multi-func only on source AOT path (NOT .lbin compile)
(module
  (func helper
    (u64 5))
  (main
    (call helper)
    (add-u64 1)
    (expect 6)))
