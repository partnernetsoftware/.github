; Wave98 modules-semantic mirror · tag=callee · source=lisp/core/lisp-tu-callee.lisp
; L4 TU callee: add body exported as nano_tu_callee via compile-elf64-obj-code.
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
