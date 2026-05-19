#if defined(__COSMORUN__)
#ifndef RTLD_LAZY
#define RTLD_LAZY 1
#endif
extern int printf(const char *format, ...);
extern void *__dlopen(const char *name, int flags);
extern void *__dlsym(void *handle, const char *symbol);
extern int __dlclose(void *handle);
#define open_library __dlopen
#define load_symbol __dlsym
#define close_library __dlclose
#else
#include <stdio.h>
#include <dlfcn.h>
#define open_library dlopen
#define load_symbol dlsym
#define close_library dlclose
#endif

static const char *arch_name(void) {
#if defined(__x86_64__) || defined(_M_X64)
  return "x86_64";
#elif defined(__aarch64__) || defined(_M_ARM64)
  return "aarch64";
#elif defined(__arm__) || defined(_M_ARM)
  return "arm";
#elif defined(__i386__) || defined(_M_IX86)
  return "x86";
#elif defined(__riscv)
  return "riscv";
#else
  return "unknown";
#endif
}

static const char *os_name(void) {
#if defined(_WIN32)
  return "windows";
#elif defined(__APPLE__)
  return "macos";
#elif defined(__linux__)
  return "linux";
#else
  return "unknown";
#endif
}

static void *open_first(const char *const *names, const char **opened_name) {
  for (int i = 0; names[i]; ++i) {
    void *handle = open_library(names[i], RTLD_LAZY);
    if (handle) {
      if (opened_name) {
        *opened_name = names[i];
      }
      return handle;
    }
  }
  return NULL;
}

int main(void) {
#if defined(_WIN32)
  static const char *const libc_names[] = {"ucrtbase.dll", "msvcrt.dll", NULL};
  static const char *const math_names[] = {"ucrtbase.dll", "msvcrt.dll", NULL};
#elif defined(__APPLE__)
  static const char *const libc_names[] = {"libSystem.B.dylib", NULL};
  static const char *const math_names[] = {"libSystem.B.dylib", NULL};
#else
  static const char *const libc_names[] = {"libc.so.6", "libc.so", NULL};
  static const char *const math_names[] = {"libm.so.6", "libm.so", NULL};
#endif

  typedef int (*puts_fn)(const char *);
  typedef double (*cos_fn)(double);

  const char *libc_name = NULL;
  const char *math_name = NULL;
  void *libc_handle = open_first(libc_names, &libc_name);
  void *math_handle = open_first(math_names, &math_name);

  printf("probe.os=%s\n", os_name());
  printf("probe.arch=%s\n", arch_name());

  if (!libc_handle) {
    printf("ffi.libc=fail\n");
    return 10;
  }
  puts_fn host_puts = (puts_fn)load_symbol(libc_handle, "puts");
  if (!host_puts) {
    printf("ffi.libc.symbol=fail\n");
    return 11;
  }
  printf("ffi.libc=%s\n", libc_name);
  host_puts("ffi.libc.puts=ok");

  if (!math_handle) {
    printf("ffi.libm=fail\n");
    return 20;
  }
  cos_fn host_cos = (cos_fn)load_symbol(math_handle, "cos");
  if (!host_cos) {
    printf("ffi.libm.symbol=fail\n");
    return 21;
  }
  printf("ffi.libm=%s\n", math_name);
  printf("ffi.libm.cos0=%.1f\n", host_cos(0.0));

  close_library(math_handle);
  close_library(libc_handle);
  return 0;
}
