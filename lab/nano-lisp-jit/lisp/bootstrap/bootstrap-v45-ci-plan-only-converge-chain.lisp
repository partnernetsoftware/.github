; Wave54 W1: plan-only 收敛链 — squad + verify + entry + physical daily 锚.
; Prefix v45-cpoc- · plan 内零 .sh 步骤.
(bootstrap
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-entry-plan-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-matrix-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-plan-only-terminal.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cpoc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cpoc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-cpoc-smoke-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cpoc-smoke-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cpoc-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cpoc-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.entry.plan_only" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.verify.matrix_plan" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.plan_only_terminal" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete-plan-only.lisp"))
