/* Included from lispjit.c — lbin/ljir VM execute, dump, resolve, run. */
#if !defined(_WIN32)
#include <sys/mman.h>
#endif
static int checked_span(size_t size, size_t off, size_t count, size_t each) {
  return off <= size && count <= (size - off) / each;
}

static int blob_init(Blob *b, unsigned char *data, size_t size) {
  static const unsigned char lbin_magic[8] = {'L', 'B', 'I', 'N', '0', '1', 0, 0};
  static const unsigned char ljir_magic[8] = {'L', 'J', 'I', 'R', 'B', '1', 0, 0};
  if (size < HEADER_SIZE) return 0;
  if (memcmp(data, lbin_magic, sizeof(lbin_magic)) == 0) {
    b->format = 1;
  } else if (memcmp(data, ljir_magic, sizeof(ljir_magic)) == 0) {
    b->format = 2;
  } else {
    return 0;
  }
  b->data = data;
  b->size = size;
  b->version = rd32(data + 8);
  b->func_count = rd32(data + 12);
  b->import_count = rd32(data + 16);
  b->const_count = rd32(data + 20);
  b->instr_count = rd32(data + 24);
  b->string_size = rd32(data + 28);
  b->import_off = HEADER_SIZE;
  b->const_off = b->import_off + (size_t)b->import_count * IMPORT_SIZE;
  b->instr_off = b->const_off + (size_t)b->const_count * CONST_SIZE;
  b->string_off = b->instr_off + (size_t)b->instr_count * INSTR_SIZE;
  b->func_off = b->string_off + (size_t)b->string_size;
  if (!checked_span(size, b->import_off, b->import_count, IMPORT_SIZE)) return 0;
  if (!checked_span(size, b->const_off, b->const_count, CONST_SIZE)) return 0;
  if (!checked_span(size, b->instr_off, b->instr_count, INSTR_SIZE)) return 0;
  if (!checked_span(size, b->string_off, b->string_size, 1)) return 0;
  if (!checked_span(size, b->func_off, b->func_count, FUNC_ENTRY_SIZE)) return 0;
  if (b->func_off + (size_t)b->func_count * FUNC_ENTRY_SIZE != size) {
    if (b->func_count == 0 && b->string_off + b->string_size == size) {
      b->func_off = size;
    } else {
      return 0;
    }
  }
  return b->version == 1;
}

static const char *blob_string(const Blob *b, uint32_t off) {
  if (off >= b->string_size) return NULL;
  const char *s = (const char *)(b->data + b->string_off + off);
  return memchr(s, 0, b->string_size - off) ? s : NULL;
}

static const unsigned char *import_row(const Blob *b, uint32_t idx) {
  return idx < b->import_count ? b->data + b->import_off + (size_t)idx * IMPORT_SIZE : NULL;
}

static const unsigned char *const_row(const Blob *b, uint32_t idx) {
  return idx < b->const_count ? b->data + b->const_off + (size_t)idx * CONST_SIZE : NULL;
}

static const unsigned char *instr_row(const Blob *b, uint32_t idx) {
  return idx < b->instr_count ? b->data + b->instr_off + (size_t)idx * INSTR_SIZE : NULL;
}

static const unsigned char *func_entry_row(const Blob *b, uint32_t idx) {
  return idx < b->func_count ? b->data + b->func_off + (size_t)idx * FUNC_ENTRY_SIZE : NULL;
}

static void *open_named_library(const char *name) {
#if defined(_WIN32)
  if (strcmp(name, "libc") == 0) {
    void *h = LoadLibraryA("ucrtbase.dll");
    return h ? h : LoadLibraryA("msvcrt.dll");
  }
  return LoadLibraryA(name);
#elif defined(__COSMOPOLITAN__)
  if (strcmp(name, "libc") == 0) {
    void *h = cosmo_dlopen(NULL, RTLD_LAZY);
    if (h) return h;
    h = cosmo_dlopen("libc.so.6", RTLD_LAZY);
    return h ? h : cosmo_dlopen("libc.so", RTLD_LAZY);
  }
  return cosmo_dlopen(name, RTLD_LAZY);
#else
  if (strcmp(name, "libc") == 0) {
#if defined(__APPLE__)
    return dlopen("libSystem.B.dylib", RTLD_LAZY);
#else
    void *h = dlopen("libc.so.6", RTLD_LAZY);
    return h ? h : dlopen("libc.so", RTLD_LAZY);
#endif
  }
  return dlopen(name, RTLD_LAZY);
#endif
}

