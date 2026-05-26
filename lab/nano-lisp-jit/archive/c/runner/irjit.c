#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <dlfcn.h>
#include <sys/mman.h>
#endif

#define HEADER_SIZE 32u
#define IMPORT_SIZE 16u
#define CONST_SIZE 16u
#define INSTR_SIZE 12u

#define SIG_U64_PTR 1u
#define CONST_STRING 1u
#define OP_CALL_IMPORT_CONST 1u
#define OP_RET_LAST 2u

typedef uint64_t (*jit_entry_fn)(void);

typedef struct {
  unsigned char *data;
  size_t size;
  uint32_t version;
  uint32_t import_count;
  uint32_t const_count;
  uint32_t instr_count;
  uint32_t string_size;
  size_t import_off;
  size_t const_off;
  size_t instr_off;
  size_t string_off;
} Blob;

static uint32_t rd32(const unsigned char *p) {
  return ((uint32_t)p[0]) |
         ((uint32_t)p[1] << 8) |
         ((uint32_t)p[2] << 16) |
         ((uint32_t)p[3] << 24);
}

static int checked_span(size_t size, size_t off, size_t count, size_t each) {
  return off <= size && count <= (size - off) / each;
}

static unsigned char *read_file(const char *path, size_t *out_size) {
  FILE *f = fopen(path, "rb");
  if (!f) return NULL;
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    return NULL;
  }
  long n = ftell(f);
  if (n < 0) {
    fclose(f);
    return NULL;
  }
  rewind(f);
  unsigned char *buf = (unsigned char *)malloc((size_t)n);
  if (!buf) {
    fclose(f);
    return NULL;
  }
  if (fread(buf, 1, (size_t)n, f) != (size_t)n) {
    free(buf);
    fclose(f);
    return NULL;
  }
  fclose(f);
  *out_size = (size_t)n;
  return buf;
}

static int blob_init(Blob *b, unsigned char *data, size_t size) {
  static const unsigned char magic[8] = {'L', 'J', 'I', 'R', 'B', '1', 0, 0};
  if (size < HEADER_SIZE || memcmp(data, magic, sizeof(magic)) != 0) {
    return 0;
  }

  b->data = data;
  b->size = size;
  b->version = rd32(data + 8);
  b->import_count = rd32(data + 16);
  b->const_count = rd32(data + 20);
  b->instr_count = rd32(data + 24);
  b->string_size = rd32(data + 28);
  b->import_off = HEADER_SIZE;
  b->const_off = b->import_off + (size_t)b->import_count * IMPORT_SIZE;
  b->instr_off = b->const_off + (size_t)b->const_count * CONST_SIZE;
  b->string_off = b->instr_off + (size_t)b->instr_count * INSTR_SIZE;

  if (!checked_span(size, b->import_off, b->import_count, IMPORT_SIZE)) return 0;
  if (!checked_span(size, b->const_off, b->const_count, CONST_SIZE)) return 0;
  if (!checked_span(size, b->instr_off, b->instr_count, INSTR_SIZE)) return 0;
  if (!checked_span(size, b->string_off, b->string_size, 1)) return 0;
  if (b->string_off + b->string_size != size) return 0;
  return b->version == 1;
}

static const char *blob_string(const Blob *b, uint32_t off) {
  if (off >= b->string_size) return NULL;
  const char *s = (const char *)(b->data + b->string_off + off);
  const void *end = memchr(s, 0, b->string_size - off);
  return end ? s : NULL;
}

static const unsigned char *import_row(const Blob *b, uint32_t idx) {
  if (idx >= b->import_count) return NULL;
  return b->data + b->import_off + (size_t)idx * IMPORT_SIZE;
}

static const unsigned char *const_row(const Blob *b, uint32_t idx) {
  if (idx >= b->const_count) return NULL;
  return b->data + b->const_off + (size_t)idx * CONST_SIZE;
}

static const unsigned char *instr_row(const Blob *b, uint32_t idx) {
  if (idx >= b->instr_count) return NULL;
  return b->data + b->instr_off + (size_t)idx * INSTR_SIZE;
}

static void *open_named_library(const char *name) {
#if defined(_WIN32)
  if (strcmp(name, "libc") == 0) {
    void *h = LoadLibraryA("ucrtbase.dll");
    return h ? h : LoadLibraryA("msvcrt.dll");
  }
  return LoadLibraryA(name);
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
  for (int i = 0; i < 8; ++i) {
    p[i] = (unsigned char)((v >> (i * 8)) & 0xff);
  }
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
    0x80, 0x00, 0x00, 0x58,
    0xb0, 0x00, 0x00, 0x58,
    0x00, 0x02, 0x3f, 0xd6,
    0xc0, 0x03, 0x5f, 0xd6,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
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

static int execute_blob(const Blob *b) {
  if (b->instr_count != 2) {
    fprintf(stderr, "unsupported.ir_shape=instruction_count\n");
    return 10;
  }

  const unsigned char *call = instr_row(b, 0);
  const unsigned char *ret = instr_row(b, 1);
  if (!call || !ret || call[0] != OP_CALL_IMPORT_CONST || ret[0] != OP_RET_LAST) {
    fprintf(stderr, "unsupported.ir_shape=ops\n");
    return 11;
  }

  uint32_t import_idx = rd32(call + 4);
  uint32_t const_idx = rd32(call + 8);
  const unsigned char *imp = import_row(b, import_idx);
  const unsigned char *con = const_row(b, const_idx);
  if (!imp || !con) {
    fprintf(stderr, "invalid.ir=index\n");
    return 12;
  }

  const char *lib = blob_string(b, rd32(imp));
  const char *sym = blob_string(b, rd32(imp + 4));
  uint32_t sig = rd32(imp + 8);
  uint32_t const_type = rd32(con);
  const char *arg = blob_string(b, rd32(con + 4));
  if (!lib || !sym || !arg || sig != SIG_U64_PTR || const_type != CONST_STRING) {
    fprintf(stderr, "unsupported.ir=signature_or_const\n");
    return 13;
  }

  void *handle = open_named_library(lib);
  if (!handle) {
    fprintf(stderr, "ffi.open=fail lib=%s\n", lib);
    return 14;
  }
  void *fn = load_symbol(handle, sym);
  if (!fn) {
    fprintf(stderr, "ffi.symbol=fail symbol=%s\n", sym);
    return 15;
  }

  size_t code_n = 0;
  void *entry = emit_u64_ptr_call(fn, arg, &code_n);
  if (!entry) {
    fprintf(stderr, "jit.emit=fail\n");
    return 16;
  }

  printf("blob.version=%u\n", b->version);
  printf("blob.imports=%u\n", b->import_count);
  printf("blob.consts=%u\n", b->const_count);
  printf("blob.instructions=%u\n", b->instr_count);
  printf("ffi.import=%s:%s\n", lib, sym);
  printf("jit.code.bytes=%zu\n", code_n);
  printf("jit.result.u64=%llu\n", (unsigned long long)((jit_entry_fn)entry)());
  return 0;
}

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s program.ljir\n", argv[0]);
    return 2;
  }

  size_t size = 0;
  unsigned char *data = read_file(argv[1], &size);
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", argv[1]);
    return 3;
  }

  Blob blob;
  if (!blob_init(&blob, data, size)) {
    fprintf(stderr, "blob=parse_fail\n");
    free(data);
    return 4;
  }

  printf("blob.bytes=%zu\n", size);
  int rc = execute_blob(&blob);
  free(data);
  return rc;
}
