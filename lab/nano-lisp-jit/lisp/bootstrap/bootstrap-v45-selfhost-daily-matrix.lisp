; Wave40 W4: selfhost daily matrix on lisp-only path.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sdm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sdm-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-sdm-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-sdm-daily-lo.com"
            "lab/nano-lisp-jit/.build/v45-sdm-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-sdm-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-sdm-daily-lo.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.next_onion_lisp_only" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp"))
