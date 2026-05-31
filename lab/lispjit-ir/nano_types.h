/* Shared IR / VM / AOT / bootstrap core types and opcode constants (v2.5). */

#ifndef NANO_TYPES_H
#define NANO_TYPES_H

#include <stddef.h>
#include <stdint.h>

#define CONST_STRING 1u
#define OP_CALL_IMPORT_CONST 1u
#define OP_RET_LAST 2u
#define OP_CALL_IMPORT_CONST2 3u
#define OP_RESOLVE_IMPORT 4u
#define OP_CALL_IMPORT_VOID 5u
#define OP_EXPECT_U64 6u
#define OP_CONST_U64 7u
#define OP_ADD_U64 8u
#define OP_CALL_IMPORT_IMM 9u
#define OP_CONST_I64 10u
#define OP_CONST_BOOL 11u
#define OP_EXPECT_I64 12u
#define OP_EXPECT_BOOL 13u
#define OP_EXPECT_PTR 14u
#define OP_BRANCH_BOOL 15u
#define OP_ADD_I64 16u
#define OP_SUB_I64 17u
#define OP_MUL_I64 18u
#define OP_EQ_I64 19u
#define OP_LT_I64 20u
#define OP_GT_I64 21u
#define OP_NE_I64 22u
#define OP_LE_I64 23u
#define OP_GE_I64 24u
#define OP_NOT_BOOL 25u
#define OP_AND_BOOL 26u
#define OP_OR_BOOL 27u
#define OP_NULL_PTR 28u
#define OP_IS_NULL_PTR 29u
#define OP_IS_NONNULL_PTR 30u
#define OP_ADD_PTR 31u
#define OP_SUB_PTR 32u
#define OP_PTR_TO_U64 33u
#define OP_U64_TO_PTR 34u
#define OP_CONST_PTR 35u
#define OP_LOAD_U8 36u
#define OP_LOAD_U16 37u
#define OP_LOAD_U32 38u
#define OP_STORE_U8 39u
#define OP_STORE_U16 40u
#define OP_STORE_U32 41u
#define OP_CALL_FUNC 42u
#define OP_LOAD_ARG_I64 43u

#define SRC_FORM_CALL 1u
#define SRC_FORM_RESOLVE 2u
#define SRC_FORM_EXPECT 3u
#define SRC_FORM_CONST_U64 4u
#define SRC_FORM_ADD_U64 5u
#define SRC_FORM_CONST_I64 6u
#define SRC_FORM_CONST_BOOL 7u
#define SRC_FORM_EXPECT_I64 8u
#define SRC_FORM_EXPECT_BOOL 9u
#define SRC_FORM_EXPECT_PTR 10u
#define SRC_FORM_BRANCH 11u
#define SRC_FORM_LABEL 12u
#define SRC_FORM_ADD_I64 13u
#define SRC_FORM_SUB_I64 14u
#define SRC_FORM_MUL_I64 15u
#define SRC_FORM_EQ_I64 16u
#define SRC_FORM_LT_I64 17u
#define SRC_FORM_GT_I64 18u
#define SRC_FORM_NE_I64 19u
#define SRC_FORM_LE_I64 20u
#define SRC_FORM_GE_I64 21u
#define SRC_FORM_NOT_BOOL 22u
#define SRC_FORM_AND_BOOL 23u
#define SRC_FORM_OR_BOOL 24u
#define SRC_FORM_NULL_PTR 25u
#define SRC_FORM_IS_NULL_PTR 26u
#define SRC_FORM_IS_NONNULL_PTR 27u
#define SRC_FORM_ADD_PTR 28u
#define SRC_FORM_SUB_PTR 29u
#define SRC_FORM_PTR_TO_U64 30u
#define SRC_FORM_U64_TO_PTR 31u
#define SRC_FORM_CONST_PTR 32u
#define SRC_FORM_LOAD_U8 33u
#define SRC_FORM_LOAD_U16 34u
#define SRC_FORM_LOAD_U32 35u
#define SRC_FORM_STORE_U8 36u
#define SRC_FORM_STORE_U16 37u
#define SRC_FORM_STORE_U32 38u
#define SRC_FORM_CALL_FUNC 39u
#define SRC_FORM_PARAM_I64 40u
#define SRC_FORM_LOAD_ARG_I64 41u

