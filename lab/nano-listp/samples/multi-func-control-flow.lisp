; Multi-function source AOT smoke: helper uses typed/control-flow before returning u64.
(module
  (func helper
    (block
      (bool true)
      (branch typed-path)
      (u64 999)
      (expect 0)
      (label typed-path)
      (i64 -7)
      (expect -7)
      (bool false)
      (expect false)
      (u64 42)))
  (main
    (call helper)
    (add-u64 1)
    (expect 43)))
