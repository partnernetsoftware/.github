; Wave80 expand template A — multi-func · exit 42.
(module
  (func neg-base
    (i64 -7))
  (func bump
    (call neg-base)
    (add-i64 49)
    (expect 42))
  (main
    (call bump)
    (u64 41)
    (add-u64 1)
    (expect 42)))
