#pragma once

#include <cn-executable/utils.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

// Core Lua State
void       lua_init();
void       lua_deinit();
lua_State* lua_get_state();

// Lua CN Runtime State
void lua_cn_load_runtime(
    const char* filename,
    int ghost_array_size, 
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

// Thunks
void lua_push_bool_thunk(bool val);
void lua_push_char_thunk(char val);
void lua_push_integer_thunk(int val);
void lua_push_float_thunk(float val);
void lua_push_pointer_thunk(void* addr, int ptr_depth, const char* final_reader_name);