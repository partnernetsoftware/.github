; Probe: duplicate label in same function (expect compile fail)
(module
  (main
    (block
      (bool true)
      (branch X)
      (label X)
      (label X)
      (u64 0)
      (expect 0))))
