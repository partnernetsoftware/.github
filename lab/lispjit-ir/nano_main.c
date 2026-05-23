static void usage(const char *argv0) {
  fprintf(stderr, "usage:\n");
  fprintf(stderr, "  %s compile input.%s output.%s\n", argv0, SOURCE_EXT, BLOB_EXT);
  fprintf(stderr, "  %s run program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s run-embedded container.com blob_offset blob_size\n", argv0);
  fprintf(stderr, "  %s inspect-ape container.com\n", argv0);
  fprintf(stderr, "  %s inspect-expect-exit expected inspect-ape|inspect-app container.com\n", argv0);
  fprintf(stderr, "  %s inspect-app container.com\n", argv0);
  fprintf(stderr, "  %s run-ape container.com [x86_64|aarch64]\n", argv0);
  fprintf(stderr, "  %s run-ape-expect-exit container.com expected_exit [arch]\n", argv0);
  fprintf(stderr, "  %s run-app container.com\n", argv0);
  fprintf(stderr, "  %s emit-elf64-exit output.elf exit_code\n", argv0);
  fprintf(stderr, "  %s emit-elf64-obj-ret output.o symbol value\n", argv0);
  fprintf(stderr, "  %s emit-elf64-obj-call output.o local_symbol external_symbol\n", argv0);
  fprintf(stderr, "  %s aot-elf64-exit input.%s output.elf\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-obj-ret input.%s output.o symbol\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-code input.%s output.elf\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s aot-elf64-obj-code input.%s output.o symbol\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s compile-elf64-code input.%s output.elf\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compile-elf64-obj-code input.%s output.o symbol\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compile-elf64-exe input.%s output.elf entry_symbol\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compile-expect-exit expected mode input output [symbol]\n", argv0);
  fprintf(stderr, "  %s link-elf64-exe output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s link-expect-exit expected output.elf entry_symbol input.o...\n", argv0);
  fprintf(stderr, "  %s run-expect-exit executable expected_exit\n", argv0);
  fprintf(stderr, "  %s dump program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s hash program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s file-size path\n", argv0);
  fprintf(stderr, "  %s file-hash path\n", argv0);
  fprintf(stderr, "  %s gen-libc-resolve [libc.so] output.%s\n", argv0, SOURCE_EXT);
  fprintf(stderr, "  %s compare left.%s right.%s\n", argv0, BLOB_EXT, BLOB_EXT);
  fprintf(stderr, "  %s resolve [--quiet] program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s resolve-quiet program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s run-bootstrap-plan plan.lisp\n", argv0);
  fprintf(stderr, "  %s pack-ape output.com x86_64.elf aarch64.elf\n", argv0);
  fprintf(stderr, "  %s pack-ape-bare output.ape x86_64.elf aarch64.elf\n", argv0);
  fprintf(stderr, "  %s pack-app output.com x86_64.elf aarch64.elf program.%s\n", argv0, BLOB_EXT);
  fprintf(stderr, "  %s nano-cc compile input.c -o output.elf\n", argv0);
  fprintf(stderr, "  %s nano-cc compile-obj input.c -o output.o\n", argv0);
  fprintf(stderr, "  %s nano-cc parse input.c\n", argv0);
  fprintf(stderr, "  %s nano-cc-compile-expect-exit expected input.c output.elf\n", argv0);
  fprintf(stderr, "  %s nano-cc-parse-expect-exit expected input.c\n", argv0);
}

