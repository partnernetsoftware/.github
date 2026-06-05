; codegen-158k daily — COM + *.lisp only; profile in-plan (no NANO_LISPJIT_* env).
; Produces ~155648B x86_64 slice via compose15 semantic-unified pure link.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (build-slice-lisp-profile "compose-15link-semantic-unified"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-codegen-158k-daily.elf"
    "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-codegen-158k-daily.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-codegen-158k-daily.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-codegen-158k-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-codegen-158k-strlen.lbin"))
