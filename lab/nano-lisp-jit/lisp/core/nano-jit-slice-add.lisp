; Add slice profile: main exit 42 via u64 add (lisp/core · plan-only).
(module
  (main
    (u64 38)
    (add-u64 4)
    (expect 42)))
