; Wave98 modules-semantic mirror · tag=boot · source=lisp/modules/03-bootstrap-stub.lisp
; lispjit-modules/03-bootstrap-stub: bootstrap plan runner proxy (exit 42).
(module
  (main
    (u64 41)
    (add-u64 1)
    (expect 42)))
