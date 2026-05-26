; Runner core profile: exit-42 VM (stand-in until full lispjit.c → Lisp codegen).
(module
  (main
    (u64 40)
    (add-u64 2)
    (expect 42)))
