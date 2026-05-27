# Wave71 — lisp-codegen-diffuse（扩散 · 四轨并发）

**签收**：`v45.v45.lisp_codegen_diffuse_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `lisp-codegen-compose15-prove.lisp` | compose-15 plan-only + build-slice env 探针 |
| W2 | `lisp-codegen-genesis-154kb-sync.lisp` | genesis aarch64 154KB 对齐 |
| W3 | `converge-daily-v45-lisp-codegen-diffuse.lisp` | daily 升维 |
| W4 | `lisp-codegen-ape-six-face-plan.lisp` | APE 6 面规划 SSOT |

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-lisp-codegen-diffuse.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py ready

bash lab/nano-lisp-jit/retired/scripts/v45-wave71-lisp-codegen-diffuse-converge.sh
```

**下一圈**：Wave72 compose-15 slice → release COM promote
