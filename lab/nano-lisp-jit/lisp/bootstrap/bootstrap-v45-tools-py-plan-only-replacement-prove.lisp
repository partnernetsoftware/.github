; Wave59 W1: tools .py plan-only 替代证明 — squad/verify 链无 python 步骤（迁出前跑）.
; Prefix v45-tppr- · no python exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/tools/mindmap-dp-v45.py")
  (file-size "lab/nano-lisp-jit/squad/squad_cli.py")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-outer.lisp")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-tppr-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-tppr-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-tppr-smoke-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-tppr-smoke-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-tppr-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-tppr-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_plan_only_outer" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.tools.py_inventory" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.entry.plan_only" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-cpysh-terminal.lisp"))
