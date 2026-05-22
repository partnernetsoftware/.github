/* Included from lispjit.c — APE pack/inspect/run (v1 manifest + v2 binary). */
#if !defined(_WIN32)
#include <sys/wait.h>
#endif
typedef struct {
  int found;
  char container[32];
  size_t x86_off;
  size_t x86_size;
  uint64_t x86_hash;
  int has_x86_hash;
  size_t arm_off;
  size_t arm_size;
  uint64_t arm_hash;
  int has_arm_hash;
  size_t payload_start;
} NanoApeManifest;

static int parse_ape_manifest(const unsigned char *data, size_t n, NanoApeManifest *m,
                              const char *error_prefix) {
  memset(m, 0, sizeof(*m));
  if (!find_payload_start(data, n, NANO_APE_PAYLOAD_MARKER, &m->payload_start)) {
    fprintf(stderr, "%s=payload_marker_missing\n", error_prefix);
    return 2;
  }
  int in_manifest = 0;
  size_t pos = 0;
  while (pos < n) {
    size_t line_start = pos;
    while (pos < n && data[pos] != '\n') pos++;
    size_t line_n = pos - line_start;
    if (pos < n && data[pos] == '\n') pos++;
    if (line_n == sizeof(NANO_MANIFEST_BEGIN) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_BEGIN, sizeof(NANO_MANIFEST_BEGIN) - 1) == 0) {
      in_manifest = 1;
      m->found = 1;
      continue;
    }
    if (line_n == sizeof(NANO_MANIFEST_END) - 1 &&
        memcmp(data + line_start, NANO_MANIFEST_END, sizeof(NANO_MANIFEST_END) - 1) == 0) {
      break;
    }
    if (in_manifest && line_n >= 2 && data[line_start] == '#' &&
        data[line_start + 1] == ' ') {
      fwrite(data + line_start + 2, 1, line_n - 2, stdout);
      fputc('\n', stdout);
    }
  }
  if (!m->found) {
    fprintf(stderr, "%s=manifest_missing\n", error_prefix);
    return 2;
  }
  if (!manifest_find_string(data, n, "nano.container", m->container, sizeof(m->container))) {
    fprintf(stderr, "%s=container_key_missing\n", error_prefix);
    return 3;
  }
  if (strcmp(m->container, "ape-v1") != 0) {
    fprintf(stderr, "%s=bad_container value=%s\n", error_prefix, m->container);
    return 3;
  }
  if (!manifest_find_size(data, n, "nano.slice.x86_64.offset", &m->x86_off) ||
      !manifest_find_size(data, n, "nano.slice.x86_64.size", &m->x86_size) ||
      !manifest_find_size(data, n, "nano.slice.aarch64.offset", &m->arm_off) ||
      !manifest_find_size(data, n, "nano.slice.aarch64.size", &m->arm_size)) {
    fprintf(stderr, "%s=slice_key_missing\n", error_prefix);
    return 4;
  }
  m->has_x86_hash = manifest_find_hash(data, n, "nano.slice.x86_64.hash", &m->x86_hash);
  m->has_arm_hash = manifest_find_hash(data, n, "nano.slice.aarch64.hash", &m->arm_hash);
  return 0;
}

static int validate_ape_slice_bounds(const unsigned char *data, size_t n,
                                       const NanoApeManifest *m, size_t rel_off,
                                       size_t slice_size, const char *arch,
                                       const char *error_prefix) {
  size_t abs_off = m->payload_start + rel_off;
  if (rel_off > n - m->payload_start || slice_size > n - abs_off) {
    fprintf(stderr, "%s=bad_offset arch=%s off=%zu size=%zu payload=%zu file=%zu\n",
            error_prefix, arch, rel_off, slice_size, m->payload_start, n);
    return 4;
  }
  if (!is_elf(data + abs_off, slice_size)) {
    fprintf(stderr, "%s=bad_slice_elf arch=%s\n", error_prefix, arch);
    return 4;
  }
  return 0;
}

