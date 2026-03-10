#include "lua_wrappers.h"

#include <assert.h>

// Lua globals

lua_State *lua_state = NULL;
int lua_cn_runtime_ref = LUA_NOREF;

static const char* LUA_FACTORY_BASE_TYPE_NAME = "base_type";
static const char* LUA_FACTORY_POINTER_TYPE_NAME = "pointer_type";

// Core Lua State

void lua_init() {
    lua_state = luaL_newstate();
    luaL_openlibs(lua_state);
}

void lua_deinit() {
    lua_close(lua_state);
    lua_state = NULL;
}

lua_State* lua_get_state() { return lua_state; }

// Lua CN Runtime State

// C wrappers

static int c_assert_wrapper() {
    bool cond  = lua_toboolean(lua_state, 1);
    int64_t spec_mode = (int64_t)luaL_checkinteger(lua_state, 2);

    cn_assert(convert_to_cn_bool(cond), (enum spec_mode)spec_mode);

    return 0;
}

static int c_add_to_ghost_state_wrapper() {
    int64_t addr  = (int64_t)luaL_checkinteger(lua_state, 1);
    int64_t size = (int64_t)luaL_checkinteger(lua_state, 2);

    c_add_to_ghost_state((void*)addr, (size_t)size, get_cn_stack_depth());

    return 0;
}

static int c_remove_from_ghost_state_wrapper() {
    int64_t addr  = (int64_t)luaL_checkinteger(lua_state, 1);
    int64_t size = (int64_t)luaL_checkinteger(lua_state, 2);

    c_remove_from_ghost_state((void*)addr, (size_t)size);

    return 0;
}

static int c_get_or_put_ownership_wrapper() {
    int64_t spec_mode = (int64_t)luaL_checkinteger(lua_state, 1);
    int64_t addr  = (int64_t)luaL_checkinteger(lua_state, 2);
    int64_t size = (int64_t)luaL_checkinteger(lua_state, 3);
    int64_t loop_ownership = (int64_t)luaL_checkinteger(lua_state, 4);

    cn_get_or_put_ownership(
        (enum spec_mode)spec_mode, 
        (void*)addr, 
        (size_t)size,
        (struct loop_ownership*)loop_ownership
    );

    return 0;
}

static int c_ghost_state_depth_incr() {
    ghost_stack_depth_incr();
    return 0;
}

static int c_ghost_state_depth_decr() {
    ghost_stack_depth_decr();
    return 0;
}

static int c_postcondition_leak_check_wrapper() {
    cn_postcondition_leak_check();
    return 0;
}

static int c_update_error_msg_info_wrapper() {
    size_t length;
    const char* msg = luaL_checklstring(lua_state, 1, &length);

    update_cn_error_message_info(msg);

    return 0;
}

static int c_pop_msg_wrapper() {
    cn_pop_msg_info();
    return 0;
}

static int c_dump_error_msgs_wrapper() {
    cn_dump_error_msgs();
    return 0;
}

static int c_get_bool() {
    bool* addr = (bool*)luaL_checkinteger(lua_state, 1);
    lua_pushboolean(lua_state, *addr);
    return 1;
}

static int c_get_char() {
    char* addr = (char*)luaL_checkinteger(lua_state, 1);
    lua_pushlstring(lua_state, addr, 1);
    return 1;
}

static int c_get_integer() {
    int* addr = (int*)luaL_checkinteger(lua_state, 1);
    lua_pushinteger(lua_state, *addr);
    return 1;
}

static int c_get_float() {
    float* addr = (float*)luaL_checkinteger(lua_state, 1);
    lua_pushnumber(lua_state, *addr);
    return 1;
}

static int c_get_pointer() {
    void** addr = (void**)luaL_checkinteger(lua_state, 1);
    lua_pushinteger(lua_state, lua_convert_ptr_to_int(*addr));
    return 1;
}

static int c_initialise_loop_ownership_state() {
    struct loop_ownership* state = initialise_loop_ownership_state();
    lua_pushinteger(lua_state, lua_convert_ptr_to_int(state));
    return 1;
}

static int c_loop_put_back_ownership() {
    struct loop_ownership* state = (struct loop_ownership*)luaL_checkinteger(lua_state, 1);
    cn_loop_put_back_ownership(state);
    return 0;
}

void push_cn_c_tables() {
    lua_rawgeti(lua_state, LUA_REGISTRYINDEX, lua_cn_runtime_ref);
    lua_getfield(lua_state, -1, "c");

    // Size-of Table
    {
        lua_newtable(lua_state);

        lua_pushinteger(lua_state, (lua_Integer)sizeof(bool));
        lua_setfield(lua_state, -2, "bool");

        lua_pushinteger(lua_state, (lua_Integer)sizeof(char));
        lua_setfield(lua_state, -2, "char");

        lua_pushinteger(lua_state, (lua_Integer)sizeof(int));
        lua_setfield(lua_state, -2, "int");

        lua_pushinteger(lua_state, (lua_Integer)sizeof(float));
        lua_setfield(lua_state, -2, "float");

        lua_pushinteger(lua_state, (lua_Integer)sizeof(void*));
        lua_setfield(lua_state, -2, "pointer");

        lua_setfield(lua_state, -2, "sizeof");
    }

    lua_pop(lua_state, 2);
}

