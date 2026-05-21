; Probe: large add-ptr offset (still null base)
(module
  (main
    (null-ptr)
    (add-ptr 4096)
    (ptr-to-u64)
    (expect 4096)))
