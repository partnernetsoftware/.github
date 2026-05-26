; Product feedback probe: block/branch inside func fails VM run (op 11).
(module
  (func pick
    (block
      (bool true)
      (branch ok)
      (u64 0)
      (label ok)
      (u64 42)))
  (main
    (call pick)
    (expect 42)))
