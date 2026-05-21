; Probe: i64 min boundary in VM (interpret path)
(module
  (main
    (i64 -9223372036854775808)
    (expect -9223372036854775808)
    (i64 9223372036854775807)
    (expect 9223372036854775807)))
