/* Included from lispjit.c — shell no-arg dispatch + dev compile/run (Phase 3 C parity). */

#define SHELL_SCRIPT_LISP "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
#define SHELL_SCRIPT_LBIN_BUILD "lab/nano-lisp-jit/.build/nanolisp-shell-script.lbin"
#define SHELL_EMBED_C "lab/nano-lisp-jit/archive/c/embed/shell-script.lbin"
#define SHELL_EMBED_RS "lab/nano-jit-rs/embed/shell-script.lbin"

static int shell_path_is_file(const char *path) {
  struct stat st;
  return path && stat(path, &st) == 0 && S_ISREG(st.st_mode);
}

static int cmd_shell_run_lbin(const char *lbin_path, const char *mode) {
  size_t n = 0;
  unsigned char *data;
  int rc;
  if (!shell_path_is_file(lbin_path)) {
    fprintf(stderr, "shell=missing_lbin path=%s\n", lbin_path);
    return 1;
  }
  data = read_file(lbin_path, &n);
  if (!data) {
    fprintf(stderr, "shell=read_fail path=%s\n", lbin_path);
    return 1;
  }
  printf("shell.mode=%s\n", mode);
  printf("shell.lbin=%s\n", lbin_path);
  printf("shell.embed.bytes=%zu\n", n);
  free(data);
  rc = cmd_run(lbin_path);
  return rc;
}

static int cmd_shell_try_embedded_files(void) {
  static const char *candidates[] = {SHELL_EMBED_C, SHELL_EMBED_RS, NULL};
  size_t i;
  for (i = 0; candidates[i]; ++i) {
    if (shell_path_is_file(candidates[i])) {
      return cmd_shell_run_lbin(candidates[i], "embedded-lbin");
    }
  }
  return -1;
}

static int cmd_shell_try_run_app_self(const char *argv0) {
  size_t n = 0;
  size_t blob_off = 0;
  size_t blob_size = 0;
  unsigned char *data;
  int rc;
  if (!argv0 || !argv0[0]) return -1;
  data = read_file(argv0, &n);
  if (!data) return -1;
  if (!manifest_find_size(data, n, "nano.blob.offset", &blob_off) ||
      !manifest_find_size(data, n, "nano.blob.size", &blob_size) || blob_size == 0) {
    free(data);
    return -1;
  }
  free(data);
  printf("shell.mode=embedded-lbin\n");
  printf("shell.embed.container=%s\n", argv0);
  printf("shell.embed.bytes=%zu\n", blob_size);
  rc = cmd_run_app(argv0);
  return rc;
}

static int cmd_shell_compile_run(void) {
  const char *lisp = SHELL_SCRIPT_LISP;
  const char *lbin = SHELL_SCRIPT_LBIN_BUILD;
  int rc;
  if (!shell_path_is_file(lisp)) {
    fprintf(stderr, "shell=missing_script path=%s\n", lisp);
    return 1;
  }
  rc = cmd_compile(lisp, lbin);
  if (rc != 0) return rc;
  printf("shell.mode=lbin-script\n");
  printf("shell.lisp=%s\n", lisp);
  printf("shell.lbin=%s\n", lbin);
  return cmd_run(lbin);
}

static int cmd_shell(void) { return cmd_shell_compile_run(); }

static int cmd_shell_noarg(const char *argv0) {
  int rc = cmd_shell_try_run_app_self(argv0);
  if (rc >= 0) return rc;
  rc = cmd_shell_try_embedded_files();
  if (rc >= 0) return rc;
  /* TODO(factory): pack-app embed shell-script.lbin in release COM for true embedded-lbin. */
  fprintf(stderr, "shell.noarg=fallback compile-run\n");
  return cmd_shell_compile_run();
}
