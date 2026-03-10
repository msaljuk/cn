#include <lua_wrappers.h>
#include <cn-executable/utils.h>

#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct s {
  signed int x;
  signed int y;
};

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_simple_integer_push_frame(signed int);
static void lua_cn_simple_integer_precondition();
static void lua_cn_simple_integer_postcondition();
static void lua_cn_simple_owned_push_frame(struct s*);
static void lua_cn_simple_owned_precondition();
static void lua_cn_simple_owned_postcondition();
static void lua_cn_addtl_indirection_owned_push_frame(struct s**);
static void lua_cn_addtl_indirection_owned_precondition();
static void lua_cn_addtl_indirection_owned_postcondition();
static signed int push_struct_s_size();
static signed int get_struct_s();

# 1 "./lua_gen_output/basic_owned_example.c"
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
# 1 "./lua_gen_output/basic_owned_example.c" 2
void simple_integer (int s)
/*@
requires
  s == 0i32;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_simple_integer_push_frame(s);
  lua_cn_simple_integer_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&s), sizeof(signed int), lua_cn_get_stack_depth());
  

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&s), sizeof(signed int));

  lua_cn_simple_integer_postcondition();

  lua_cn_frame_pop_function();
}

struct s;

void simple_owned (struct s *origin)
/*@
requires
  take Or = RW<struct s>(origin);
  Or.y == 0i32;
ensures
  take Or_ = RW<struct s>(origin);
  Or_.y == 7i32;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_simple_owned_push_frame(origin);
  lua_cn_simple_owned_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&origin), sizeof(struct s*), lua_cn_get_stack_depth());
  
  CN_STORE(CN_LOAD(origin)->y, 7);

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&origin), sizeof(struct s*));

  lua_cn_simple_owned_postcondition();

  lua_cn_frame_pop_function();
}

void addtl_indirection_owned (struct s **origin)
/*@
requires
  take Or = RW<struct s*>(origin);
  take Or_ = RW<struct s>(Or);
  Or_.y == 7i32;
ensures
  take Or = RW<struct s*>(origin);
  take Or_ = RW<struct s>(Or);
  Or_.y == 0i32;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_addtl_indirection_owned_push_frame(origin);
  lua_cn_addtl_indirection_owned_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&origin), sizeof(struct s**), lua_cn_get_stack_depth());

  CN_STORE(CN_LOAD((*CN_LOAD(origin)))->y, 0);

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&origin), sizeof(struct s**));

  lua_cn_addtl_indirection_owned_postcondition();

  lua_cn_frame_pop_function();
}


int main(void)
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./lua_gen_output/basic_owned_example.lua", 0, 0, 0, 0, 0);
  
  lua_cn_register_c_func("get_struct_s", get_struct_s);
  push_struct_s_size();

  int x = 0;
lua_cn_ghost_add((&x), sizeof(signed int), lua_cn_get_stack_depth());

  (
({
  ghost_call_site = EMPTY;
  0;
})
, simple_integer(CN_LOAD(x)));

  struct s sample = { .x = 7, .y = 0 };
lua_cn_ghost_add((&sample), sizeof(struct s), lua_cn_get_stack_depth());

  (
({
  ghost_call_site = EMPTY;
  0;
})
, simple_owned(&sample));

  struct s *s_addr = &sample;
lua_cn_ghost_add((&s_addr), sizeof(struct s*), lua_cn_get_stack_depth());

  (
({
  ghost_call_site = EMPTY;
  0;
})
, addtl_indirection_owned(&s_addr));

lua_cn_ghost_remove((&x), sizeof(signed int));


lua_cn_ghost_remove((&sample), sizeof(struct s));


lua_cn_ghost_remove((&s_addr), sizeof(struct s*));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_unload_runtime();

  lua_deinit();

return __cn_ret;

}


static void lua_cn_simple_integer_push_frame(signed int s)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "simple_integer");
  lua_getfield(L, -1, "push_frame");
  lua_push_integer_thunk(s);
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_simple_integer_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "simple_integer");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_simple_integer_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "simple_integer");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_simple_owned_push_frame(struct s* origin)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "simple_owned");
  lua_getfield(L, -1, "push_frame");
  lua_push_pointer_thunk(origin, 1, "get_struct_s");
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_simple_owned_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "simple_owned");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_simple_owned_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "simple_owned");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static signed int push_struct_s_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct s));
  lua_setfield(L, -2, "struct_s");
  lua_pop(L, 3);
  return 1;
}
static signed int get_struct_s()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct s* val = (struct s*) ptr;
  lua_newtable(L);
  lua_pushstring(L, "x");
  lua_push_integer_thunk(val->x);
  lua_settable(L, -3);
  lua_pushstring(L, "y");
  lua_push_integer_thunk(val->y);
  lua_settable(L, -3);
  return 1;
}

static void lua_cn_addtl_indirection_owned_push_frame(struct s** origin)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "addtl_indirection_owned");
  lua_getfield(L, -1, "push_frame");
  lua_push_pointer_thunk(origin, 2, "get_struct_s");
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_addtl_indirection_owned_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "addtl_indirection_owned");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_addtl_indirection_owned_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "addtl_indirection_owned");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}

