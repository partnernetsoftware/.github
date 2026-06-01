# APE 6 面规划（Wave71 W4 · 扩散 SSOT）

| arch_id | os_id | OS | ISA | release COM | 目标 |
|---------|-------|-----|-----|-------------|------|
| 1 | 1 | Linux | x86_64 | ✅ 154KB | 保持 |
| 2 | 1 | Linux | aarch64 | ✅ 154KB | 保持 |
| 1 | 2 | macOS | x86_64 | ❌ | Cosmo apelink / fat Mach-O |
| 2 | 2 | macOS | aarch64 | ❌ | 同上 |
| 1 | 3 | Windows | x86_64 | ❌ | PE slice |
| 2 | 3 | Windows | aarch64 | ❌ | PE ARM64 |

**当前**：APE v2 · `os_id=1` only · **Linux 2/2** · cross-os **0/4**  
**Wave102**：release COM `inspect-ape` 签收 Linux 双 slice · `ape_six_face_expand_milestone=1`  
**下一刀**：os_id **2**=macOS · **3**=Windows slice 探针（Cosmo apelink / PE）
