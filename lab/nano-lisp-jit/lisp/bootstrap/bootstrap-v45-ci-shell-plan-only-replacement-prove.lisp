; Wave60 W1: CI shell plan-only 替代证明 — 无 wave59 .sh 步骤（迁出前跑）.
; Prefix v45-cspr- · no .sh exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/scripts/v45-wave59-tools-py-retire-converge.sh")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-cpysh-terminal.lisp")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (file-size "lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cspr-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cspr-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cspr-smoke-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cspr-smoke-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cspr-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cspr-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_zero_cpysh_terminal" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.tools.py_active_deleted" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.host.wave_sh_active_deleted" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical-zero-cpysh.lisp"))
