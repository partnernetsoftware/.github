; Wave98 modules-semantic mirror · tag=aot · source=lisp/modules/05-aot.lisp
; maps nano_aot_x86.c — AOT smoke TU (main-only for obj export).
(module
  (main
    (u64 39)
    (add-u64 3)
    (expect 42)))
