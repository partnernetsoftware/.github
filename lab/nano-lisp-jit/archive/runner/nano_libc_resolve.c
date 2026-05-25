/* Included from lispjit.c — ELF dynsym scrape, gen-libc-resolve CLI. */

static int str_cmp_ptr(const void *a, const void *b) {
  const char *const *sa = (const char *const *)a;
  const char *const *sb = (const char *const *)b;
  return strcmp(*sa, *sb);
}

static int ident_char_ok(char c) {
  return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
         (c >= '0' && c <= '9') || c == '_';
}

static char *libc_ident(const char *name, size_t index) {
  size_t n = strlen(name);
  char suffix[32];
  int suffix_n = snprintf(suffix, sizeof(suffix), "_%zu", index);
  int needs_prefix = n == 0 || (name[0] >= '0' && name[0] <= '9');
  size_t out_n = (needs_prefix ? 4u : 0u) + n + (size_t)suffix_n + 1u;
  char *out = (char *)malloc(out_n);
  if (!out) return NULL;
  size_t pos = 0;
  if (needs_prefix) {
    memcpy(out + pos, "sym_", 4);
    pos += 4;
  }
  for (size_t i = 0; i < n; ++i) out[pos++] = ident_char_ok(name[i]) ? name[i] : '_';
  memcpy(out + pos, suffix, (size_t)suffix_n + 1u);
  return out;
}

static int symbol_vec_push(char ***items, size_t *count, size_t *cap, const char *sym) {
  if (*count == *cap) {
    size_t next = *cap ? *cap * 2u : 256u;
    char **grown = (char **)realloc(*items, next * sizeof(**items));
    if (!grown) return 0;
    *items = grown;
    *cap = next;
  }
  (*items)[*count] = dup_cstr(sym);
  if (!(*items)[*count]) return 0;
  *count += 1u;
  return 1;
}

static const char *default_libc_path(void) {
  static const char *candidates[] = {
    "/lib/x86_64-linux-gnu/libc.so.6",
    "/lib64/libc.so.6",
    "/usr/lib/libc.so.6",
    "/usr/lib64/libc.so.6",
    NULL
  };
  for (size_t i = 0; candidates[i]; ++i) {
    FILE *f = fopen(candidates[i], "rb");
    if (f) {
      fclose(f);
      return candidates[i];
    }
  }
  return candidates[0];
}

static int collect_libc_dynsym_symbols(const char *libc_path, char ***symbols,
                                       size_t *symbol_count, size_t *symbol_cap) {
  enum {
    LOCAL_ELF64_EHDR_SIZE = 64,
    LOCAL_ELF64_SHDR_SIZE = 64,
    LOCAL_ELF64_SYM_SIZE = 24,
    LOCAL_SHT_STRTAB = 3,
    LOCAL_SHT_DYNSYM = 11,
    LOCAL_SHT_GNU_VERSYM = 0x6fffffff
  };
  size_t size = 0;
  unsigned char *data = read_file(libc_path, &size);
  if (!data) return 0;
  int ok = 0;
  if (size < LOCAL_ELF64_EHDR_SIZE || data[0] != 0x7f || data[1] != 'E' ||
      data[2] != 'L' || data[3] != 'F' || data[4] != 2 || data[5] != 1) {
    goto done;
  }
  uint64_t shoff = rd64(data + 40);
  uint16_t shentsize = rd16(data + 58);
  uint16_t shnum = rd16(data + 60);
  if (shentsize < LOCAL_ELF64_SHDR_SIZE || shoff > size ||
      shnum > (size - shoff) / shentsize) {
    goto done;
  }
  const unsigned char *shdr = data + shoff;
  for (uint16_t i = 1; i < shnum; ++i) {
    const unsigned char *sh = shdr + (size_t)i * shentsize;
    if (rd32(sh + 4) != LOCAL_SHT_DYNSYM) continue;
    uint64_t sym_off = rd64(sh + 24);
    uint64_t sym_size = rd64(sh + 32);
    uint32_t str_idx = rd32(sh + 40);
    uint64_t sym_entsize = rd64(sh + 56);
    if (sym_entsize != LOCAL_ELF64_SYM_SIZE || str_idx >= shnum ||
        sym_off > size || sym_size > size - sym_off) {
      goto done;
    }
    const unsigned char *str_sh = shdr + (size_t)str_idx * shentsize;
    if (rd32(str_sh + 4) != LOCAL_SHT_STRTAB) goto done;
    uint64_t str_off = rd64(str_sh + 24);
    uint64_t str_size = rd64(str_sh + 32);
    if (str_off > size || str_size > size - str_off) goto done;
    const unsigned char *strtab = data + str_off;
    const unsigned char *versym = NULL;
    size_t versym_count = 0;
    for (uint16_t v = 1; v < shnum; ++v) {
      const unsigned char *vsh = shdr + (size_t)v * shentsize;
      if (rd32(vsh + 4) != LOCAL_SHT_GNU_VERSYM || rd32(vsh + 40) != i) continue;
      uint64_t v_off = rd64(vsh + 24);
      uint64_t v_size = rd64(vsh + 32);
      if (v_off > size || v_size > size - v_off) goto done;
      versym = data + v_off;
      versym_count = (size_t)(v_size / 2u);
      break;
    }
    size_t nsyms = (size_t)(sym_size / sym_entsize);
    for (size_t s = 1; s < nsyms; ++s) {
      const unsigned char *sym = data + sym_off + s * sym_entsize;
      uint32_t name_off = rd32(sym);
      uint16_t shndx = rd16(sym + 6);
      if (shndx == 0 || name_off >= str_size) continue;
      if (versym && s < versym_count && (rd16(versym + s * 2u) & 0x8000u)) continue;
      const char *name = (const char *)strtab + name_off;
      if (!memchr(name, 0, (size_t)str_size - name_off)) continue;
      if (strncmp(name, "GLIBC_", 6) == 0 || strncmp(name, "GCC_", 4) == 0 || name[0] == 0) continue;
      if (!symbol_vec_push(symbols, symbol_count, symbol_cap, name)) goto done;
    }
  }
  ok = 1;
done:
  free(data);
  return ok;
}

