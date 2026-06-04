; shell-script — Phase 1 multi-command .lbin script (libc:system chain).
(module
  (import system "libc" "system" "i32(ptr)")
  (const step1 "echo nanolisp-shell-script-step1")
  (const step2 "echo nanolisp-shell-script-step2")
  (const step3 "/bin/true")
  (main
    (resolve system)
    (call system step1)
    (expect 0)
    (call system step2)
    (expect 0)
    (call system step3)
    (expect 0)))
