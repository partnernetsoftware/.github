; Explicit mutable pointer should use writable data even without stores.
(module
  (const word "Az09")
  (main
    (mut-ptr word)
    (expect nonnull)
    (mut-ptr word)
    (load-u8)
    (expect 65)
    (bool true)
    (expect true)))
