# Wave2 并发实施细节（工程师 checklist）

> 配对 [`DIFFUSE-WAVE2.md`](DIFFUSE-WAVE2.md) · catalog `wave2-v45-*`  
> **原则**：四轨同时开工 → **一次** `v45-wave2-converge.sh` → 洋葱修失败项。

---

## 轨 A · engineer-a · 自举代际

**touch_paths**（互不争用）：

```text
samples/bootstrap-v45-selfhost-modules-full.lisp   ← 新建/扩全 13 TU
samples/bootstrap-v45-selfhost-next-com-verify.lisp ← 锚点（执行在 converge 脚本）
v4.5/SELFHOST.md
.build/v45-selfhost-next.com                        ← 产物，勿手改
```

**实施清单**：

1. `selfhost-modules-full.lisp`：对 `lispjit-modules/00–12.lisp` 各 `(compile)(run)`；失败则记 `PRODUCT-FEEDBACK` 一行，**勿**拆成 13 个 wave。
2. `SELFHOST.md`：补 S6–S8 表与 `next_com` 验收命令。
3. **不要**在本轨改 `run.sh`（轨 C 统一追加 case 块）。

**轨 A 完成判据**：

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-modules-full.lisp
# → 13× compile/run 绿
```

---

## 轨 B · engineer-b · 工厂矩阵（全局扩散）

**touch_paths**：

```text
samples/bootstrap-v45-factory-matrix.lisp
samples/bootstrap-v45-wave2-diffuse-global.lisp
v4.5/DIFFUSE-WAVE2.md
v4.5/CONCURRENT-IMPL.md
```

**实施清单**：

1. `factory-matrix.lisp`：`(file-size …)` **全部** `bootstrap-v45-*.lisp` + `v4.5/*.md` SSOT（一轮登记，允许多步 file-size）。
2. `wave2-diffuse-global.lisp`：锚定 Wave2 四轨 tick + `DIFFUSE-WAVE2.md` hash。
3. 不移动 `bootstrap-v4-wave*`（Wave3 批量归档）。

**轨 B 完成判据**：plan 无 `.c` 字符串；`factory-matrix` 覆盖 ≥28 个 v45 plan 路径。

---

## 轨 C · engineer-b · 收敛与门禁

**touch_paths**：

```text
scripts/v45-wave2-converge.sh
scripts/v45-com-verify.sh
run.sh                    ← 仅追加 wave2 case **一个连续块**
squad/catalog-v45.yaml
```

**实施清单**：

1. `v45-wave2-converge.sh`：顺序 = `v45-com-verify.sh` → 若存在 `v45-selfhost-next.com` 则跑 `verify-smoke` → 写 evidence 键。
2. `v45-com-verify.sh`：追加 `selfhost-modules-full` `factory-matrix` `wave2-diffuse-global`。
3. `run.sh`：**单块**追加 `run-bootstrap-v45-*-wave2-*` 与 evidence append（禁止散落多处）。

**环境**（所有 genesis/compare/next）：

```bash
env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS
```

**轨 C 完成判据**：`bash lab/nano-lisp-jit/scripts/v45-wave2-converge.sh` exit 0。

---

## 轨 D · reviewer · 评估与 rollup

**touch_paths**：

```text
v4.5/EVAL.md
v4.5/REFLECTION.md
v4.5/PARALLEL.md
samples/bootstrap-v45-wave2-assess-tick.lisp
samples/bootstrap-v45-wave2-rollup.lisp
.build/v45-entry.evidence
```

**实施清单**：

1. `wave2-assess-tick`：锚定 EVAL/REFLECTION/DIFFUSE-WAVE2 + evidence 文件 size。
2. `wave2-rollup`：依赖 A/B/C 产物 file-size + catalog wave2 段。
3. `EVAL.md`：增 **Wave2 六维** 一行表；**scoped 100% 仍为 ✅**，另列 selfhost 代际 %。

**轨 D 完成判据**：`assess` 对 `v45-scoped-100` 仍绿；wave2 键写入 evidence。

---

## 合并顺序（收敛轮）

```text
1. git merge 四轨（冲突优先保留 A 的 modules-full、C 的 run.sh 单块）
2. bash lab/nano-lisp-jit/scripts/v45-wave2-converge.sh
3. 仅失败项洋葱修（内圈 genesis → modules → 文档）
4. 禁止「修一点再开 wave3」— Wave3 整表登记后一次扩散
```

## 并发槽位图

```text
         engineer-a          engineer-b          reviewer
Slot1    modules-full        factory-matrix      (wait)
Slot2    SELFHOST S6–S8      wave2-diffuse       assess-tick
Slot3    next-verify锚点      converge.sh扩写     rollup
Slot4    —                   com-verify扩写      EVAL/REFLECTION
```

---

## Agent 单进程等价四轨（无 tmux）

按 **A → B → C → D** 顺序改文件，但 **每轨内一批文件一次提交**；最后只跑一次 converge（等同四轨并行后收敛）。
