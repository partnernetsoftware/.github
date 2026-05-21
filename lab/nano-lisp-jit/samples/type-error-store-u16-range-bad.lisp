; Negative source AOT smoke: store-u16 requires a 16-bit immediate.
(module
  (main
    (null-ptr)
    (store-u16 65536)))