int main(int argc, char **argv) {
  if (argc >= 2 && strcmp(argv[1], "compile") == 0 && argc == 4) {
    return cmd_compile(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "run") == 0 && argc == 3) {
    return cmd_run(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-embedded") == 0 && argc == 5) {
    return cmd_run_embedded(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "inspect-ape") == 0 && argc == 3) {
    return cmd_inspect_ape(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "inspect-app") == 0 && argc == 3) {
    return cmd_inspect_app(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-app") == 0 && argc == 3) {
    return cmd_run_app(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape") == 0 && argc == 3) {
    return cmd_run_ape(argv[2], NULL);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape") == 0 && argc == 4) {
    return cmd_run_ape(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape-expect-exit") == 0 && argc == 4) {
    return run_ape_expect_exit(argv[2], argv[3], NULL);
  }
  if (argc >= 2 && strcmp(argv[1], "run-ape-expect-exit") == 0 && argc == 5) {
    return run_ape_expect_exit(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "inspect-expect-exit") == 0 && argc == 5) {
    return cmd_inspect_expect_exit(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "emit-elf64-exit") == 0 && argc == 4) {
    return cmd_emit_elf64_exit(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "emit-elf64-obj-ret") == 0 && argc == 5) {
    return cmd_emit_elf64_obj_ret(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "emit-elf64-obj-call") == 0 && argc == 5) {
    return cmd_emit_elf64_obj_call(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-exit") == 0 && argc == 4) {
    return cmd_aot_elf64_exit(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-obj-ret") == 0 && argc == 5) {
    return cmd_aot_elf64_obj_ret(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-code") == 0 && argc == 4) {
    return cmd_aot_elf64_code(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "aot-elf64-obj-code") == 0 && argc == 5) {
    return cmd_aot_elf64_obj_code(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-elf64-code") == 0 && argc == 4) {
    return cmd_compile_elf64_code(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-elf64-obj-code") == 0 && argc == 5) {
    return cmd_compile_elf64_obj_code(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-elf64-exe") == 0 && argc == 5) {
    return cmd_compile_elf64_exe(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "compile-expect-exit") == 0) {
    return cmd_compile_expect_exit(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "link-elf64-exe") == 0) {
    return cmd_link_elf64_exe(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "link-expect-exit") == 0) {
    return cmd_link_expect_exit(argc, argv);
  }
  if (argc >= 2 && strcmp(argv[1], "run-expect-exit") == 0 && argc == 4) {
    return run_executable_expect_exit(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "dump") == 0 && argc == 3) {
    return cmd_dump(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "hash") == 0 && argc == 3) {
    return cmd_hash(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "file-size") == 0 && argc == 3) {
    return cmd_file_size(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "file-hash") == 0 && argc == 3) {
    return cmd_file_hash(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "gen-libc-resolve") == 0) {
    if (argc == 3) return cmd_gen_libc_resolve(NULL, argv[2]);
    if (argc == 4) return cmd_gen_libc_resolve(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "compare") == 0 && argc == 4) {
    return cmd_compare(argv[2], argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "resolve") == 0) {
    if (argc == 3) return cmd_resolve(argv[2], 0);
    if (argc == 4 && strcmp(argv[2], "--quiet") == 0) return cmd_resolve(argv[3], 1);
  }
  if (argc >= 2 && strcmp(argv[1], "resolve-quiet") == 0 && argc == 3) {
    return cmd_resolve(argv[2], 1);
  }
  if (argc >= 2 && strcmp(argv[1], "run-bootstrap-plan") == 0 && argc == 3) {
    return cmd_run_bootstrap_plan(argv[2]);
  }
  if (argc >= 2 && strcmp(argv[1], "pack-ape") == 0 && argc == 5) {
    return cmd_pack_ape(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "pack-ape-bare") == 0 && argc == 5) {
    return cmd_pack_ape_bare(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "pack-app") == 0 && argc == 6) {
    return cmd_pack_app(argv[2], argv[3], argv[4], argv[5]);
  }
  if (argc >= 2 && strcmp(argv[1], "nano-cc") == 0 && argc == 6 && strcmp(argv[2], "compile") == 0 &&
      strcmp(argv[4], "-o") == 0) {
    return cmd_nano_cc_compile(argv[3], argv[5]);
  }
  if (argc >= 2 && strcmp(argv[1], "nano-cc") == 0 && argc == 6 &&
      strcmp(argv[2], "compile-obj") == 0 && strcmp(argv[4], "-o") == 0) {
    return cmd_nano_cc_compile_obj(argv[3], argv[5]);
  }
  if (argc >= 2 && strcmp(argv[1], "nano-cc") == 0 && argc == 4 && strcmp(argv[2], "parse") == 0) {
    return cmd_nano_cc_parse(argv[3]);
  }
  if (argc >= 2 && strcmp(argv[1], "nano-cc-compile-expect-exit") == 0 && argc == 5) {
    return cmd_nano_cc_compile_expect_exit(argv[2], argv[3], argv[4]);
  }
  if (argc >= 2 && strcmp(argv[1], "nano-cc-parse-expect-exit") == 0 && argc == 4) {
    size_t expected = 0;
    int actual;
    if (!parse_size_arg(argv[2], &expected) || expected > 255) {
      fprintf(stderr, "nano-cc-parse-expect-exit=bad_expected\n");
      return 1;
    }
    actual = cmd_nano_cc_parse(argv[3]);
    printf("nano-cc-parse-expect-exit.expected=%zu\n", expected);
    printf("nano-cc-parse-expect-exit.actual=%d\n", actual);
    if ((size_t)actual == expected) {
      printf("nano-cc-parse-expect-exit.ok=1\n");
      return 0;
    }
    fprintf(stderr, "nano-cc-parse-expect-exit=mismatch expected=%zu actual=%d\n", expected, actual);
    return 1;
  }
  usage(argv[0]);
  return 2;
}
