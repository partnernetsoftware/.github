; Wave93: VM module — func 内 call chain（maps nano_blob_vm 语义探针）.
(module
  (func vm_add10
    (u64 5)
    (add-u64 5))
  (main
    (call vm_add10)
    (add-u64 32)
    (expect 42)))
