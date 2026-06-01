; Wave98 modules-semantic mirror · tag=vm · source=lisp/modules/04-vm.lisp
; Wave93: VM module — func 内 call chain（maps nano_blob_vm 语义探针）.
(module
  (func vm_add10
    (u64 5)
    (add-u64 5))
  (main
    (call vm_add10)
    (add-u64 32)
    (expect 42)))
