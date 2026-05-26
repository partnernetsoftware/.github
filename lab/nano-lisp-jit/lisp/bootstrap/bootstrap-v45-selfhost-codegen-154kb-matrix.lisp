; Wave45 W4: selfhost × 154KB codegen 矩阵 — broad ir + 代际 com 探针.
; Prefix v45-sc154- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sc154-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sc154-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-sc154-ir-aarch64.elf"
                    "aarch64")
  (compile "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
           "lab/nano-lisp-jit/.build/v45-sc154-mod07.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sc154-mod07.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
           "lab/nano-lisp-jit/.build/v45-sc154-mod08.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sc154-mod08.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
           "lab/nano-lisp-jit/.build/v45-sc154-mod09.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sc154-mod09.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.nano_lisp_com_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.runner_broad_profiles" "4")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-lispjit-codegen-deep.lisp"))
