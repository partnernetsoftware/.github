; Negative source AOT smoke: store-u32 requires a 32-bit immediate.
(module
  (main
    (null-ptr)
    (store-u32 4294967296)))
