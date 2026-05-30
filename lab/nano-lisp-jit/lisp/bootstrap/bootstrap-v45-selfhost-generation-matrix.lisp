; Wave38 W4: 代际 selfhost generation matrix on lisp-only path.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/v45-selfhost-next.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sgm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sgm-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-sgm-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sgm-add-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sgm-parse.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sgm-parse.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-sgm-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-sgm-next-lo.com"
            "lab/nano-lisp-jit/.build/v45-sgm-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-sgm-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-sgm-next-lo.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.next_onion_lisp_only" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.100" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-chain-lisp-only.lisp"))
