#include <stdint.h>
#include <stdio.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <dlfcn.h>
#include <sys/mman.h>
#include <unistd.h>
#endif

typedef unsigned long (*strlen_fn)(const char *);
typedef unsigned long (*jit_fn)(void);

static void *open_libc(void) {
#if defined(_WIN32)
  void *h = LoadLibraryA("ucrtbase.dll");
  return h ? h : LoadLibraryA("msvcrt.dll");
#elif defined(__APPLE__)
  return dlopen("libSystem.B.dylib", RTLD_LAZY);
#else
  void *h = dlopen("libc.so.6", RTLD_LAZY);
  return h ? h : dlopen("libc.so", RTLD_LAZY);
#endif
}

static void *sym(void *handle, const char *name) {
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
  return mmap(NULL, n, PROT_READ | PROT_WRITE | PROT_EXEC,
              MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
#endif
}

static void patch64(unsigned char *p, uint64_t v) {
  for (int i = 0; i < 8; ++i) {
    p[i] = (unsigned char)((v >> (i * 8)) & 0xff);
  }
}

int main(void) {
  void *libc = open_libc();
  if (!libc) {
    puts("ffi=fail");
    return 1;
  }

  strlen_fn host_strlen = (strlen_fn)sym(libc, "strlen");
  if (!host_strlen) {
    puts("ffi.symbol=fail");
    return 2;
  }

  const char *arg = "ffi";

#if defined(__x86_64__) || defined(_M_X64)
  unsigned char code[] = {
#if defined(_WIN32)
    0x48, 0xb9, 0, 0, 0, 0, 0, 0, 0, 0, /* mov rcx, arg */
#else
    0x48, 0xbf, 0, 0, 0, 0, 0, 0, 0, 0, /* mov rdi, arg */
#endif
    0x48, 0xb8, 0, 0, 0, 0, 0, 0, 0, 0, /* mov rax, strlen */
    0xff, 0xd0,                               /* call rax */
    0xc3                                      /* ret */
  };
  patch64(code + 2, (uint64_t)(uintptr_t)arg);
  patch64(code + 12, (uint64_t)(uintptr_t)host_strlen);
#elif defined(__aarch64__) || defined(_M_ARM64)
  unsigned char code[] = {
    0x80, 0x00, 0x00, 0x58, /* ldr x0, arg_literal */
    0xb0, 0x00, 0x00, 0x58, /* ldr x16, fn_literal */
    0x00, 0x02, 0x3f, 0xd6, /* blr x16 */
    0xc0, 0x03, 0x5f, 0xd6, /* ret */
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
  };
  patch64(code + 16, (uint64_t)(uintptr_t)arg);
  patch64(code + 24, (uint64_t)(uintptr_t)host_strlen);
#else
  puts("jit.arch=unsupported");
  return 3;
#endif

  void *mem = alloc_exec(sizeof(code));
  if (!mem) {
    puts("jit.alloc=fail");
    return 4;
  }

  memcpy(mem, code, sizeof(code));
#if defined(__GNUC__) || defined(__clang__)
  __builtin___clear_cache((char *)mem, (char *)mem + sizeof(code));
#endif

  printf("ffi.symbol=strlen\n");
  printf("jit.code.bytes=%zu\n", sizeof(code));
  printf("jit.calls.ffi.result=%lu\n", ((jit_fn)mem)());
  return 0;
}
