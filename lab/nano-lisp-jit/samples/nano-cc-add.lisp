; Companion lower for nano-cc-add.c: multi-func object + link via compile-elf64-exe.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 40)
    (save-top-i64)
    (i64 2)
    (call add)
    (expect 42)))
