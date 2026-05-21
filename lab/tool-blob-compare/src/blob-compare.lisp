; Pure VM: deterministic compile target (hash/compare done in build.sh)
(module
  (main
    (i64 100)
    (add-i64 23)
    (expect 123)))
