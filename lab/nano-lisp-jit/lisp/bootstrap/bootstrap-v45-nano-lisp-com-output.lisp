; Wave35 W3: nano-lisp.com 产物路径（pack-ape，plan 内零 .c）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlc-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlc-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlc-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlc-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlc-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"))
