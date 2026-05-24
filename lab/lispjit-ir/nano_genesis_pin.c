/* Included from lispjit.c after nano_cc.c — genesis-pinned slices (zero host cc for lispjit.c). */

static int build_slice_is_lispjit_c(const char *src_path) {
  const char *base = src_path;
  const char *slash;
  if (!src_path) return 0;
  slash = strrchr(src_path, '/');
  if (slash) base = slash + 1;
  return strcmp(base, "lispjit.c") == 0;
}

static const char *genesis_pin_path_for_arch(const char *arch) {
  if (strcmp(arch, "x86_64") == 0 || strcmp(arch, "amd64") == 0)
    return "lab/nano-lisp-jit/genesis/nano-jit.x86_64";
  if (strcmp(arch, "aarch64") == 0 || strcmp(arch, "arm64") == 0)
    return "lab/nano-lisp-jit/genesis/nano-jit.aarch64";
  return NULL;
}

static int build_slice_allow_host_cc(void) {
  const char *regen = getenv("NANO_REGENESIS");
  const char *allow = getenv("NANO_SLICE_ALLOW_HOST_CC");
  if (regen && regen[0] == '1' && regen[1] == '\0') return 1;
  if (allow && allow[0] == '1') return 1;
  return 0;
}

static int build_slice_use_genesis_pin(const char *src_path) {
  return build_slice_is_lispjit_c(src_path) && !build_slice_allow_host_cc();
}

static int build_slice_copy_genesis_pin(const char *pin_path, const char *out_path) {
  size_t n = 0;
  unsigned char *data = read_file(pin_path, &n);
  if (!data) {
    fprintf(stderr, "build-slice=genesis_pin_missing path=%s\n", pin_path);
    return 1;
  }
  if (!write_file(out_path, data, n)) {
    fprintf(stderr, "build-slice=genesis_pin_write_fail path=%s\n", out_path);
    free(data);
    return 3;
  }
  if (!make_executable(out_path)) {
    fprintf(stderr, "build-slice=genesis_pin_chmod_fail path=%s\n", out_path);
    free(data);
    return 3;
  }
  free(data);
  return 0;
}

static int build_slice_via_genesis_pin(const char *src_path, const char *out_path,
                                       const char *arch) {
  const char *pin = genesis_pin_path_for_arch(arch);
  int rc;
  if (!pin) {
    fprintf(stderr, "build-slice=genesis_pin_bad_arch arch=%s\n", arch);
    return 2;
  }
  printf("build-slice.compiler=none\n");
  printf("build-slice.arch=%s\n", arch);
  printf("build-slice.role=genesis-pin\n");
  printf("build-slice.genesis_pin=%s\n", pin);
  printf("build-slice.source=%s\n", src_path);
  printf("build-slice.output=%s\n", out_path);
  rc = build_slice_copy_genesis_pin(pin, out_path);
  if (rc != 0) return rc;
  return cmd_file_size(out_path);
}
