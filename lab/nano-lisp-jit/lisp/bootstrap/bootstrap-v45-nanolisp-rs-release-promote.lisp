; nanolisp Rust release promote — pack RS x86+aarch64 slices into .com/.ape (plan-only).
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp")
  (file-size "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nanolisp-rs-promote.com"
            "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
            "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64")
  (pack-ape-bare "lab/nano-lisp-jit/.build/nanolisp-rs-promote.ape"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64")
  (inspect-ape "lab/nano-lisp-jit/.build/nanolisp-rs-promote.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/nanolisp-rs-promote.com" 0)
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/nanolisp-rs-promote.ape" 0)
  (file-size "lab/nano-lisp-jit/.build/nanolisp-rs-promote.com")
  (file-hash "lab/nano-lisp-jit/.build/nanolisp-rs-promote.com"))
