; Wave69 W1: run.sh 工厂面 plan-only 替代证明 — 用户 daily 纯 COM+plan 收敛（零 plan 内 run.sh 步骤）.
; Prefix v45-rshfp- · 不依赖 run.sh.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-selfhost-bootstrap-chain.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/scripts/README.md")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-rshfp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rshfp-smoke-strlen.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-rshfp-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rshfp-exit42.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_lisp_selfhost_chain" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-selfhost-bootstrap-chain.lisp"))
