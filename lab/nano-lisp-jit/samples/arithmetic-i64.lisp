; Signed integer arithmetic smoke for VM, AOT, and object codegen.
(module
  (main
    (i64 -40)
    (add-i64 -2)
    (expect -42)
    (i64 44)
    (sub-i64 2)
    (expect 42)
    (i64 -7)
    (mul-i64 -6)
    (expect 42)))
