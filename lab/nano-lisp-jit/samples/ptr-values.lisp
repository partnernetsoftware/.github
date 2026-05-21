; Pointer value smoke for VM, static AOT, x86 codegen, and object paths.
(module
  (main
    (null-ptr)
    (expect null)
    (is-null-ptr)
    (expect true)
    (null-ptr)
    (is-nonnull-ptr)
    (expect false)
    (not-bool)
    (expect true)))
