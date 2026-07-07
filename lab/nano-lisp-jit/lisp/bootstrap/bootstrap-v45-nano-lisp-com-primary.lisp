; Wave38 W3: nano-lisp.com 为用户主入口产品名（plan 叙事非 nano-jit.com）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlp-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlp-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlp-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/release/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlp-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlp-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/nano-jit.md")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-canonical.lisp")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.output_named" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.canonical" "1")
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
