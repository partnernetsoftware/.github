; AOT 2x i64 params: SysV rdi/rsi. Main: (i64 a)(save-top-i64)(i64 b)(call) -> rdi=rbx, rsi=rax.
; Callee loads arg0 (41) and adds 1; with b=1 passed in rsi, result is 42.
(module
  (func add-first-plus-one
    (param i64)
    (param i64)
    (load-arg-i64 0)
    (add-i64 1))
  (main
    (i64 41)
    (save-top-i64)
    (i64 1)
    (call add-first-plus-one)
    (expect 42)))
