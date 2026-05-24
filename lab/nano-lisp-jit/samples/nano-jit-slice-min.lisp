; Minimal slice profile: pure VM main exit 42 (build-slice-lisp / compile-elf64-code).
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
