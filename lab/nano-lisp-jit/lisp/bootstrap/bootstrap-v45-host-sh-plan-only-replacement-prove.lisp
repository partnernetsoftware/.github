; Wave58 W1: host .sh plan-only 替代证明 — 用户 daily 链无 .sh 步骤（迁出前跑）.
; Prefix v45-hspr- · no .sh exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/scripts/v45-wave57-lispjit-c-delete-converge.sh")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-c.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete-plan-only.lisp")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-hspr-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-hspr-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-hspr-smoke-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-hspr-smoke-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-hspr-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-hspr-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_zero_c" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_complete_plan_only" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.entry.plan_only" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-outer.lisp"))