static int validate_ape_manifest_hashes(const unsigned char *data, size_t n,
                                        const NanoApeManifest *m,
                                        const char *error_prefix) {
  if (m->has_x86_hash) {
    uint64_t actual = fnv1a64(data + m->payload_start + m->x86_off, m->x86_size);
    if (actual != m->x86_hash) {
      fprintf(stderr, "%s=bad_hash arch=x86_64 expected=%016llx actual=%016llx\n",
              error_prefix, (unsigned long long)m->x86_hash, (unsigned long long)actual);
      return 5;
    }
  }
  if (m->has_arm_hash) {
    uint64_t actual = fnv1a64(data + m->payload_start + m->arm_off, m->arm_size);
    if (actual != m->arm_hash) {
      fprintf(stderr, "%s=bad_hash arch=aarch64 expected=%016llx actual=%016llx\n",
              error_prefix, (unsigned long long)m->arm_hash, (unsigned long long)actual);
      return 5;
    }
  }
  return 0;
}

static int validate_ape_manifest(const unsigned char *data, size_t n, NanoApeManifest *m,
                                 const char *error_prefix) {
  int rc = parse_ape_manifest(data, n, m, error_prefix);
  if (rc != 0) return rc;
  rc = validate_ape_slice_bounds(data, n, m, m->x86_off, m->x86_size, "x86_64", error_prefix);
  if (rc != 0) return rc;
  rc = validate_ape_slice_bounds(data, n, m, m->arm_off, m->arm_size, "aarch64", error_prefix);
  if (rc != 0) return rc;
  return validate_ape_manifest_hashes(data, n, m, error_prefix);
}

#if !defined(_WIN32)
static int host_machine_is_x86_64(void) {
  struct utsname ut;
  if (uname(&ut) != 0) return 0;
  return strcmp(ut.machine, "x86_64") == 0 || strcmp(ut.machine, "amd64") == 0;
}

static int ape_slice_for_arch(const NanoApeManifest *m, const char *force_arch,
                              size_t *rel_off, size_t *slice_size, const char **arch_name) {
  if (force_arch && force_arch[0]) {
    if (strcmp(force_arch, "x86_64") == 0) {
      *rel_off = m->x86_off;
      *slice_size = m->x86_size;
      *arch_name = "x86_64";
      return 0;
    }
    if (strcmp(force_arch, "aarch64") == 0) {
      *rel_off = m->arm_off;
      *slice_size = m->arm_size;
      *arch_name = "aarch64";
      return 0;
    }
    fprintf(stderr, "run-ape=bad_arch value=%s\n", force_arch);
    return 127;
  }
  struct utsname ut;
  if (uname(&ut) != 0) return 126;
  if (strcmp(ut.machine, "x86_64") == 0 || strcmp(ut.machine, "amd64") == 0) {
    *rel_off = m->x86_off;
    *slice_size = m->x86_size;
    *arch_name = "x86_64";
    return 0;
  }
  if (strcmp(ut.machine, "aarch64") == 0 || strcmp(ut.machine, "arm64") == 0) {
    *rel_off = m->arm_off;
    *slice_size = m->arm_size;
    *arch_name = "aarch64";
    return 0;
  }
  fprintf(stderr, "run-ape=unsupported_arch machine=%s\n", ut.machine);
  return 126;
}

static const char *find_qemu_aarch64(void) {
  static const char *candidates[] = {
    "/usr/bin/qemu-aarch64-static",
    "/usr/bin/qemu-aarch64",
    NULL,
  };
  for (size_t i = 0; candidates[i]; ++i) {
    if (access(candidates[i], X_OK) == 0) return candidates[i];
  }
  return NULL;
}

