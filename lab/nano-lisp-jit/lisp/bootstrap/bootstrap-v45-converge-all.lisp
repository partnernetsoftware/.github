; Wave36 W1: plan 内收敛 — 链式 verify + selfhost lisp-only（无 .sh 步骤）.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-regenesis-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-chain-lisp-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-output.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-lisp-only.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-ca-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-ca-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-ca-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-ca-smoke-arithmetic.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-ca-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-ca-min-x86.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.lisp_com_only_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-plan-converge.json"))
