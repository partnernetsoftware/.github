/* Included from lispjit.c — FFI import signature IDs and parse/name helpers. */

#define SIG_ADDR 0u
#define SIG_U64_PTR 1u
#define SIG_I32_PTR 2u
#define SIG_I32_PTR_PTR 3u
#define SIG_I32_VOID 4u
#define SIG_I32_I32 5u

static uint32_t sig_parse(const char *sig) {
  if (strcmp(sig, "addr") == 0) return SIG_ADDR;
  if (strcmp(sig, "u64(ptr)") == 0) return SIG_U64_PTR;
  if (strcmp(sig, "i32(ptr)") == 0) return SIG_I32_PTR;
  if (strcmp(sig, "i32(ptr,ptr)") == 0) return SIG_I32_PTR_PTR;
  if (strcmp(sig, "i32()") == 0) return SIG_I32_VOID;
  if (strcmp(sig, "i32(i32)") == 0) return SIG_I32_I32;
  return UINT32_MAX;
}

static const char *sig_name(uint32_t sig) {
  switch (sig) {
    case SIG_ADDR: return "addr";
    case SIG_U64_PTR: return "u64(ptr)";
    case SIG_I32_PTR: return "i32(ptr)";
    case SIG_I32_PTR_PTR: return "i32(ptr,ptr)";
    case SIG_I32_VOID: return "i32()";
    case SIG_I32_I32: return "i32(i32)";
    default: return "unknown";
  }
}