void bind_cn_c_functions() {
    // C assert
    lua_cn_register_c_func("assert", c_assert_wrapper);

    // C ghost state
    lua_cn_register_c_func("add_to_ghost_state", c_add_to_ghost_state_wrapper);
    lua_cn_register_c_func("remove_from_ghost_state", c_remove_from_ghost_state_wrapper);
    lua_cn_register_c_func("get_or_put_ownership", c_get_or_put_ownership_wrapper);
    lua_cn_register_c_func("ghost_state_depth_incr", c_ghost_state_depth_incr);
    lua_cn_register_c_func("ghost_state_depth_decr", c_ghost_state_depth_decr);
    lua_cn_register_c_func("postcondition_leak_check", c_postcondition_leak_check_wrapper);

    // C error handling
    lua_cn_register_c_func("update_error_msg_info", c_update_error_msg_info_wrapper);
    lua_cn_register_c_func("pop_msg_info", c_pop_msg_wrapper);
    lua_cn_register_c_func("dump_error_msgs", c_dump_error_msgs_wrapper);

    // C type reading
    lua_cn_register_c_func("get_bool", c_get_bool);
    lua_cn_register_c_func("get_char", c_get_char);
    lua_cn_register_c_func("get_integer", c_get_integer);
    lua_cn_register_c_func("get_float", c_get_float);
    lua_cn_register_c_func("get_pointer", c_get_pointer);

    // C loop checks
    lua_cn_register_c_func("initialise_loop_ownership_state", c_initialise_loop_ownership_state);
    lua_cn_register_c_func("loop_put_back_ownership", c_loop_put_back_ownership);
}

void lua_cn_load_runtime(
    const char* filename, 
    int ghost_array_size,
    int max_bump_blocks,
    int bump_block_size,
    _Bool exec_c_locs_mode,
    _Bool ownership_stack_mode) {
    assert(lua_state != NULL);

    // C runtime (keeping this as is for now, especially because some of the Lua
    // runtime still binds to C)
    initialise_ownership_ghost_state();
    initialise_ghost_stack_depth();
    alloc_ghost_array(ghost_array_size);
    initialise_exec_c_locs_mode(exec_c_locs_mode);
    initialise_ownership_stack_mode(ownership_stack_mode);

    if (max_bump_blocks > 0) {
        cn_bump_set_max_blocks(max_bump_blocks);
    }
    if (bump_block_size > 0) {
        cn_bump_set_block_size(bump_block_size);
    }
    
    lua_getglobal(lua_state, "package");
    lua_getfield(lua_state, -1, "path"); // get package.path
    const char *current_path = lua_tostring(lua_state, -1);
    lua_pop(lua_state, 1);
    char new_path[1024];
    snprintf(new_path, sizeof(new_path), "%s;%s/?.lua", current_path, "./runtime/lua/cn");
    lua_pushstring(lua_state, new_path);
    lua_setfield(lua_state, -2, "path");
    lua_pop(lua_state, 1);

    if (luaL_dofile(lua_state, filename) != LUA_OK) {
        fprintf(stderr, "Unable to load lua cn runtime: %s\n", lua_tostring(lua_state, -1));
        lua_pop(lua_state, 1);
        return;
    }

    lua_cn_runtime_ref = luaL_ref(lua_state, LUA_REGISTRYINDEX);

    bind_cn_c_functions();
    push_cn_c_tables();
}

void lua_cn_unload_runtime()
{
    assert(lua_cn_runtime_ref != LUA_NOREF);

    luaL_unref(lua_state, LUA_REGISTRYINDEX, lua_cn_runtime_ref);
    lua_cn_runtime_ref = LUA_NOREF;

    // C runtime stuff
    free_ghost_array();
}

int lua_cn_get_runtime_ref() { return lua_cn_runtime_ref; }

void lua_cn_register_c_func(const char* func_name, lua_CFunction func) {
    lua_rawgeti(lua_state, LUA_REGISTRYINDEX, lua_cn_runtime_ref);
    lua_getfield(lua_state, -1, "c");
    lua_pushcfunction(lua_state, func);
    lua_setfield(lua_state, -2, func_name);
    lua_pop(lua_state, 2);
}

// Lua CN Ghost State
void lua_cn_ghost_add(void* ptr, size_t size, signed long stack_depth) {
    //@note: Kept in C for now
    c_add_to_ghost_state(ptr, size, stack_depth);
}

void lua_cn_ghost_remove(void* ptr, size_t size) {
    //@note: Kept in C for now
    c_remove_from_ghost_state(ptr, size);
}

signed long lua_cn_get_stack_depth() {
    //@note: Kept in C for now
    return get_cn_stack_depth();
}

