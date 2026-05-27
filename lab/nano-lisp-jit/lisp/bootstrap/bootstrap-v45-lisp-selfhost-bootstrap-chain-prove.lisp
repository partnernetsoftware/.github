; Wave68 W1: Lisp 自举链 promote 证明 — 种子退仓前跑（零 plan 内 .sh 步骤）.
; Prefix v45-lsbc- · pack 自举链 COM 可 bootstrap.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-lisp-only-chain.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-lsbc-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-lsbc-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-lsbc-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-lsbc-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-lsbc-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-lsbc-promote.com"
            "lab/nano-lisp-jit/.build/v45-lsbc-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-lsbc-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-lsbc-promote.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-lsbc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-lsbc-smoke-strlen.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_com_plan_only_terminal" "1")
  (file-hash "lab/nano-lisp-jit/.build/v45-lsbc-promote.com"))
