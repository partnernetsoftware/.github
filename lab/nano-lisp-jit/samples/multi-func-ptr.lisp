; Multi-function pointer smoke: preserve ptr return kind across a local call.
(module
  (func maybe-null
    (null-ptr))
  (func offset-ptr
    (null-ptr)
    (add-ptr 1))
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
    (call offset-ptr)
    (expect nonnull)
    (is-nonnull-ptr)
    (expect true)
    (not-bool)
    (expect true)))
