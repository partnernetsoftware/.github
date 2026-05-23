# v3.5 nano-cc error codes

Extends [`../v3/ERROR-CODES.md`](../v3/ERROR-CODES.md).

## Slice 0（已签收）

| Exit | When | stderr tag |
|------|------|------------|
| **0** | compile OK | `nano-cc.exit_code=*` |
| **1** | bad args / read fail / expect mismatch | `nano-cc-compile-expect-exit=bad_args`, `nano-cc=read_fail` |
| **2** | unsupported C-subset | `nano-cc=unsupported_source` |
| **3** | ELF emit fail | `nano-cc=emit_fail` |

Negative sample: `samples/nano-cc-bad.c` → **exit 2** via `nano-cc-compile-expect-exit`.

## add-parse (slice 1)

C-subset frontend beyond `int main(){ return N; }` — token/parse/lower for `int add(int a,int b){ return a+b; }` and callers.

| Exit | When | stderr tag |
|------|------|------------|
| **0** | parse OK | stable dump on stdout (`nano-cc.parse.*`) |
| **1** | read fail / expect mismatch | `nano-cc=read_fail`, `nano-cc-parse-expect-exit=mismatch` |
| **2** | parse / lower reject | `nano-cc=add_parse_fail reason=*` |
| **2** | legacy alias (pre-add-parse) | `nano-cc=unsupported_source` + `reason=add_parse` in plan logs |

| reason | Sample |
|--------|--------|
| `unsupported_stmt` | signature/body/call pattern mismatch — `samples/nano-cc-add-bad-sig.c` (non-`int add`), `samples/nano-cc-add-bad-body.c` (`return a-b`) |
| `bad_signature` | reserved — non-`int` return or arity ≠ 2 (today reported as `unsupported_stmt`) |
| `bad_token` | reserved — lexer cannot tokenize input |
| `dump_mismatch` | `run.sh` `nano-cc-parse-add-golden` — stdout missing a line from `samples/nano-cc-add.parse.golden` |

Positive path: `samples/nano-cc-add.c` — `nano-cc parse` dump matches `samples/nano-cc-add.parse.golden`; compile + run exit matches hand-written `.lisp` 等价路径。

CLI: `nano-cc parse input.c` → stable dump on stdout (`nano-cc.parse.path=`, `kind=`, `add_a=`, `add_b=`, `exit_code=`); failures use **exit 2**.

`run.sh` gates: `nano-cc-parse-add-golden`, `nano-cc-parse-add-bad-expect2`, `nano-cc-parse-add-bad-body-expect2`.

## compile-obj emit (slice 2)

CLI: `nano-cc compile-obj input.c -o out.o` → relocatable ELF64 object (`main` immediate-return via `emit_elf64_obj_ret_file`); emit fail **exit 3** tag `nano-cc=emit_obj_fail`.

## build-slice-codegen (slice 3)

`cmd_build_slice` routing when `NANO_CC=1` or eligible TU should use nano-cc instead of host `cc` / genesis-pin.

| Exit | When | stderr tag |
|------|------|------------|
| **1** | bad args | `build-slice=bad_args` |
| **2** | nano-cc compile failed on routed path | `build-slice=codegen_fail` |
| **2** | source not in nano-cc TU set | `build-slice=nano_cc_unsupported path=*` |
| **2** | host `cc` fallback blocked | `build-slice=host_cc_fallback_disallowed` |
| **2** | arch not yet supported by nano-cc | `build-slice=nano_cc_arch_unsupported arch=*` |

Existing tags (v3 **4b-2** / slice 0): `build-slice.compiler=nano-cc`, `build-slice.role=lisp-codegen` for `nano-cc-hello.c`.

Target logs (slice 3 签收):

- `build-slice.role=nano-cc`
- `build-slice.compiler=nano-cc`
- **no** `build-slice.compiler=cc` unless `NANO_CC_FALLBACK=1`

| Env | Meaning |
|-----|---------|
| `NANO_CC=1` | prefer nano-cc for eligible sources (`lispjit.c` 子集) |
| `NANO_CC_FALLBACK=1` | allow host `cc` when nano-cc cannot compile |
| `NANO_BUILD_SLICE_CODEGEN=1` | v3 4b-2 dev flag (`nano-cc-hello.c` only today) |
| `NANO_SLICE_ALLOW_HOST_CC=1` | v3 genesis-pin 时代回退 host `cc`（slice 3 后 deprecated） |

Planned sample: `samples/bootstrap-v35-build-slice.lisp` — assert `build-slice.role=nano-cc` and no silent `stage0-bridge`.