#define AOT_STMT_CONST_U64 1u
#define AOT_STMT_ADD_U64 2u
#define AOT_STMT_EXPECT_U64 3u
#define AOT_STMT_CALL_FUNC 4u
#define AOT_STMT_CONST_I64 5u
#define AOT_STMT_CONST_BOOL 6u
#define AOT_STMT_EXPECT_I64 7u
#define AOT_STMT_EXPECT_BOOL 8u
#define AOT_STMT_BRANCH_BOOL 9u
#define AOT_STMT_LABEL 10u
#define AOT_STMT_ADD_I64 11u
#define AOT_STMT_SUB_I64 12u
#define AOT_STMT_MUL_I64 13u
#define AOT_STMT_EQ_I64 14u
#define AOT_STMT_LT_I64 15u
#define AOT_STMT_GT_I64 16u
#define AOT_STMT_NE_I64 17u
#define AOT_STMT_LE_I64 18u
#define AOT_STMT_GE_I64 19u
#define AOT_STMT_NOT_BOOL 20u
#define AOT_STMT_AND_BOOL 21u
#define AOT_STMT_OR_BOOL 22u
#define AOT_STMT_NULL_PTR 23u
#define AOT_STMT_IS_NULL_PTR 24u
#define AOT_STMT_IS_NONNULL_PTR 25u
#define AOT_STMT_EXPECT_PTR 26u
#define AOT_STMT_ADD_PTR 27u
#define AOT_STMT_SUB_PTR 28u
#define AOT_STMT_PTR_TO_U64 29u
#define AOT_STMT_U64_TO_PTR 30u
#define AOT_STMT_LOAD_U8 31u
#define AOT_STMT_LOAD_U16 32u
#define AOT_STMT_LOAD_U32 33u
#define AOT_STMT_STORE_U8 34u
#define AOT_STMT_STORE_U16 35u
#define AOT_STMT_STORE_U32 36u
#define AOT_STMT_LOAD_ARG_I64 37u
#define AOT_STMT_SAVE_TOP_I64 38u
#define AOT_STMT_ADD_ARG_I64 39u

#define BOOTSTRAP_STEP_COMPILE 1u
#define BOOTSTRAP_STEP_HASH 2u
#define BOOTSTRAP_STEP_RUN 3u
#define BOOTSTRAP_STEP_COMPARE 4u
#define BOOTSTRAP_STEP_PACK_APP 5u
#define BOOTSTRAP_STEP_INSPECT_APP 6u
#define BOOTSTRAP_STEP_EMIT_ELF64_EXIT 7u
#define BOOTSTRAP_STEP_AOT_ELF64_EXIT 8u
#define BOOTSTRAP_STEP_AOT_ELF64_CODE 9u
#define BOOTSTRAP_STEP_AOT_ELF64_OBJ_CODE 10u
#define BOOTSTRAP_STEP_COMPILE_ELF64_CODE 11u
#define BOOTSTRAP_STEP_COMPILE_ELF64_OBJ_CODE 12u
#define BOOTSTRAP_STEP_LINK_ELF64_EXE 13u
#define BOOTSTRAP_STEP_RUN_EXPECT_EXIT 14u
#define BOOTSTRAP_STEP_AOT_ELF64_OBJ_RET 15u
#define BOOTSTRAP_STEP_EMIT_ELF64_OBJ_RET 16u
#define BOOTSTRAP_STEP_EMIT_ELF64_OBJ_CALL 17u
#define BOOTSTRAP_STEP_LINK_EXPECT_EXIT 18u
#define BOOTSTRAP_STEP_RESOLVE_QUIET 19u
#define BOOTSTRAP_STEP_COMPILE_ELF64_EXE 20u
#define BOOTSTRAP_STEP_RUN_APP 21u
#define BOOTSTRAP_STEP_DUMP 22u
#define BOOTSTRAP_STEP_FILE_SIZE 23u
#define BOOTSTRAP_STEP_FILE_HASH 24u
#define BOOTSTRAP_STEP_GEN_LIBC_RESOLVE 25u
#define BOOTSTRAP_STEP_COMPILE_EXPECT_EXIT 26u
#define BOOTSTRAP_STEP_PACK_APE 27u
#define BOOTSTRAP_STEP_INSPECT_APE 28u
#define BOOTSTRAP_STEP_RUN_APE 29u
#define BOOTSTRAP_STEP_INSPECT_EXPECT_EXIT 30u
#define BOOTSTRAP_STEP_RUN_APE_EXPECT_EXIT 31u
#define BOOTSTRAP_STEP_PACK_APE_BARE 32u
#define BOOTSTRAP_STEP_PACK_APE_BARE_ENV 33u
#define BOOTSTRAP_STEP_BUILD_SLICE 34u
#define BOOTSTRAP_STEP_BUILD_SLICE_LISP 35u
#define BOOTSTRAP_STEP_NANO_CC_COMPILE 36u
#define BOOTSTRAP_STEP_SQUAD_ASSESS 37u
#define BOOTSTRAP_STEP_SQUAD_DISPATCH 38u
#define BOOTSTRAP_STEP_RESULTS_MIN 38u
#define BOOTSTRAP_STEP_IR_TABLE_LISP 39u
#define BOOTSTRAP_STEP_BUILD_SLICE_COMPILE 40u
#define BOOTSTRAP_STEP_READ_FILE 41u
#define BOOTSTRAP_STEP_SPAWN_WAIT 42u

