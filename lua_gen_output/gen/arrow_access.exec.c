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
static void lua_cn_arrow_access_1_push_frame();
static void lua_cn_arrow_access_1_precondition();
static void lua_cn_inline_instance0(struct s*);
static void lua_cn_inline_instance1(struct s**);
static void lua_cn_inline_instance2(struct s**);
static void lua_cn_inline_instance3(struct s**);
static void lua_cn_inline_instance4(struct s**, struct s**);
static void lua_cn_arrow_access_1_postcondition();
static void lua_cn_arrow_access_2_push_frame(struct s*);
static void lua_cn_arrow_access_2_precondition();
static void lua_cn_inline_instance5(struct s**);
static void lua_cn_arrow_access_2_postcondition();
static void lua_cn_main_push_frame();
static void lua_cn_main_precondition();
static void lua_cn_main_postcondition(signed int);
static signed int lua_cn_push_s_size();
static void lua_cn_push_s_offsets();
static void lua_cn_push_s(struct s*);
static void lua_cn_push_runtime_metadata();
static signed int lua_cn_get_s();

# 1 "./tests/cn/arrow_access.c"
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
# 1 "./tests/cn/arrow_access.c" 2
struct s;

void arrow_access_1()
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_arrow_access_1_push_frame();
  lua_cn_arrow_access_1_precondition();
  
  struct s origin = { .x = 0, .y = 0 };
lua_cn_ghost_add((&origin), sizeof(struct s), lua_cn_get_stack_depth());

  lua_cn_inline_instance0((&origin));
 // -- member
  struct s *p = &origin;
lua_cn_ghost_add((&p), sizeof(struct s*), lua_cn_get_stack_depth());

  struct s *q = &origin;
lua_cn_ghost_add((&q), sizeof(struct s*), lua_cn_get_stack_depth());


  lua_cn_inline_instance1((&p));
 // Arrow access
  lua_cn_inline_instance2((&p));
 // ... desugared as this
  CN_STORE((*CN_LOAD(p)).y, 7);
  lua_cn_inline_instance3((&q));

  lua_cn_inline_instance4((&p), (&q));


lua_cn_ghost_remove((&origin), sizeof(struct s));


lua_cn_ghost_remove((&p), sizeof(struct s*));


lua_cn_ghost_remove((&q), sizeof(struct s*));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_arrow_access_1_postcondition();

  lua_cn_frame_pop_function();
}

void arrow_access_2 (struct s *origin)
/*@
requires
  take Or = RW<struct s>(origin);
  origin->y == 0i32;
ensures
  take Or_ = RW<struct s>(origin);
  origin->y == 7i32;
  (*origin).y == 7i32;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_arrow_access_2_push_frame(origin);
  lua_cn_arrow_access_2_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&origin), sizeof(struct s*), lua_cn_get_stack_depth());
  
  CN_STORE(CN_LOAD(origin)->y, 7);
  lua_cn_inline_instance5((&origin));


/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&origin), sizeof(struct s*));

  lua_cn_arrow_access_2_postcondition();

  lua_cn_frame_pop_function();
}

int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./lua_gen_output/gen/arrow_access.lua", 0, -1, -1, 0, 0);
  lua_cn_push_runtime_metadata();
  
  (
({
  ghost_call_site = EMPTY;
  0;
})
, arrow_access_1());

  struct s a = { .x = 0, .y = 0 };
lua_cn_ghost_add((&a), sizeof(struct s), lua_cn_get_stack_depth());

  (
({
  ghost_call_site = EMPTY;
  0;
})
, arrow_access_2(&a));

  { __cn_ret = 0; 
lua_cn_ghost_remove((&a), sizeof(struct s));
goto __cn_epilogue; }

lua_cn_ghost_remove((&a), sizeof(struct s));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_unload_runtime();

  lua_deinit();

return __cn_ret;

}


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_arrow_access_1_push_frame()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "push_frame");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_1_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_inline_instance0(struct s* origin)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "inline");
  lua_getfield(L, -1, "instance0");
  lua_pushinteger(L, lua_convert_ptr_to_int(origin));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_inline_instance1(struct s** p)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "inline");
  lua_getfield(L, -1, "instance1");
  lua_pushinteger(L, lua_convert_ptr_to_int(p));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_inline_instance2(struct s** p)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "inline");
  lua_getfield(L, -1, "instance2");
  lua_pushinteger(L, lua_convert_ptr_to_int(p));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_inline_instance3(struct s** q)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "inline");
  lua_getfield(L, -1, "instance3");
  lua_pushinteger(L, lua_convert_ptr_to_int(q));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_inline_instance4(struct s** p, struct s** q)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "inline");
  lua_getfield(L, -1, "instance4");
  lua_pushinteger(L, lua_convert_ptr_to_int(p));
  lua_pushinteger(L, lua_convert_ptr_to_int(q));
  lua_pcall(L, 2, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_1_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_2_push_frame(struct s* origin)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(origin));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_2_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_inline_instance5(struct s** origin)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "inline");
  lua_getfield(L, -1, "instance5");
  lua_pushinteger(L, lua_convert_ptr_to_int(origin));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_2_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
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
static void lua_cn_main_postcondition(signed int __cn_ret)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "postcondition");
  lua_pushinteger(L, __cn_ret);
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static signed int lua_cn_push_s_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct s));
  lua_setfield(L, -2, "s");
  lua_pop(L, 3);
  return 1;
}
static void lua_cn_push_s_offsets()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "offsets");
  lua_newtable(L);
  lua_pushinteger(L, offsetof(struct s, x));
  lua_setfield(L, -2, "x");
  lua_pushinteger(L, offsetof(struct s, y));
  lua_setfield(L, -2, "y");
  lua_setfield(L, -2, "s");
  lua_pop(L, 3);
}
static void lua_cn_push_s(struct s* data)
{
  struct lua_State* L = lua_get_state();
  lua_newtable(L);
  lua_pushinteger(L, data->x);
  lua_setfield(L, -2, "x");
  lua_pushinteger(L, data->y);
  lua_setfield(L, -2, "y");
}
static void lua_cn_push_runtime_metadata()
{
  {
    lua_cn_register_c_func("get_s", lua_cn_get_s);
  }
  {
    lua_cn_push_s_size();
  }
  {
    lua_cn_push_s_offsets();
  }
}
static signed int lua_cn_get_s()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct s* data = (struct s*) ptr;
  lua_cn_push_s(data);
  return 1;
}

