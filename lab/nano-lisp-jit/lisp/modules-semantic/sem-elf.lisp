; Wave98 modules-semantic mirror · tag=elf · source=lisp/modules/06-elf.lisp
; maps nano_elf64.c — ELF smoke TU (main-only for obj export).
(module
  (main
    (u64 37)
    (add-u64 5)
    (expect 42)))
