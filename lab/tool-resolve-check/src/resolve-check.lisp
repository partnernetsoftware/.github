; Resolver smoke from a lab consumer (no full libc manifest)
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const arg "x")
  (main
    (resolve strlen)
    (expect nonnull)
    (call strlen arg)
    (expect 1)))
