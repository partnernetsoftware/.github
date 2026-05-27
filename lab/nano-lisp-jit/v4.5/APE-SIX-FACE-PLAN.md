# APE 6 面规划（Wave71 W4 · 扩散 SSOT）

| arch_id | os_id | OS | ISA | release COM | 目标 |
|---------|-------|-----|-----|-------------|------|
| 1 | 1 | Linux | x86_64 | ✅ 154KB | 保持 |
| 2 | 1 | Linux | aarch64 | ✅ 154KB | 保持 |
| 1 | 2 | macOS | x86_64 | ❌ | Cosmo apelink / fat Mach-O |
| 2 | 2 | macOS | aarch64 | ❌ | 同上 |
| 1 | 3 | Windows | x86_64 | ❌ | PE slice |
| 2 | 3 | Windows | aarch64 | ❌ | PE ARM64 |

**当前**：APE v2 · `os_id=1` only · 2/6 面  
**Wave72+**：先 Linux 双架构 Lisp codegen promote，再扩 os_id 2/3
