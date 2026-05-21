; Probe: label is not a barrier — execution falls through into label body
(module
  (main
    (block
      (bool false)
      (branch end)
      (u64 42)
      (expect 42)
      (label end)
      (u64 1)
      (expect 999))))
