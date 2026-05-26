; Wave44 W2: selfhost × nano-lisp.com 代际矩阵（lisp-only chain）.
; Prefix v45-shnlc- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-shnlc-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-shnlc-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-shnlc-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-shnlc-next.com"
            "lab/nano-lisp-jit/.build/v45-shnlc-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-shnlc-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-shnlc-next.com")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-shnlc-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shnlc-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-shnlc-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shnlc-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.semantic_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.next_onion_lisp_only" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-semantic-run.lisp"))
