; Wave88: in-place repack release COM from genesis 154KB slices.
(bootstrap
  (file-size "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-size "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (pack-ape "lab/nano-lisp-jit/release/nano-lisp.com"
            "lab/nano-lisp-jit/genesis/nano-jit.x86_64"
            "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
