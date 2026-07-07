; Wave67 W3: v4.5 COM+plan 终局 daily — 用户路径零 .sh/.c/.py/archive 步骤.
; Prefix v45-cdcpot- · 唯一入口 = nano-lisp.com + 本 plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-path.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-wave-converge-shell-retire-prove.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdcpot-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdcpot-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdcpot-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdcpot-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdcpot-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdcpot-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdcpot-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdcpot-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdcpot-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdcpot-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_zero_archive_path" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.wave_converge_shell_retired" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-wave-converge-shell-retire.json"))
