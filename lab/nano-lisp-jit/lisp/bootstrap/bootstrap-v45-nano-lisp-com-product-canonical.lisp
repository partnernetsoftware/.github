; Wave51 W2: nano-lisp.com 产品面 canonical — pack + 文档 + 与 host com 锚.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcpc-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcpc-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/release/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlcpc-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlcpc-min-x86.elf")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/nano-jit.md")
  (file-size "lab/nano-lisp-jit/v4.5/HONEST-REMAINING.md")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.canonical" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.bootstrap_terminal" "1")
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
