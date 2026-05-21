; Probe: same i64 extremes on AOT codegen path (x86_64 only)
(module
  (main
    (i64 -9223372036854775808)
    (expect -9223372036854775808)))
