; Wave46 W4: selfhost × codegen terminal 矩阵 — 15link 代际 + broad ir.
; Prefix v45-sctm- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sctm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sctm-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-sctm-ir-aarch64.elf"
                    "aarch64")
  (compile "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
           "lab/nano-lisp-jit/.build/v45-sctm-mod10.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sctm-mod10.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-sctm-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sctm-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sctm-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sctm-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.codegen_154kb_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.modules_full_13" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-codegen-full-chain.lisp"))
