; Constant string pointer smoke for VM and static AOT memory access.
(module
  (const word "Az")
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
    (bool false)
    (not-bool)
    (expect true)))
