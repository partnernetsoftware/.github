# Wave103 — macOS os_id=2 slice 探针

**签收**：`v45.goal.ape_macos_slice_probe_milestone=1`

| 槽 | 交付 |
|----|------|
| W1 | `gen-ape-macos-osid-probe.py` → 4-row APE v2 bare |
| W2 | `inspect-ape` 识别 os_id=2 · size=0 placeholder |
| W3 | ape_v2 校验扩面 · run-ape 仍选 Linux slice |
| W4 | journal round 32 |

**诚实分层**（禁止混称 macOS runtime DONE）：

| 行 | arch | os_id | size | 状态 |
|----|------|-------|------|------|
| 0 | x86_64 | 1 Linux | ELF | ✅ |
| 1 | aarch64 | 1 Linux | ELF | ✅ |
| 2 | x86_64 | 2 macOS | 0 | 探针 placeholder |
| 3 | aarch64 | 2 macOS | 0 | 探针 placeholder |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave103-ape-macos-slice-probe-converge.sh
```

**下一刀**：真实 Mach-O slice · build_nano_jit 工厂 lisp-only 路径
