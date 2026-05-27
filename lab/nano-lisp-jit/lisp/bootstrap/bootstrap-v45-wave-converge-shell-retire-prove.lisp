; Wave67 W1: wave converge sh plan-only 替代证明 — 迁出前跑（零 plan 内 .sh 步骤）.
; Prefix v45-wcsrp- · COM+plan 即收敛.
(bootstrap
  (file-size "lab/nano-lisp-jit/scripts/v45-wave66-archive-factory-lisp-retire-converge.sh")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-path.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-wcsrp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-wcsrp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-wcsrp-smoke-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-wcsrp-smoke-arith.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-wcsrp-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-wcsrp-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_zero_archive_path" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.archive_factory_lisp_retired" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-com-plan-only-terminal.lisp"))
