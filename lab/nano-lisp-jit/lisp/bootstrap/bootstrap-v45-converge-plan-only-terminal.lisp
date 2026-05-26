; Wave47 W1: plan 内全收敛终局 — squad + verify + daily-codegen 锚（零 plan 内 .sh）.
(bootstrap
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-codegen-terminal.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-matrix-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-entry-plan-only.lisp")
  (file-size "lab/nano-lisp-jit/v4.5/DIFFUSE-WAVE47.md")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cpot-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cpot-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cpot-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cpot-smoke-arithmetic.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_codegen_terminal" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.verify.matrix_plan" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.zero_sh_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-host-sh-terminal.json"))
