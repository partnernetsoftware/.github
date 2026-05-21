; Multi-function pointer smoke: preserve ptr return kind across a local call.
(module
  (func maybe-null
    (null-ptr))
  (main
    (call maybe-null)
    (expect null)
    (is-null-ptr)
    (branch ptr-null)
    (u64 1)
    (expect 999)
    (label ptr-null)
    (call maybe-null)
    (is-nonnull-ptr)
    (expect false)
    (not-bool)
    (expect true)))