static int extract_and_run_ape_slice(const unsigned char *data, size_t n,
                                       const NanoApeManifest *m, size_t rel_off,
                                       size_t slice_size, const char *arch_name) {
  size_t abs_off = m->payload_start + rel_off;
  char tmpl[] = "/tmp/nano-ape-XXXXXX";
  int fd = mkstemp(tmpl);
  if (fd < 0) {
    fprintf(stderr, "run-ape=mkstemp_fail arch=%s\n", arch_name);
    return 3;
  }
  ssize_t wrote = write(fd, data + abs_off, slice_size);
  close(fd);
  if ((size_t)wrote != slice_size) {
    remove(tmpl);
    fprintf(stderr, "run-ape=write_fail arch=%s\n", arch_name);
    return 3;
  }
  if (!make_executable(tmpl)) {
    remove(tmpl);
    fprintf(stderr, "run-ape=chmod_fail arch=%s\n", arch_name);
    return 3;
  }
  pid_t pid = fork();
  if (pid < 0) {
    remove(tmpl);
    fprintf(stderr, "run-ape=fork_fail arch=%s\n", arch_name);
    return 3;
  }
  if (pid == 0) {
    if (strcmp(arch_name, "aarch64") == 0 && host_machine_is_x86_64()) {
      const char *qemu = find_qemu_aarch64();
      if (!qemu) {
        fprintf(stderr, "run-ape=qemu_missing arch=aarch64\n");
        _exit(126);
      }
      char *const argv[] = {(char *)qemu, tmpl, NULL};
      execv(qemu, argv);
      _exit(127);
    }
    char *const argv[] = {tmpl, NULL};
    execv(tmpl, argv);
    _exit(127);
  }
  int status = 0;
  if (waitpid(pid, &status, 0) < 0) {
    remove(tmpl);
    fprintf(stderr, "run-ape=wait_fail arch=%s\n", arch_name);
    return 3;
  }
  remove(tmpl);
  if (WIFEXITED(status)) return WEXITSTATUS(status);
  if (WIFSIGNALED(status)) return 128 + WTERMSIG(status);
  return 3;
}
#endif

static int cmd_run_ape(const char *container_path, const char *force_arch) {
  size_t n = 0;
  unsigned char *data = read_file(container_path, &n);
  NanoApeManifest m = {0};
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  size_t payload_start = 0;
  if (!find_payload_start(data, n, NANO_APE_PAYLOAD_MARKER, &payload_start)) {
    fprintf(stderr, "run-ape=payload_marker_missing\n");
    free(data);
    return 2;
  }
  int rc;
  if (nano_ape_v2_magic_at(data, n, payload_start)) {
    NanoApeV2Image img = {0};
    rc = validate_nano_ape_v2(data, n, payload_start, &img, is_elf, fnv1a64, "run-ape");
    if (rc != 0) {
      free(data);
      return rc;
    }
#if defined(_WIN32)
    fprintf(stderr, "run-ape=unsupported_platform\n");
    free(data);
    return 2;
#else
    const NanoApeV2SliceRow *row = NULL;
    const char *arch_name = NULL;
    rc = nano_ape_v2_slice_for_arch(&img, force_arch, &row, &arch_name);
    if (rc != 0) {
      free(data);
      return rc;
    }
    size_t payload_base = payload_start + img.header_bytes;
    size_t abs_off = payload_base + (size_t)row->offset;
    NanoApeManifest fake = {.payload_start = 0};
    printf("run-ape.path=%s\n", container_path);
    printf("run-ape.container=ape-v2\n");
    printf("run-ape.arch=%s\n", arch_name);
    printf("run-ape.offset=%llu\n", (unsigned long long)row->offset);
    printf("run-ape.size=%llu\n", (unsigned long long)row->size);
    if (force_arch && force_arch[0]) printf("run-ape.force_arch=%s\n", force_arch);
    rc = extract_and_run_ape_slice(data, n, &fake, abs_off, (size_t)row->size, arch_name);
    printf("run-ape.exit=%d\n", rc);
    free(data);
    return rc;
#endif
  }
  rc = validate_ape_manifest(data, n, &m, "run-ape");
  if (rc != 0) {
    free(data);
    return rc;
  }
#if defined(_WIN32)
  (void)m;
  (void)force_arch;
  fprintf(stderr, "run-ape=unsupported_platform\n");
  free(data);
  return 2;
#else
  size_t rel_off = 0;
  size_t slice_size = 0;
  const char *arch_name = NULL;
  rc = ape_slice_for_arch(&m, force_arch, &rel_off, &slice_size, &arch_name);
  if (rc != 0) {
    free(data);
    return rc;
  }
  printf("run-ape.path=%s\n", container_path);
  printf("run-ape.arch=%s\n", arch_name);
  printf("run-ape.offset=%zu\n", rel_off);
  printf("run-ape.size=%zu\n", slice_size);
  if (force_arch && force_arch[0]) printf("run-ape.force_arch=%s\n", force_arch);
  rc = extract_and_run_ape_slice(data, n, &m, rel_off, slice_size, arch_name);
  printf("run-ape.exit=%d\n", rc);
  free(data);
  return rc;
#endif
}

