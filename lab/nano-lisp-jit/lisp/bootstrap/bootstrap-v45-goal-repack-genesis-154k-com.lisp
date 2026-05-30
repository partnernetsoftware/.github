; Wave88: repack release COM from genesis 154KB slices.
(bootstrap
  (file-size "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-size "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
            "lab/nano-lisp-jit/genesis/nano-jit.x86_64"
            "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"))