// Lua CN Error Handling
void lua_cn_error_push(const char* msg) {
    //@note: Kept in C for now
    update_cn_error_message_info(msg);
}

void lua_cn_error_pop() {
    //@note: Kept in C for now
    cn_pop_msg_info();
}

// Lua CN Frames
void lua_cn_frame_push_function() {
  lua_rawgeti(lua_state, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(lua_state, -1, "frames");
  lua_getfield(lua_state, -1, "push_function");

  if (lua_pcall(lua_state, 0, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling cn.frames.push_function: %s\n", lua_tostring(lua_state, -1));
      lua_pop(lua_state, 1);
  }

  lua_pop(lua_state, 2);
}

void lua_cn_frame_pop_function() {
    lua_rawgeti(lua_state, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
    lua_getfield(lua_state, -1, "frames");
    lua_getfield(lua_state, -1, "pop_function");

    if (lua_pcall(lua_state, 0, 0, 0) != LUA_OK) {
        fprintf(stderr, "Error calling cn.frames.pop_function: %s\n", lua_tostring(lua_state, -1));
        lua_pop(lua_state, 1);
    }

    lua_pop(lua_state, 2);
}

void lua_cn_frame_push_loop() {
  lua_rawgeti(lua_state, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(lua_state, -1, "frames");
  lua_getfield(lua_state, -1, "push_loop");

  if (lua_pcall(lua_state, 0, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling cn.frames.push_loop: %s\n", lua_tostring(lua_state, -1));
      lua_pop(lua_state, 1);
  }

  lua_pop(lua_state, 2);
}

void lua_cn_frame_pop_loop() {
    lua_rawgeti(lua_state, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
    lua_getfield(lua_state, -1, "frames");
    lua_getfield(lua_state, -1, "pop_loop");

    if (lua_pcall(lua_state, 0, 0, 0) != LUA_OK) {
        fprintf(stderr, "Error calling cn.frames.pop_loop: %s\n", lua_tostring(lua_state, -1));
        lua_pop(lua_state, 1);
    }

    lua_pop(lua_state, 2);
}

// Types Utils
int64_t lua_convert_ptr_to_int(void* ptr) {
    return (int64_t)(uintptr_t)ptr;
}

// Thunks

// Helpers
int lua_push_factories_table(const char* factory_type_name)
{
    struct lua_State* L = lua_get_state();
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
    int cn_idx = lua_gettop(L);

    lua_getfield(L, cn_idx, "factories");
    lua_getfield(L, -1, factory_type_name);

    return cn_idx;
}

void lua_call_factories_table(int cn_idx, int factory_arg_count)
{
    struct lua_State* L = lua_get_state();

    if (lua_pcall(L, factory_arg_count, 1, 0) != LUA_OK) {
        fprintf(stderr, "Thunk Factory Error: %s. Top idx: %d\n. ", 
            lua_tostring(L, -1),
            lua_gettop(L));
        return;
    }

    lua_replace(L, cn_idx); 
    lua_settop(L, cn_idx);
}

void lua_push_bool_thunk(bool val) {
    int cn_idx = lua_push_factories_table(LUA_FACTORY_BASE_TYPE_NAME);
    lua_State* L = lua_get_state();
    lua_pushboolean(L, val);
    lua_call_factories_table(cn_idx, 1);
}

void lua_push_char_thunk(char val) {
    int cn_idx = lua_push_factories_table(LUA_FACTORY_BASE_TYPE_NAME);
    lua_State* L = lua_get_state();
    lua_pushlstring(lua_state, &val, 1);
    lua_call_factories_table(cn_idx, 1);
}

void lua_push_integer_thunk(int val) {
    int cn_idx = lua_push_factories_table(LUA_FACTORY_BASE_TYPE_NAME);
    lua_State* L = lua_get_state();
    lua_pushinteger(lua_state, val);
    lua_call_factories_table(cn_idx, 1);
}

void lua_push_float_thunk(float val) {
    int cn_idx = lua_push_factories_table(LUA_FACTORY_BASE_TYPE_NAME);
    lua_State* L = lua_get_state();
    lua_pushnumber(lua_state, val);
    lua_call_factories_table(cn_idx, 1);
}

void lua_push_pointer_thunk(void* addr, int ptr_depth, const char* final_reader_name) {
    struct lua_State* L = lua_get_state();
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
    int cn_idx = lua_gettop(L);

    lua_getfield(L, cn_idx, "c");
    lua_getfield(L, -1, final_reader_name);
    int reader_idx = lua_gettop(L);

    lua_getfield(L, cn_idx, "factories");
    lua_getfield(L, -1, LUA_FACTORY_POINTER_TYPE_NAME);
    
    lua_pushinteger(L, lua_convert_ptr_to_int(addr));
    lua_pushinteger(L, ptr_depth);
    lua_pushvalue(L, reader_idx);

    lua_call_factories_table(cn_idx, 3);
}