static void *load_symbol(void *handle, const char *name) {
#if defined(_WIN32)
  return (void *)GetProcAddress((HMODULE)handle, name);
#elif defined(__COSMOPOLITAN__)
  return cosmo_dlsym(handle, name);
#else
  return dlsym(handle, name);
#endif
}

static void *alloc_exec(size_t n) {
#if defined(_WIN32)
  return VirtualAlloc(NULL, n, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
#else
  void *p = mmap(NULL, n, PROT_READ | PROT_WRITE | PROT_EXEC,
                 MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  return p == MAP_FAILED ? NULL : p;
#endif
}

static void patch64(unsigned char *p, uint64_t v) {
  for (int i = 0; i < 8; ++i) p[i] = (unsigned char)((v >> (i * 8)) & 0xff);
}

static void *emit_u64_ptr_call(void *fn, const char *arg, size_t *out_n) {
#if defined(__x86_64__) || defined(_M_X64)
  unsigned char code[] = {
#if defined(_WIN32)
    0x48, 0xb9, 0, 0, 0, 0, 0, 0, 0, 0,
#else
    0x48, 0xbf, 0, 0, 0, 0, 0, 0, 0, 0,
#endif
    0x48, 0xb8, 0, 0, 0, 0, 0, 0, 0, 0,
    0xff, 0xd0,
    0xc3
  };
  patch64(code + 2, (uint64_t)(uintptr_t)arg);
  patch64(code + 12, (uint64_t)(uintptr_t)fn);
#elif defined(__aarch64__) || defined(_M_ARM64)
  unsigned char code[] = {
    0x80, 0x00, 0x00, 0x58, 0xb0, 0x00, 0x00, 0x58,
    0x00, 0x02, 0x3f, 0xd6, 0xc0, 0x03, 0x5f, 0xd6,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  patch64(code + 16, (uint64_t)(uintptr_t)arg);
  patch64(code + 24, (uint64_t)(uintptr_t)fn);
#else
  (void)fn;
  (void)arg;
  (void)out_n;
  return NULL;
#endif
  void *mem = alloc_exec(sizeof(code));
  if (!mem) return NULL;
  memcpy(mem, code, sizeof(code));
#if defined(__GNUC__) || defined(__clang__)
  __builtin___clear_cache((char *)mem, (char *)mem + sizeof(code));
#endif
  *out_n = sizeof(code);
  return mem;
}

static int blob_load_path(const char *path, Blob *b, unsigned char **owned) {
  size_t n = 0;
  unsigned char *data = read_file(path, &n);
  if (!data) return 0;
  if (!blob_init(b, data, n)) {
    free(data);
    return 0;
  }
  *owned = data;
  return 1;
}

typedef struct {
  const char *lib;
  const char *sym;
  uint32_t sig;
  void *handle;
  void *fn;
} RuntimeImport;

static int resolve_import_ref(const Blob *b, uint32_t idx, RuntimeImport *out) {
  const unsigned char *imp = import_row(b, idx);
  if (!imp) return 12;
  out->lib = blob_string(b, rd32(imp));
  out->sym = blob_string(b, rd32(imp + 4));
  out->sig = rd32(imp + 8);
  if (!out->lib || !out->sym) return 13;
  out->handle = open_named_library(out->lib);
  if (!out->handle) {
    fprintf(stderr, "ffi.open=fail lib=%s\n", out->lib);
    return 14;
  }
  out->fn = load_symbol(out->handle, out->sym);
  if (!out->fn) {
    fprintf(stderr, "ffi.symbol=fail symbol=%s\n", out->sym);
    return 15;
  }
  return 0;
}

static const char *const_string_ref(const Blob *b, uint32_t idx) {
  const unsigned char *con = const_row(b, idx);
  if (!con || rd32(con) != CONST_STRING) return NULL;
  return blob_string(b, rd32(con + 4));
}

static int call_import1(const RuntimeImport *ri, const char *arg, Value *out) {
  if (!arg) return 13;
  if (ri->sig == SIG_U64_PTR) {
    size_t code_n = 0;
    void *entry = emit_u64_ptr_call(ri->fn, arg, &code_n);
    if (!entry) return 16;
    *out = value_u64(((jit_entry_fn)entry)());
    fprintf(stderr, "jit.code.bytes=%zu\n", code_n);
    return 0;
  }
  if (ri->sig == SIG_I32_PTR) {
    *out = value_i64((int64_t)((ffi_i32_ptr_fn)ri->fn)(arg));
    return 0;
  }
  fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
  return 17;
}

static int call_import2(const RuntimeImport *ri, const char *arg0, const char *arg1, Value *out) {
  if (!arg0 || !arg1) return 13;
  if (ri->sig != SIG_I32_PTR_PTR) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = value_i64((int64_t)((ffi_i32_ptr_ptr_fn)ri->fn)(arg0, arg1));
  return 0;
}

static int call_import0(const RuntimeImport *ri, Value *out) {
  if (ri->sig != SIG_I32_VOID) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = value_i64((int64_t)((ffi_i32_void_fn)ri->fn)());
  return 0;
}

static int call_import_i32(const RuntimeImport *ri, int32_t arg, Value *out) {
  if (ri->sig != SIG_I32_I32) {
    fprintf(stderr, "signature.arg_mismatch=%s\n", sig_name(ri->sig));
    return 17;
  }
  *out = value_i64((int64_t)((ffi_i32_i32_fn)ri->fn)((int)arg));
  return 0;
}

static int resolve_blob(const Blob *b, int quiet) {
  uint32_t ok = 0;
  for (uint32_t i = 0; i < b->import_count; ++i) {
    RuntimeImport ri = {0};
    int rc = resolve_import_ref(b, i, &ri);
    if (rc != 0) return rc;
    ok++;
    if (!quiet) {
      printf("resolve.%u=%s:%s sig=%s ok\n", i, ri.lib, ri.sym, sig_name(ri.sig));
    }
  }
  printf("resolve.imports=%u\n", b->import_count);
  printf("resolve.ok=%u\n", ok);
  return 0;
}

static uint64_t value_as_call_arg(Value v) {
  if (v.kind == VAL_U64) return v.bits;
  if (v.kind == VAL_I64) return v.bits;
  return UINT64_MAX;
}

static int execute_func_range(const Blob *b, uint32_t start, uint32_t end, uint64_t arg,
                              Value *out) {
  Value slots[2] = {value_i64((int64_t)arg), value_i64(0)};
  Value last = value_u64(arg);
  uint32_t pc = start;
  while (pc < end) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) return 10;
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    if (op == OP_LOAD_ARG_I64) {
      if (arg0 >= 2u) {
        fprintf(stderr, "func.load-arg-i64.%u=bad_index %u\n", pc, arg0);
        return 24;
      }
      last = slots[arg0];
      printf("func.load-arg-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_U64) {
      last = value_u64((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      printf("func.u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_I64) {
      last = value_i64((int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32)));
      printf("func.i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_U64) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_add_u64(&last, rhs)) {
        fprintf(stderr, "func.type.add-u64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("func.add-u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_add_i64(&last, rhs)) {
        fprintf(stderr, "func.type.add-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("func.add-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    fprintf(stderr, "func.unsupported.op=%u\n", op);
    return 11;
  }
  *out = last;
  return 0;
}

static int execute_blob(const Blob *b) {
  Value last = value_u64(0);
  uint32_t pc = 0;
  while (pc < b->instr_count) {
    const unsigned char *ins = instr_row(b, pc);
    if (!ins) return 10;
    uint8_t op = ins[0];
    uint32_t arg0 = rd32(ins + 4);
    uint32_t arg1 = rd32(ins + 8);
    RuntimeImport ri = {0};
    int rc = 0;
    if (op == OP_RET_LAST) {
      printf("ret=");
      print_value(stdout, last);
      printf("\n");
      return 0;
    }
    if (op == OP_RESOLVE_IMPORT) {
      rc = resolve_import_ref(b, arg0, &ri);
      if (rc != 0) return rc;
      last = value_ptr(ri.fn);
      printf("resolve.%u=%s:%s sig=%s ok\n", pc, ri.lib, ri.sym, sig_name(ri.sig));
      pc++;
      continue;
    }
    if (op == OP_EXPECT_U64) {
      uint64_t expected = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_expect_u64(last, expected)) {
        fprintf(stderr, "expect.%u=fail expected=%llu actual=", pc,
                (unsigned long long)expected);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%llu\n", pc, (unsigned long long)expected);
      pc++;
      continue;
    }
    if (op == OP_EXPECT_I64) {
      int64_t expected = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_expect_i64(last, expected)) {
        fprintf(stderr, "expect.%u=fail expected=%lld actual=", pc, (long long)expected);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%lld\n", pc, (long long)expected);
      pc++;
      continue;
    }
    if (op == OP_EXPECT_BOOL) {
      if (!value_expect_bool(last, (int)arg0)) {
        fprintf(stderr, "expect.%u=fail expected=%s actual=", pc, arg0 ? "true" : "false");
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%s\n", pc, arg0 ? "true" : "false");
      pc++;
      continue;
    }
    if (op == OP_EXPECT_PTR) {
      if (!value_expect_ptr(last, (int)arg0)) {
        fprintf(stderr, "expect.%u=fail expected=%s actual=", pc, arg0 ? "nonnull" : "null");
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 19;
      }
      printf("expect.%u=ok expected=%s\n", pc, arg0 ? "nonnull" : "null");
      pc++;
      continue;
    }
    if (op == OP_BRANCH_BOOL) {
      if (last.kind != VAL_BOOL) {
        fprintf(stderr, "type.branch=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 21;
      }
      if (arg0 >= b->instr_count) {
        fprintf(stderr, "branch.%u=bad_target %u\n", pc, arg0);
        return 22;
      }
      printf("branch.%u=%s target=%u\n", pc, last.bits ? "taken" : "not-taken", arg0);
      pc = last.bits ? arg0 : pc + 1;
      continue;
    }
    if (op == OP_CONST_U64) {
      last = value_u64((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      printf("u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_I64) {
      last = value_i64((int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32)));
      printf("i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_BOOL) {
      last = value_bool((int)arg0);
      printf("bool.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_NULL_PTR) {
      last = value_ptr(NULL);
      printf("null-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_PTR) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_add_ptr(&last, rhs)) {
        fprintf(stderr, "type.add-ptr=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("add-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_SUB_PTR) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_sub_ptr(&last, rhs)) {
        fprintf(stderr, "type.sub-ptr=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("sub-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_PTR_TO_U64) {
      if (!value_ptr_to_u64(&last)) {
        fprintf(stderr, "type.ptr-to-u64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("ptr-to-u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_U64_TO_PTR) {
      if (!value_u64_to_ptr(&last)) {
        fprintf(stderr, "type.u64-to-ptr=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("u64-to-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CONST_PTR) {
      const char *s = const_string_ref(b, arg0);
      if (!s) {
        fprintf(stderr, "const-ptr.%u=bad_const %u\n", pc, arg0);
        return 23;
      }
      last = value_ptr(s);
      printf("const-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_LOAD_U8) {
      if (!value_load_u8(&last)) {
        fprintf(stderr, "type.load-u8=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("load-u8.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_LOAD_U16) {
      if (!value_load_u16(&last)) {
        fprintf(stderr, "type.load-u16=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("load-u16.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_LOAD_U32) {
      if (!value_load_u32(&last)) {
        fprintf(stderr, "type.load-u32=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("load-u32.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_STORE_U8) {
      uint64_t byte = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_store_u8(&last, byte)) {
        fprintf(stderr, "type.store-u8=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("store-u8.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_STORE_U16) {
      uint64_t word = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_store_u16(&last, word)) {
        fprintf(stderr, "type.store-u16=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("store-u16.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_STORE_U32) {
      uint64_t dword = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_store_u32(&last, dword)) {
        fprintf(stderr, "type.store-u32=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("store-u32.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_IS_NULL_PTR) {
      if (!value_is_null_ptr(&last)) {
        fprintf(stderr, "type.is-null-ptr=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("is-null-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_IS_NONNULL_PTR) {
      if (!value_is_nonnull_ptr(&last)) {
        fprintf(stderr, "type.is-nonnull-ptr=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("is-nonnull-ptr.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_NOT_BOOL) {
      if (!value_not_bool(&last)) {
        fprintf(stderr, "type.not-bool=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("not-bool.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_AND_BOOL) {
      if (!value_and_bool(&last, (int)arg0)) {
        fprintf(stderr, "type.and-bool=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("and-bool.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_OR_BOOL) {
      if (!value_or_bool(&last, (int)arg0)) {
        fprintf(stderr, "type.or-bool=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("or-bool.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_U64) {
      uint64_t rhs = (uint64_t)arg0 | ((uint64_t)arg1 << 32);
      if (!value_add_u64(&last, rhs)) {
        fprintf(stderr, "type.add-u64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("add-u64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_ADD_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_add_i64(&last, rhs)) {
        fprintf(stderr, "type.add-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("add-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_SUB_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_sub_i64(&last, rhs)) {
        fprintf(stderr, "type.sub-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("sub-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_MUL_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_mul_i64(&last, rhs)) {
        fprintf(stderr, "type.mul-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("mul-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_EQ_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_eq_i64(&last, rhs)) {
        fprintf(stderr, "type.eq-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("eq-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_LT_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_lt_i64(&last, rhs)) {
        fprintf(stderr, "type.lt-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("lt-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_GT_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_gt_i64(&last, rhs)) {
        fprintf(stderr, "type.gt-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("gt-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_NE_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_ne_i64(&last, rhs)) {
        fprintf(stderr, "type.ne-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("ne-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_LE_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_le_i64(&last, rhs)) {
        fprintf(stderr, "type.le-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("le-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_GE_I64) {
      int64_t rhs = (int64_t)((uint64_t)arg0 | ((uint64_t)arg1 << 32));
      if (!value_ge_i64(&last, rhs)) {
        fprintf(stderr, "type.ge-i64=%u actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      printf("ge-i64.%u=", pc);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    if (op == OP_CALL_FUNC) {
      const unsigned char *entry = func_entry_row(b, arg0);
      uint64_t call_arg;
      uint32_t start;
      uint32_t len;
      if (!entry) {
        fprintf(stderr, "call-func.%u=bad_index %u\n", pc, arg0);
        return 24;
      }
      call_arg = value_as_call_arg(last);
      if (call_arg == UINT64_MAX) {
        fprintf(stderr, "call-func.%u=bad_arg actual=", pc);
        print_value(stderr, last);
        fprintf(stderr, "\n");
        return 20;
      }
      start = rd32(entry);
      len = rd32(entry + 4);
      if (start + len > b->instr_count) {
        fprintf(stderr, "call-func.%u=bad_range start=%u len=%u\n", pc, start, len);
        return 24;
      }
      rc = execute_func_range(b, start, start + len, call_arg, &last);
      if (rc != 0) return rc;
      printf("call-func.%u=idx%u result=", pc, arg0);
      print_value(stdout, last);
      printf("\n");
      pc++;
      continue;
    }
    rc = resolve_import_ref(b, arg0, &ri);
    if (rc != 0) return rc;
    if (op == OP_CALL_IMPORT_CONST) {
      rc = call_import1(&ri, const_string_ref(b, arg1), &last);
    } else if (op == OP_CALL_IMPORT_CONST2) {
      uint32_t c0 = arg1 & 0xffffu;
      uint32_t c1 = arg1 >> 16;
      rc = call_import2(&ri, const_string_ref(b, c0), const_string_ref(b, c1), &last);
    } else if (op == OP_CALL_IMPORT_VOID) {
      rc = call_import0(&ri, &last);
    } else if (op == OP_CALL_IMPORT_IMM) {
      rc = call_import_i32(&ri, (int32_t)arg1, &last);
    } else {
      fprintf(stderr, "unsupported.op=%u\n", op);
      return 11;
    }
    if (rc != 0) return rc;
    printf("call.%u=%s:%s result=", pc, ri.lib, ri.sym);
    print_value(stdout, last);
    printf("\n");
    pc++;
  }
  fprintf(stderr, "missing.ret\n");
  return 18;
}

static int dump_blob(const Blob *b) {
  printf("blob.format=%s\n", b->format == 1 ? "lbin" : "legacy-ljir");
  printf("blob.version=%u\n", b->version);
  printf("blob.imports=%u\n", b->import_count);
  printf("blob.consts=%u\n", b->const_count);
  printf("blob.instructions=%u\n", b->instr_count);
  printf("blob.strings=%u\n", b->string_size);
  for (uint32_t i = 0; i < b->import_count; ++i) {
    const unsigned char *r = import_row(b, i);
    uint32_t sig = rd32(r + 8);
    printf("import.%u=%s:%s sig=%s(%u)\n", i, blob_string(b, rd32(r)),
           blob_string(b, rd32(r + 4)), sig_name(sig), sig);
  }
  return 0;
}
static int cmd_run(const char *blob_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int rc = execute_blob(&b);
  free(owned);
  return rc;
}
static int cmd_dump(const char *blob_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int rc = dump_blob(&b);
  free(owned);
  return rc;
}

static int cmd_hash(const char *blob_path) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  printf("blob.bytes=%zu\n", b.size);
  printf("blob.fnv1a64=%016llx\n", (unsigned long long)fnv1a64(owned, b.size));
  free(owned);
  return 0;
}
static int cmd_resolve(const char *blob_path, int quiet) {
  Blob b;
  unsigned char *owned = NULL;
  if (!blob_load_path(blob_path, &b, &owned)) {
    fprintf(stderr, "blob=parse_fail path=%s\n", blob_path);
    return 1;
  }
  int rc = resolve_blob(&b, quiet);
  free(owned);
  return rc;
}
