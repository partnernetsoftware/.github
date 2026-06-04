; shell-v0 — dogfood libc:system via .lbin VM (Phase 0 shell runner seed).
(module
  (import system "libc" "system" "i32(ptr)")
  (const cmd "echo nanolisp-shell-v0-system")
  (main
    (resolve system)
    (call system cmd)
    (expect 0)))
