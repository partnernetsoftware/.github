#!/usr/bin/env python3
import re
import struct
import sys

MAGIC = b"LJIRB1\0\0"
VERSION = 1

SIGS = {"u64(ptr)": 1}
CONST_STRING = 1
OP_CALL_IMPORT_CONST = 1
OP_RET_LAST = 2


def tokenize(src):
    src = re.sub(r";[^\n]*", "", src)
    return re.findall(r'"(?:\\.|[^"])*"|[()]|[^()\s]+', src)


def parse_expr(tokens):
    if not tokens:
        raise ValueError("unexpected end of input")
    tok = tokens.pop(0)
    if tok == "(":
        out = []
        while tokens and tokens[0] != ")":
            out.append(parse_expr(tokens))
        if not tokens:
            raise ValueError("missing ')'")
        tokens.pop(0)
        return out
    if tok == ")":
        raise ValueError("unexpected ')'")
    if tok.startswith('"'):
        return bytes(tok[1:-1], "utf-8").decode("unicode_escape")
    return tok


def parse_module(src):
    tokens = tokenize(src)
    expr = parse_expr(tokens)
    if tokens:
        raise ValueError("trailing tokens")
    if not isinstance(expr, list) or not expr or expr[0] != "module":
        raise ValueError("expected (module ...)")
    return expr[1:]


def add_string(pool, s):
    data = s.encode("utf-8") + b"\0"
    off = len(pool)
    pool.extend(data)
    return off


def compile_forms(forms):
    imports = []
    consts = []
    import_index = {}
    const_index = {}
    main_call = None

    for form in forms:
        if not isinstance(form, list) or not form:
            raise ValueError("forms must be lists")
        if form[0] == "import":
            if len(form) != 5:
                raise ValueError("import form: (import name lib symbol sig)")
            name, lib, symbol, sig = form[1:]
            if sig not in SIGS:
                raise ValueError(f"unsupported signature: {sig}")
            import_index[name] = len(imports)
            imports.append((lib, symbol, SIGS[sig]))
        elif form[0] == "const":
            if len(form) != 3:
                raise ValueError("const form: (const name value)")
            name, value = form[1:]
            const_index[name] = len(consts)
            consts.append((CONST_STRING, value))
        elif form[0] == "main":
            if len(form) != 2 or not isinstance(form[1], list):
                raise ValueError("main form: (main (call import const))")
            call = form[1]
            if len(call) != 3 or call[0] != "call":
                raise ValueError("main supports only (call import const)")
            main_call = (call[1], call[2])
        else:
            raise ValueError(f"unknown form: {form[0]}")

    if main_call is None:
        raise ValueError("missing main form")
    if main_call[0] not in import_index:
        raise ValueError(f"unknown import: {main_call[0]}")
    if main_call[1] not in const_index:
        raise ValueError(f"unknown const: {main_call[1]}")

    strings = bytearray()
    import_rows = []
    for lib, symbol, sig in imports:
        import_rows.append((add_string(strings, lib), add_string(strings, symbol), sig, 0))

    const_rows = []
    for typ, value in consts:
        off = add_string(strings, value)
        const_rows.append((typ, off, len(value.encode("utf-8")), 0))

    instr_rows = [
        (OP_CALL_IMPORT_CONST, import_index[main_call[0]], const_index[main_call[1]]),
        (OP_RET_LAST, 0, 0),
    ]

    header = struct.pack(
        "<8sIIIIII",
        MAGIC,
        VERSION,
        0,
        len(import_rows),
        len(const_rows),
        len(instr_rows),
        len(strings),
    )
    body = bytearray()
    for row in import_rows:
        body.extend(struct.pack("<IIII", *row))
    for row in const_rows:
        body.extend(struct.pack("<IIII", *row))
    for op, a, b in instr_rows:
        body.extend(struct.pack("<B3xII", op, a, b))
    body.extend(strings)
    return header + body


def main(argv):
    if len(argv) != 3:
        print("usage: compile_blob.py input.lispir output.ljir", file=sys.stderr)
        return 2
    with open(argv[1], "r", encoding="utf-8") as f:
        forms = parse_module(f.read())
    blob = compile_forms(forms)
    with open(argv[2], "wb") as f:
        f.write(blob)
    print(f"blob.bytes={len(blob)}")
    print(f"blob.path={argv[2]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
