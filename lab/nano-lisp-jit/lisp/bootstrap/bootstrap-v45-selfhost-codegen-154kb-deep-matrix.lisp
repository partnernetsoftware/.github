; Wave50 W4: selfhost × 154KB codegen 深矩阵.
; Prefix v45-sc154d- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sc154d-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sc154d-min-x86.elf" 42)
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-sc154d-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sc154d-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
           "lab/nano-lisp-jit/.build/v45-sc154d-mod05.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sc154d-mod05.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.codegen_154kb_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.runner_broad_profiles" "4")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-lispjit-154kb-codegen-probe.lisp"))