static int run_ape_expect_exit(const char *path, const char *expected_s, const char *force_arch) {
  size_t expected = 0;
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "run-ape-expect-exit=bad_expected\n");
    return 1;
  }
  int actual = cmd_run_ape(path, force_arch);
  printf("run-ape-expect-exit.path=%s\n", path);
  printf("run-ape-expect-exit.expected=%zu\n", expected);
  printf("run-ape-expect-exit.actual=%d\n", actual);
  if (actual == (int)expected) {
    printf("run-ape-expect-exit.ok=1\n");
    return 0;
  }
  fprintf(stderr, "run-ape-expect-exit=mismatch expected=%zu actual=%d\n", expected, actual);
  return 5;
}
static int cmd_inspect_ape(const char *container_path) {
  size_t n = 0;
  unsigned char *data = read_file(container_path, &n);
  NanoApeManifest m = {0};
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  size_t payload_start = 0;
  if (!find_payload_start(data, n, NANO_APE_PAYLOAD_MARKER, &payload_start)) {
    fprintf(stderr, "inspect-ape=payload_marker_missing\n");
    free(data);
    return 2;
  }
  int rc;
  if (nano_ape_v2_magic_at(data, n, payload_start)) {
    NanoApeV2Image img = {0};
    rc = validate_nano_ape_v2(data, n, payload_start, &img, is_elf, fnv1a64, "inspect-ape");
    if (rc == 0) {
      printf("inspect-ape.path=%s\n", container_path);
      printf("inspect-ape.container=ape-v2\n");
      printf("inspect-ape.header_bytes=%u\n", (unsigned)img.header_bytes);
      printf("inspect-ape.slice_count=%u\n", (unsigned)img.slice_count);
      for (uint16_t i = 0; i < img.slice_count; ++i) {
        const NanoApeV2SliceRow *r = &img.slices[i];
        printf("inspect-ape.slice.%u.arch_id=%u\n", (unsigned)i, r->arch_id);
        printf("inspect-ape.slice.%u.os_id=%u\n", (unsigned)i, r->os_id);
        printf("inspect-ape.slice.%u.offset=%llu\n", (unsigned)i, (unsigned long long)r->offset);
        printf("inspect-ape.slice.%u.size=%llu\n", (unsigned)i, (unsigned long long)r->size);
        printf("inspect-ape.slice.%u.hash=%016llx\n", (unsigned)i, (unsigned long long)r->hash);
      }
      printf("inspect-ape.ok=1\n");
    }
    free(data);
    return rc;
  }
  rc = validate_ape_manifest(data, n, &m, "inspect-ape");
  free(data);
  if (rc == 0) {
    printf("inspect-ape.path=%s\n", container_path);
    printf("inspect-ape.container=%s\n", m.container);
    printf("inspect-ape.ok=1\n");
  }
  return rc;
}
static int cmd_pack_ape(const char *out_path, const char *x86_path, const char *arm_path) {
  size_t x86_n = 0;
  size_t arm_n = 0;
  unsigned char *x86 = read_file(x86_path, &x86_n);
  unsigned char *arm = read_file(arm_path, &arm_n);
  if (!x86 || !arm || !is_elf(x86, x86_n) || !is_elf(arm, arm_n)) {
    fprintf(stderr, "pack-ape=input_not_elf\n");
    free(x86);
    free(arm);
    return 1;
  }

  uint64_t x86_hash = fnv1a64(x86, x86_n);
  uint64_t arm_hash = fnv1a64(arm, arm_n);
  uint16_t v2_slice_count = 2;
  size_t v2_hdr_bytes = nano_ape_v2_header_bytes(v2_slice_count);
  size_t arm_payload_off = v2_hdr_bytes + x86_n;

  const char *stub_fmt =
      "#!/bin/sh\n"
      "set -eu\n"
      "# nano.loader=run-ape-cli\n"
      "if [ -n \"${NANO_JIT:-}\" ] && [ -x \"${NANO_JIT}\" ]; then\n"
      "  exec \"${NANO_JIT}\" run-ape \"$0\" \"$@\"\n"
      "fi\n"
      "if command -v nano-lisp-jit >/dev/null 2>&1; then\n"
      "  exec nano-lisp-jit run-ape \"$0\" \"$@\"\n"
      "fi\n"
      "arch=\"$(uname -m)\"\n"
      "case \"$arch\" in\n"
      "  x86_64|amd64) off=%zu; size=%zu; suffix=x86_64 ;;\n"
      "  aarch64|arm64) off=%zu; size=%zu; suffix=aarch64 ;;\n"
      "  *) echo \"nano pack-ape: unsupported arch $arch\" >&2; exit 126 ;;\n"
      "esac\n"
      "# nano.manifest.begin\n"
      "# nano.container=ape-v1\n"
      "# nano.slice.x86_64.offset=%zu\n"
      "# nano.slice.x86_64.size=%zu\n"
      "# nano.slice.x86_64.hash=%016llx\n"
      "# nano.slice.aarch64.offset=%zu\n"
      "# nano.slice.aarch64.size=%zu\n"
      "# nano.slice.aarch64.hash=%016llx\n"
      "# nano.manifest.end\n"
      "payload_line=$(awk '/^__NANO_APE_PAYLOAD_BELOW__$/ { print NR + 1; exit }' \"$0\")\n"
      "if [ -z \"${payload_line:-}\" ]; then echo \"nano pack-ape: payload marker missing\" >&2; exit 126; fi\n"
      "tmp=\"${TMPDIR:-/tmp}/nano-ape-$$-$suffix\"\n"
      "trap 'rm -f \"$tmp\"' EXIT HUP INT TERM\n"
      "tail -n +\"$payload_line\" \"$0\" | dd bs=1 skip=\"$off\" count=\"$size\" of=\"$tmp\" 2>/dev/null\n"
      "chmod +x \"$tmp\"\n"
      "exec \"$tmp\" \"$@\"\n"
      "exit 127\n"
      "__NANO_APE_PAYLOAD_BELOW__\n";

  int stub_n = snprintf(NULL, 0, stub_fmt, v2_hdr_bytes, x86_n, arm_payload_off, arm_n,
                        v2_hdr_bytes, x86_n, (unsigned long long)x86_hash, arm_payload_off, arm_n,
                        (unsigned long long)arm_hash);
  if (stub_n < 0) {
    free(x86);
    free(arm);
    return 2;
  }
  char *stub = (char *)malloc((size_t)stub_n + 1);
  if (!stub) {
    free(x86);
    free(arm);
    return 2;
  }
  snprintf(stub, (size_t)stub_n + 1, stub_fmt, v2_hdr_bytes, x86_n, arm_payload_off, arm_n,
           v2_hdr_bytes, x86_n, (unsigned long long)x86_hash, arm_payload_off, arm_n,
           (unsigned long long)arm_hash);

  NanoApeV2SliceRow v2_rows[2] = {
      {NANO_APE_V2_ARCH_X86_64, NANO_APE_V2_OS_LINUX, 0, 0, x86_n, x86_hash},
      {NANO_APE_V2_ARCH_AARCH64, NANO_APE_V2_OS_LINUX, 0, x86_n, arm_n, arm_hash},
  };
  unsigned char v2_hdr[128];
  ssize_t v2_hdr_n = emit_nano_ape_v2_header(v2_hdr, sizeof(v2_hdr), v2_slice_count, v2_rows);
  if (v2_hdr_n < 0 || (size_t)v2_hdr_n != v2_hdr_bytes) {
    free(stub);
    free(x86);
    free(arm);
    return 2;
  }

  Buf out = {0};
  buf_put(&out, stub, (size_t)stub_n);
  buf_put(&out, v2_hdr, (size_t)v2_hdr_n);
  buf_put(&out, x86, x86_n);
  buf_put(&out, arm, arm_n);
  int ok = write_file(out_path, out.data, out.len) && make_executable(out_path);
  if (ok) {
    printf("pack-ape.output=%s\n", out_path);
    printf("pack-ape.container=ape-v2\n");
    printf("pack-ape.header_bytes=%zu\n", v2_hdr_bytes);
    printf("pack-ape.bytes=%zu\n", out.len);
    printf("pack-ape.x86_64.bytes=%zu\n", x86_n);
    printf("pack-ape.aarch64.bytes=%zu\n", arm_n);
  } else {
    fprintf(stderr, "pack-ape=write_fail path=%s\n", out_path);
  }

  free(stub);
  free(out.data);
  free(x86);
  free(arm);
  return ok ? 0 : 3;
}
