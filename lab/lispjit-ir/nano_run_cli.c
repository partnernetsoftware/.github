/* Included from lispjit.c — run-embedded, run-app, run-expect-exit, file-size/hash. */
static int cmd_run_embedded(const char *container_path, const char *off_s, const char *size_s) {
  size_t rel_off = 0;
  size_t blob_n = 0;
  size_t container_n = 0;
  size_t payload_start = 0;
  if (!parse_size_arg(off_s, &rel_off) || !parse_size_arg(size_s, &blob_n)) {
    fprintf(stderr, "run-embedded=bad_offset_or_size\n");
    return 1;
  }
  unsigned char *container = read_file(container_path, &container_n);
  if (!container) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  if (!find_payload_start(container, container_n, NANO_APP_PAYLOAD_MARKER, &payload_start) ||
      rel_off > container_n - payload_start ||
      blob_n > container_n - payload_start - rel_off) {
    fprintf(stderr, "run-embedded=payload_bounds\n");
    free(container);
    return 2;
  }
  Blob b;
  if (!blob_init(&b, container + payload_start + rel_off, blob_n)) {
    fprintf(stderr, "run-embedded=blob_parse_fail\n");
    free(container);
    return 3;
  }
  int rc = execute_blob(&b);
  free(container);
  return rc;
}

static int cmd_run_app(const char *container_path) {
  size_t n = 0;
  size_t blob_off = 0;
  size_t blob_size = 0;
  char off_buf[32];
  char size_buf[32];
  unsigned char *data = read_file(container_path, &n);
  if (!data) {
    fprintf(stderr, "read=fail path=%s\n", container_path);
    return 1;
  }
  if (!manifest_find_size(data, n, "nano.blob.offset", &blob_off) ||
      !manifest_find_size(data, n, "nano.blob.size", &blob_size)) {
    fprintf(stderr, "run-app=manifest_key_missing path=%s\n", container_path);
    free(data);
    return 2;
  }
  free(data);
  snprintf(off_buf, sizeof(off_buf), "%zu", blob_off);
  snprintf(size_buf, sizeof(size_buf), "%zu", blob_size);
  printf("run-app.path=%s\n", container_path);
  printf("run-app.blob.offset=%zu\n", blob_off);
  printf("run-app.blob.size=%zu\n", blob_size);
  return cmd_run_embedded(container_path, off_buf, size_buf);
}

static int run_executable_expect_exit(const char *path, const char *expected_s) {
  size_t expected = 0;
  if (!parse_size_arg(expected_s, &expected) || expected > 255) {
    fprintf(stderr, "run-expect-exit=bad_expected\n");
    return 1;
  }
#if defined(_WIN32)
  (void)path;
  fprintf(stderr, "run-expect-exit=unsupported_platform\n");
  return 2;
#else
  pid_t pid = fork();
  if (pid < 0) {
    fprintf(stderr, "run-expect-exit=fork_fail path=%s\n", path);
    return 2;
  }
  if (pid == 0) {
    char *const argv[] = {(char *)path, NULL};
    execv(path, argv);
    _exit(127);
  }
  int status = 0;
  if (waitpid(pid, &status, 0) < 0) {
    fprintf(stderr, "run-expect-exit=wait_fail path=%s\n", path);
    return 3;
  }
  printf("run-expect-exit.path=%s\n", path);
  printf("run-expect-exit.expected=%zu\n", expected);
  if (WIFEXITED(status)) {
    int actual = WEXITSTATUS(status);
    printf("run-expect-exit.actual=%d\n", actual);
    if (actual == (int)expected) {
      printf("run-expect-exit.ok=1\n");
      return 0;
    }
    fprintf(stderr, "run-expect-exit=mismatch expected=%zu actual=%d\n", expected, actual);
    return 5;
  }
  if (WIFSIGNALED(status)) {
    fprintf(stderr, "run-expect-exit=signaled signal=%d\n", WTERMSIG(status));
    return 4;
  }
  fprintf(stderr, "run-expect-exit=unknown_status\n");
  return 4;
#endif
}

static int cmd_file_size(const char *path) {
  FILE *f = fopen(path, "rb");
  if (!f) {
    fprintf(stderr, "file-size=read_fail path=%s\n", path);
    return 1;
  }
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    fprintf(stderr, "file-size=seek_fail path=%s\n", path);
    return 1;
  }
  long n = ftell(f);
  fclose(f);
  if (n < 0) {
    fprintf(stderr, "file-size=tell_fail path=%s\n", path);
    return 1;
  }
  printf("%ld\n", n);
  return 0;
}

static int cmd_file_hash(const char *path) {
  size_t n = 0;
  unsigned char *data = read_file(path, &n);
  if (!data) {
    fprintf(stderr, "file-hash=read_fail path=%s\n", path);
    return 1;
  }
  printf("%016llx\n", (unsigned long long)fnv1a64(data, n));
  free(data);
  return 0;
}
