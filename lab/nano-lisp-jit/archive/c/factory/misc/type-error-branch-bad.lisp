; Negative source AOT smoke: branch requires a bool value.
(module
  (main
    (u64 1)
    (branch taken)
    (label taken)
    (u64 0)))