typedef uint64_t (*jit_entry_fn)(void);
typedef int (*ffi_i32_ptr_fn)(const char *);
typedef int (*ffi_i32_ptr_ptr_fn)(const char *, const char *);
typedef int (*ffi_i32_void_fn)(void);
typedef int (*ffi_i32_i32_fn)(int);

typedef struct {
  char *name;
  char *lib;
  char *symbol;
  uint32_t sig;
} ImportDef;

typedef struct {
  char *name;
  char *value;
} ConstDef;

typedef struct {
  uint32_t form;
  char *import_name;
  char *const_name;
  char *const2_name;
  uint64_t imm;
} InstrDef;

typedef struct {
  char *name;
  InstrDef *instrs;
  size_t instr_count;
  size_t instr_cap;
  int param_count;
} VmFuncDef;

typedef struct {
  ImportDef *imports;
  size_t import_count;
  size_t import_cap;
  ConstDef *consts;
  size_t const_count;
  size_t const_cap;
  InstrDef *instrs;
  size_t instr_count;
  size_t instr_cap;
  VmFuncDef *funcs;
  size_t func_count;
  size_t func_cap;
} Module;

typedef struct {
  uint32_t kind;
  uint64_t imm;
  char *target_name;
} AotStmt;

typedef struct {
  char *name;
  int is_global;
  AotStmt *stmts;
  size_t stmt_count;
  size_t stmt_cap;
  int param_count;
} AotFunc;

typedef struct {
  AotFunc *funcs;
  size_t func_count;
  size_t func_cap;
} AotModule;

typedef struct {
  uint32_t patch_off;
  const char *target_name;
} AotCallPatch;

typedef struct {
  uint32_t kind;
  char *arg0;
  char *arg1;
  char *arg2;
  char *arg3;
  char **extra_args;
  size_t extra_arg_count;
} BootstrapStep;

typedef struct {
  BootstrapStep *steps;
  size_t step_count;
  size_t step_cap;
} BootstrapPlan;

typedef struct {
  unsigned char *data;
  size_t len;
  size_t cap;
} Buf;

typedef struct {
  unsigned char *data;
  size_t size;
  uint32_t format;
  uint32_t version;
  uint32_t import_count;
  uint32_t const_count;
  uint32_t instr_count;
  uint32_t string_size;
  uint32_t func_count;
  size_t import_off;
  size_t const_off;
  size_t instr_off;
  size_t string_off;
  size_t func_off;
} Blob;

typedef struct {
  const char *name;
  uint32_t pc;
} LabelDef;

typedef enum {
  VAL_U64 = 1,
  VAL_I64 = 2,
  VAL_BOOL = 3,
  VAL_PTR = 4,
} ValueKind;

typedef struct {
  ValueKind kind;
  uint64_t bits;
} Value;

#endif /* NANO_TYPES_H */
