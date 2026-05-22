; Negative: const-ptr is read-only and cannot be stored through.
(module
  (const word "Az09")
  (main
    (const-ptr word)
    (store-u8 66)))
