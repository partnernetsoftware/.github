; Wave40 W1: THE unified daily converge plan — user runs ONLY this plan instead of .sh scripts.
; Merges: converge-via-plan (verify+onion+nano-lisp.com) + runner-physical mod00/04 + verify-matrix subset.
; Prefix v45-cdp- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-via-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-matrix-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-onion-default-all.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-output.lisp")
  (file-size "lab/nano-lisp-jit/v4.5/ONION-TDD.md")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdp-smoke-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-smoke-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdp-smoke-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cdp-smoke-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdp-smoke-exit42.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/core/ptr-values.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-core-ptr.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdp-core-ptr.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-core-multi.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                     "lab/nano-lisp-jit/.build/v45-cdp-core-multi.elf"
                     "nano_v45_multi")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdp-core-multi.elf" 43)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-cdp-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdp-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-cdp-ir-aarch64.elf"
                    "aarch64")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cdp-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-cdp-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/v45-cdp-ape.com"
            "lab/nano-lisp-jit/.build/v45-cdp-x86.elf"
            "lab/nano-lisp-jit/.build/v45-cdp-arm.elf")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-cdp-ape.com" 42)
  (pack-ape "lab/nano-lisp-jit/release/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-cdp-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-cdp-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdp-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-cdp-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdp-mod04.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.host_orchestrator_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.runner_physical_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.via_plan" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-daily-plan.json"))
