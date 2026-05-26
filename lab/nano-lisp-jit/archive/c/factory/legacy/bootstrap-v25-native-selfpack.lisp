; v2.5 native self-pack when cosmocc aarch64 slice is unavailable.
; Both APE payload rows use the x86_64 slice (oracle: slice.aarch64=x86_64_duplicate).
(bootstrap
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com" "lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64" "lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"))
