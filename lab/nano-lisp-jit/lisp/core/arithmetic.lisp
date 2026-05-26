; Pure VM smoke test. It does not depend on FFI or libc.
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
