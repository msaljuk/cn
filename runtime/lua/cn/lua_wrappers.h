#pragma once

//@saljuk NOTE: DO NOT TOUCH! (unless you know what you're doing)
// 
// Some files in Lua include defines that clash with cerberus's ones (e.g max_align_t). 
// We do empty defines here so that the compiler skips the internal library definitions
// and waits for cerberus to define them.
//
// Since lua_wrappers.h is always the FIRST include in the instrumented Lua file, this 
// works fine. If that changes, you WILL have to make changes to keep this working.
#define __max_align_t_defined
#define _MAX_ALIGN_T
#define _MAX_ALIGN_T_DEFINED
#define __CLANG_MAX_ALIGN_T_DEFINED
#define _GCC_MAX_ALIGN_T

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <stdbool.h>

// Core Lua State
void       lua_init();
void       lua_deinit();
lua_State* lua_get_state();

// Lua CN Runtime State
void lua_cn_load_runtime(
    const char* filename,
    int max_bump_blocks,
    int bump_block_size,
    _Bool exec_c_locs_mode,
    _Bool ownership_stack_mode);
void lua_cn_unload_runtime();
int  lua_cn_get_runtime_ref();
void lua_cn_register_c_func(const char* func_name, lua_CFunction func);

// Lua CN Ghost State
void lua_cn_ghost_add(void* ptr, size_t size, signed long stack_depth);
void lua_cn_ghost_remove(void* ptr, size_t size);
signed long lua_cn_get_stack_depth();

// Lua CN Error Handling
void lua_cn_error_push(const char* msg);
void lua_cn_error_pop();

// Lua CN Frames
void lua_cn_frame_push_function();
void lua_cn_frame_pop_function();
void lua_cn_frame_push_loop();
void lua_cn_frame_pop_loop();

// Types Utils
int64_t lua_convert_ptr_to_int(void* ptr);

// Arrays
#define DECLARE_PUSH_ARRAY_FUNC(type_name, c_type)                       \
void lua_cn_push_##type_name##_array(c_type *arr, int size);

DECLARE_PUSH_ARRAY_FUNC(char,        char)
DECLARE_PUSH_ARRAY_FUNC(u_8,         uint8_t)
DECLARE_PUSH_ARRAY_FUNC(i_8,         int8_t)
DECLARE_PUSH_ARRAY_FUNC(u_int,       unsigned int)
DECLARE_PUSH_ARRAY_FUNC(int,         int)
DECLARE_PUSH_ARRAY_FUNC(u_long,      unsigned long)
DECLARE_PUSH_ARRAY_FUNC(long,        long)
DECLARE_PUSH_ARRAY_FUNC(long_long,   long long)
DECLARE_PUSH_ARRAY_FUNC(u_long_long, unsigned long long)
DECLARE_PUSH_ARRAY_FUNC(float,       float)              
DECLARE_PUSH_ARRAY_FUNC(double,      double)          
DECLARE_PUSH_ARRAY_FUNC(bool,        bool)

// Misc.
void lua_cn_abort();