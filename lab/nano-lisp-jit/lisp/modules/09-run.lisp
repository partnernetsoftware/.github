; Wave93: run 模块 — i64 链式运算 smoke.
(module
  (func run_step
    (u64 15)
    (add-u64 7))
  (main
    (call run_step)
    (add-u64 20)
    (expect 42)))
