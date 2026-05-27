; Runner tier-3: multi-function AOT (maps to NANO_LISPJIT_FROM_LISP_PROFILE=multi-func).
; Source of truth for codegen: lab/nano-lisp-jit/lisp/core/multi-func.lisp
(module
  (func helper
    (u64 40)
    (add-u64 2))
  (main
    (call helper)
    (add-u64 1)
    (expect 43)))
