; Lisp-only slice profile: two-arg add + main exit 42 (lisp/core · 零 archive/c).
(module
  (func add
    (param u64)
    (param u64)
    (load-arg-u64 0)
    (add-arg-u64 1))
  (main
    (u64 40)
    (save-top-u64)
    (u64 2)
    (call add)
    (expect 42)))
