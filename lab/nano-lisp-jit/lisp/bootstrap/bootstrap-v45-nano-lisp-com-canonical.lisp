; Wave37 W2: nano-lisp.com 产物名统一 — pack + inspect + 与 wave35/36 路径锚.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlc-can-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlc-can-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlc-can-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlc-can-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlc-can-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-output.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-matrix.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-canonical.lisp")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.output_named" "1")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"))
