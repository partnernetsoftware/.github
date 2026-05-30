; Wave65 W1: CI 工具 sh plan-only 替代证明 — 迁出前跑（零 plan 内 .sh 步骤）.
; Prefix v45-csfrp- · no .sh exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/scripts/v45-evidence-canonical.sh")
  (file-size "lab/nano-lisp-jit/scripts/v45-com-verify.sh")
  (file-size "lab/nano-lisp-jit/scripts/v45-scoped-ci.sh")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-only-factory.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-csfrp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-csfrp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-csfrp-smoke-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-csfrp-smoke-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-csfrp-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-csfrp-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_lisp_only_factory" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.archive_c_runner_retired" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-final.lisp"))
