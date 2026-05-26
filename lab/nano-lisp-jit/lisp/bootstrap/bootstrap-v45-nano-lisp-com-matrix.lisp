; Wave36 W3: nano-lisp.com 产物矩阵 — pack + inspect + 四轨探针.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlc-mx-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlc-mx-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlc-mx-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlc-mx-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlc-mx-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-all.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-default-all.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-nano-lisp-com-verify.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-output.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"))
