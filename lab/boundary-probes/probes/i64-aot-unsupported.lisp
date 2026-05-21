; Probe: i64-only main is VM ok but aot-elf64-code / compile-elf64-code reject
(module
  (main
    (i64 42)
    (expect 42)))
