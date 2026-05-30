; Wave72 W2: pack-ape 探针 — min x86 + ir-exit aarch64（诚实 stub 链旁路）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-c15pk-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15pk-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-c15pk-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-c15pk-probe.com"
            "lab/nano-lisp-jit/.build/v45-c15pk-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-c15pk-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-c15pk-probe.com")
  (file-size "lab/nano-lisp-jit/.build/v45-c15pk-probe.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-c15pk-probe.com"))
