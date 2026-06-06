; Honest plan-only COM repack ~871KB — dual extract x86+aarch64 slices from pinned release/nano-lisp.com.
(bootstrap
  (extract-ape-slice "lab/nano-lisp-jit/release/nano-lisp.com"
                     "lab/nano-lisp-jit/.build/v45-dual-extract-x86.elf"
                     "x86_64")
  (extract-ape-slice "lab/nano-lisp-jit/release/nano-lisp.com"
                     "lab/nano-lisp-jit/.build/v45-dual-extract-aarch64.elf"
                     "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-dual-extract-repack.com"
            "lab/nano-lisp-jit/.build/v45-dual-extract-x86.elf"
            "lab/nano-lisp-jit/.build/v45-dual-extract-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-dual-extract-repack.com")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/v45-dual-extract-repack.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-child.lisp")
  (file-size "lab/nano-lisp-jit/.build/v45-dual-extract-repack.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-dual-extract-repack.com"))