static int cmd_gen_libc_resolve(const char *libc_path, const char *out_path) {
#if defined(_WIN32)
  (void)libc_path;
  (void)out_path;
  fprintf(stderr, "gen-libc-resolve=unsupported_platform\n");
  return 2;
#else
  if (!libc_path || !libc_path[0]) libc_path = default_libc_path();
  char **symbols = NULL;
  size_t symbol_count = 0;
  size_t symbol_cap = 0;
  int rc = 0;
  if (!collect_libc_dynsym_symbols(libc_path, &symbols, &symbol_count, &symbol_cap)) {
    fprintf(stderr, "gen-libc-resolve=dynsym_fail path=%s\n", libc_path);
    rc = 2;
  }
  if (rc == 0) {
    qsort(symbols, symbol_count, sizeof(*symbols), str_cmp_ptr);
    FILE *out = fopen(out_path, "wb");
    if (!out) {
      fprintf(stderr, "gen-libc-resolve=write_fail path=%s\n", out_path);
      rc = 3;
    } else {
      fprintf(out, "; Generated resolver manifest. It resolves exported libc symbols as addresses only.\n");
      fprintf(out, "(module\n");
      size_t emitted = 0;
      for (size_t i = 0; i < symbol_count; ++i) {
        if (i > 0 && strcmp(symbols[i], symbols[i - 1]) == 0) continue;
        char *name = libc_ident(symbols[i], emitted);
        if (!name) {
          rc = 2;
          break;
        }
        fprintf(out, "  (import %s \"libc\" \"%s\" \"addr\")\n", name, symbols[i]);
        free(name);
        emitted++;
      }
      fprintf(out, "  (main\n");
      emitted = 0;
      for (size_t i = 0; i < symbol_count; ++i) {
        if (i > 0 && strcmp(symbols[i], symbols[i - 1]) == 0) continue;
        char *name = libc_ident(symbols[i], emitted);
        if (!name) {
          rc = 2;
          break;
        }
        fprintf(out, "    (resolve %s)\n", name);
        free(name);
        emitted++;
      }
      fprintf(out, "  ))\n");
      if (fclose(out) != 0 && rc == 0) {
        fprintf(stderr, "gen-libc-resolve=close_fail path=%s\n", out_path);
        rc = 3;
      }
      if (rc == 0) {
        printf("libc.path=%s\n", libc_path);
        printf("symbols=%zu\n", emitted);
        printf("output=%s\n", out_path);
      }
    }
  }
  for (size_t i = 0; i < symbol_count; ++i) free(symbols[i]);
  free(symbols);
  return rc;
#endif
}
