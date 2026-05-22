; Constant string pointer read-only smoke for object .rodata policy.
(module
  (const word "Az09")
  (main
    (const-ptr word)
    (expect nonnull)
    (const-ptr word)
    (load-u8)
    (expect 65)
    (const-ptr word)
    (add-ptr 1)
    (load-u8)
    (expect 122)
    (bool true)
    (expect true)))
