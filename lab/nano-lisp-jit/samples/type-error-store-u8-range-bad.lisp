; Negative source AOT smoke: store-u8 requires an 8-bit immediate.
(module
  (main
    (null-ptr)
    (store-u8 256)))
