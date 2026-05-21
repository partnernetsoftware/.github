; FFI smoke tool: strlen("lab") == 3
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (const arg "lab")
  (main
    (call strlen arg)
    (expect 3)))
