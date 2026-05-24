; lispjit-modules/00-runtime-core: tier-1 proxy (maps to nano-jit-runner-core semantics).
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
