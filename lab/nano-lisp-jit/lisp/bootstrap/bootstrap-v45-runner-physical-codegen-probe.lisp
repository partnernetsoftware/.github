; Wave39 W3: 代际 codegen probe on selfhost-next path — evidence + wave34 codegen anchors.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/v45-selfhost-next.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.runner_codegen_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.runner_broad_profiles" "4")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-rpc-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpc-arith.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-rpc-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpc-strlen.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-rpc-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rpc-min-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-runner-module-table.lisp"))
