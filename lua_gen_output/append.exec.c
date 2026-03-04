#include <lua_wrappers.h>
#include <cn-executable/utils.h>

#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct int_list {
  signed int head;
  struct int_list* tail;
};

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_IntList_append_push_frame(struct int_list**, struct int_list**, struct int_list*);
static void lua_cn_IntList_append_precondition();
static void lua_cn_IntList_append_postcondition();
static void lua_cn_main_push_frame();
static void lua_cn_main_precondition();
static void lua_cn_main_postcondition();
static signed int push_int_list_size();
static signed int peek_int_list();

# 1 "./tests/cn/append.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3








# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "/Users/saljukgondal/.opam/5.2.0/lib/cerberus-lib/runtime/libc/include/builtins.h" 1
// Some gcc builtins we support
[[ cerb::hidden ]] int __builtin_ffs (int x);
[[ cerb::hidden ]] int __builtin_ffsl (long x);
[[ cerb::hidden ]] int __builtin_ffsll (long long x);
[[ cerb::hidden ]] int __builtin_ctz (unsigned int x);
[[ cerb::hidden ]] int __builtin_ctzl (unsigned long x);
[[ cerb::hidden ]] int __builtin_ctzll (unsigned long long x);
[[ cerb::hidden ]] __cerbty_uint16_t __builtin_bswap16 (__cerbty_uint16_t x);
[[ cerb::hidden ]] __cerbty_uint32_t __builtin_bswap32 (__cerbty_uint32_t x);
[[ cerb::hidden ]] __cerbty_uint64_t __builtin_bswap64 (__cerbty_uint64_t x);
[[ cerb::hidden ]] void __builtin_unreachable(void);

// this is an optimisation hint that we can erase
# 2 "<built-in>" 2
# 1 "./tests/cn/append.c" 2
struct int_list;



struct int_list* IntList_append(struct int_list* xs, struct int_list* ys, struct int_list actual_struct_param)
/*@ requires take L1 = IntList(xs);
             take L2 = IntList(ys);
    ensures take L3 = IntList(return);
            L3 == append(L1, L2); @*/
{
  /* EXECUTABLE CN PRECONDITION */
  struct int_list* __cn_ret;
  lua_cn_IntList_append_push_frame((&xs), (&ys), (&actual_struct_param));
  lua_cn_IntList_append_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&xs), sizeof(struct int_list*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&ys), sizeof(struct int_list*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&actual_struct_param), sizeof(struct int_list), lua_cn_get_stack_depth());
  
  if (CN_LOAD(xs) == 0) {
    update_cn_error_message_info("    /*@ unfold append(L1, L2); @*/\n       ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/append.c:41:8-33");

update_cn_error_message_info("    /*@ unfold append(L1, L2); @*/\n        ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/append.c:41:9-31");

cn_pop_msg_info();

cn_pop_msg_info();

    { __cn_ret = CN_LOAD(ys); goto __cn_epilogue; }
  } else {
    update_cn_error_message_info("    /*@ unfold append(L1, L2); @*/\n       ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/append.c:44:8-33");

update_cn_error_message_info("    /*@ unfold append(L1, L2); @*/\n        ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/append.c:44:9-31");

cn_pop_msg_info();

cn_pop_msg_info();

    struct int_list *new_tail = (
({
  ghost_call_site = EMPTY;
  0;
})
, IntList_append(CN_LOAD(CN_LOAD(xs)->tail), CN_LOAD(ys), CN_LOAD(actual_struct_param)));
lua_cn_ghost_add((&new_tail), sizeof(struct int_list*), lua_cn_get_stack_depth());

    CN_STORE(CN_LOAD(xs)->tail, CN_LOAD(new_tail));
    { __cn_ret = CN_LOAD(xs); 
lua_cn_ghost_remove((&new_tail), sizeof(struct int_list*));
goto __cn_epilogue; }
  
lua_cn_ghost_remove((&new_tail), sizeof(struct int_list*));
}

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&xs), sizeof(struct int_list*));

  lua_cn_ghost_remove((&ys), sizeof(struct int_list*));

  lua_cn_ghost_remove((&actual_struct_param), sizeof(struct int_list));

  lua_cn_IntList_append_postcondition();

  lua_cn_frame_pop_function();

return __cn_ret;

}

int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./append.lua", 0, 0, 0, 0, 0);
  
  struct int_list i1 = {.head = 2, .tail = 0};
lua_cn_ghost_add((&i1), sizeof(struct int_list), lua_cn_get_stack_depth());

  struct int_list i3 = {.head = 4, .tail = 0};
lua_cn_ghost_add((&i3), sizeof(struct int_list), lua_cn_get_stack_depth());

  struct int_list i2 = {.head = 3, .tail = &i3};
lua_cn_ghost_add((&i2), sizeof(struct int_list), lua_cn_get_stack_depth());


  struct int_list *il3 = (
({
  ghost_call_site = EMPTY;
  0;
})
, IntList_append(&i1, &i2, CN_LOAD(i3)));
lua_cn_ghost_add((&il3), sizeof(struct int_list*), lua_cn_get_stack_depth());


lua_cn_ghost_remove((&i1), sizeof(struct int_list));


lua_cn_ghost_remove((&i3), sizeof(struct int_list));


lua_cn_ghost_remove((&i2), sizeof(struct int_list));


lua_cn_ghost_remove((&il3), sizeof(struct int_list*));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_unload_runtime();

  lua_deinit();

return __cn_ret;

}


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_IntList_append_push_frame(struct int_list** xs_addr, struct int_list** ys_addr, struct int_list* actual_struct_param_addr)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "IntList_append");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(xs_addr));
  lua_pushinteger(L, lua_convert_ptr_to_int(ys_addr));
  lua_pushinteger(L, lua_convert_ptr_to_int(actual_struct_param_addr));
  lua_pcall(L, 3, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_IntList_append_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "IntList_append");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_IntList_append_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "IntList_append");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_main_push_frame()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "push_frame");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_main_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_main_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static signed int push_int_list_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct int_list));
  lua_setfield(L, -2, "int_list");
  lua_pop(L, 3);
  return 1;
}
static signed int peek_int_list()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct int_list* val = (struct int_list*) ptr;
  lua_newtable(L);
  lua_pushstring(L, "head_addr");
  lua_pushinteger(L, lua_convert_ptr_to_int((&val->head)));
  lua_settable(L, -3);
  lua_pushstring(L, "tail_addr");
  lua_pushinteger(L, lua_convert_ptr_to_int((&val->tail)));
  lua_settable(L, -3);
  return 1;
}

