; Probe: long pure u64 chain (30 adds) — compile + aot path
(module
  (main
    (u64 0)
    (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1)
    (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1)
    (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1)
    (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1)
    (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1)
    (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1) (add-u64 1)
    (expect 30)))
