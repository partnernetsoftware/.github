; v4.5 unified daily — A (com+lisp dogfood) + B (158KB codegen) single entry.
; User path: release/nano-lisp.com + *.lisp only (no .sh / host-cc in-plan).
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-unified-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-unified-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-unified-arith.lbin")
  (run "lab/nano-lisp-jit/.build/v45-unified-arith.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only.lisp")
  (build-slice-lisp-profile "compose-15link-semantic-unified"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-unified-codegen-158k.elf"
    "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-unified-codegen-158k.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-unified-codegen-158k.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-unified-codegen-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-unified-codegen-strlen.lbin"))
