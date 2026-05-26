; Boundary: null-ptr / add-ptr / ptr-to-u64 (subset of ptr-values.lisp).
(module
  (main
    (null-ptr)
    (expect null)
    (null-ptr)
    (add-ptr 8)
    (ptr-to-u64)
    (expect 8)
    (null-ptr)
    (add-ptr 8)
    (sub-ptr 8)
    (expect null)
    (is-null-ptr)
    (expect true)))
