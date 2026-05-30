; Compile this source into a portable .lbin blob. Runtime execution only needs
; the blob, not this source file.
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const arg "ffi")
  (main
    (call strlen arg)
    (expect 3)))
