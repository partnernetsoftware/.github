; Wave38 W1: plan 内链式收敛 — verify + onion + nano-lisp.com（无 .sh/.c/.py 步骤）.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-all.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-matrix-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-default-all.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-output.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cvp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cvp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cvp-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cvp-smoke-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-cvp-smoke-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cvp-smoke-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cvp-smoke-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cvp-smoke-exit42.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-cvp-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cvp-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-cvp-ir-aarch64.elf"
                    "aarch64")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cvp-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cvp-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/v45-cvp-ape.com"
            "lab/nano-lisp-jit/.build/v45-cvp-x86.elf"
            "lab/nano-lisp-jit/.build/v45-cvp-arm.elf")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-cvp-ape.com" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-cvp-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-cvp-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.zero_sh_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.plan_all" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-host-orchestrator.json"))
