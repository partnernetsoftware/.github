; Wave39 W2: runner 物理 emit 链 — ir-table + emit + build-slice-lisp（plan 内零 lispjit.c）.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-rpe-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpe-ctrl.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-rpe-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rpe-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-rpe-ir-aarch64.elf"
                    "aarch64")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-rpe-exit.elf" 11)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rpe-exit.elf" 11)
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp"))
