; Tiny pure-VM tool: linked ELF should exit 42.
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
