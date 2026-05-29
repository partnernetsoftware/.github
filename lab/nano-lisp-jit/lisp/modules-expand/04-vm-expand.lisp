; Wave80 expand: VM module — multi-func codegen（较 stub 592B → ~1KB+）.
(module
  (func neg-base
    (i64 -7))
  (func ready
    (call neg-base)
    (lt-i64 0)
    (and-bool true))
  (func value
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
    (call neg-base)
    (add-i64 49)
    (expect 42)
    (call ready)
    (branch ready-path)
    (u64 1)
    (expect 999)
    (label ready-path)
    (call value)
    (add-u64 0)
    (expect 42)))
