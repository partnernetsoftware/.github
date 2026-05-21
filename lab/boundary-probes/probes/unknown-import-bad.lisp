; Probe: resolve missing libc symbol
(module
  (import not_a_real_symbol_xyz "libc" "not_a_real_symbol_xyz_12345" "u64(ptr)")
  (main
    (resolve not_a_real_symbol_xyz)
    (expect nonnull)))
