; v4.5 TERMINAL daily — A dogfood + B 158KB codegen + B′ 871KB regenesis + pure-lisp pack.
; User path: release/nano-lisp.com + *.lisp only.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-terminal-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-terminal-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-terminal-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-terminal-arith.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only.lisp")
  (build-slice-lisp-profile "compose-15link"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-terminal-codegen-158k.elf"
    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-terminal-codegen-158k.elf" 42)
  (build-slice-lisp-profile "full"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-terminal-full-x86.elf"
    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-terminal-full-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-terminal-pure-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-terminal-pure-lisp.com"
            "lab/nano-lisp-jit/.build/v45-terminal-full-x86.elf"
            "lab/nano-lisp-jit/.build/v45-terminal-pure-aarch64.elf")
  (file-size "lab/nano-lisp-jit/.build/v45-terminal-pure-lisp.com")
  (extract-ape-slice "lab/nano-lisp-jit/release/nano-lisp.com"
                     "lab/nano-lisp-jit/.build/v45-terminal-x86-pack.elf"
                     "x86_64")
  (extract-ape-slice "lab/nano-lisp-jit/release/nano-lisp.com"
                     "lab/nano-lisp-jit/.build/v45-terminal-aarch64-pack.elf"
                     "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-terminal-regenesis.com"
            "lab/nano-lisp-jit/.build/v45-terminal-x86-pack.elf"
            "lab/nano-lisp-jit/.build/v45-terminal-aarch64-pack.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-terminal-regenesis.com")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/v45-terminal-regenesis.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-child.lisp")
  (file-size "lab/nano-lisp-jit/.build/v45-terminal-regenesis.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-terminal-regenesis.com"))
