; v4 slice-9: add 6+8=14 — opcode-table lowering regression.
(module
  (func add
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-arg-i64 1))
  (main
    (i64 6)
    (save-top-i64)
    (i64 8)
    (call add)
    (expect 14)))
