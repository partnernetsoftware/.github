; Wave70 W1: 活跃 daily/prove 零 archive/c 路径审计证明.
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/ARCHIVE-PATH-AUDIT.md")
  (file-size "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-lisp-selfhost-bootstrap-chain-prove.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-audit-terminal.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-dzaap-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-dzaap-smoke-strlen.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-dzaap-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-dzaap-add-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/v4.5/ARCHIVE-PATH-AUDIT.md"))
