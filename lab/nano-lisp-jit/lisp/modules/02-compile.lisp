; lispjit-modules/02-compile: compile subsystem proxy (VM compile path smoke).
(module
  (func add42
    (u64 40)
    (add-u64 2))
  (main
    (call add42)
    (expect 42)))
