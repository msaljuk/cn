#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct s {
  signed int a;
  signed int b;
  struct s* s;
};

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;

/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_callme_push_frame(signed int, signed int*, signed int***, struct s, struct s*, struct s*);
static void lua_cn_callme_precondition();
static void lua_cn_callme_postcondition();
static void lua_cn_push_s(struct s*);
static void lua_cn_push_s_size();
static void lua_cn_push_s_offsets();
static void lua_cn_push_runtime_metadata();
static signed int lua_cn_get_s();

void callme(int a, int *b, int ***c, struct s s0, struct s *s1, struct s *s2)
/*@
requires
    take bb   = Owned<int>(b);
    take s1_b = Owned<int>(member_shift<struct s>(s1, b));
    take ss2  = Owned(s2);
    take cc   = Owned(c);
    take ccc  = Owned(cc);
    take cccc = Owned(ccc);
    a == 42i32;
    bb == 43i32;
    cccc == 44i32;
    s0.a == s0.b;
    s1_b == 45i32;
    ss2.a == ss2.b;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_callme_push_frame(a, b, c, s0, s1, s2);
  lua_cn_callme_precondition();
  
	/* C OWNERSHIP */
  lua_cn_ghost_add((&a), sizeof(signed int), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&b), sizeof(signed int*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&c), sizeof(signed int***), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&s0), sizeof(struct s), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&s1), sizeof(struct s*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&s2), sizeof(struct s*), lua_cn_get_stack_depth());
  
  /* BODY */
  int xxx = 1;
  lua_cn_ghost_add((&xxx), sizeof(signed int), lua_cn_get_stack_depth());
  lua_cn_ghost_remove((&xxx), sizeof(signed int));
  
	/* C OWNERSHIP */
  lua_cn_ghost_remove((&a), sizeof(signed int));
  lua_cn_ghost_remove((&b), sizeof(signed int*));
  lua_cn_ghost_remove((&c), sizeof(signed int***));
  lua_cn_ghost_remove((&s0), sizeof(struct s));
  lua_cn_ghost_remove((&s1), sizeof(struct s*));
  lua_cn_ghost_remove((&s2), sizeof(struct s*));

  /* EXECUTABLE CN POSTCONDITION */
  lua_cn_callme_postcondition();
  //lua_cn_frame_pop_function();
}

int main(void)
/*@ trusted; @*/
{
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./lua_gen_output/canonical_example.lua", 0, 1, 1024, 0, 0);
  lua_cn_register_c_func("get_s", lua_cn_get_s);
  lua_cn_push_runtime_metadata();

  int a = 42;
  lua_cn_ghost_add((&a), sizeof(signed int), lua_cn_get_stack_depth());

  int bb = 43;
  lua_cn_ghost_add((&bb), sizeof(signed int), lua_cn_get_stack_depth());

  int *b = &bb;
  lua_cn_ghost_add((&b), sizeof(signed int*), lua_cn_get_stack_depth());


  int cccc = 44;
  lua_cn_ghost_add((&cccc), sizeof(signed int), lua_cn_get_stack_depth());

  int *c1 = &cccc;
  lua_cn_ghost_add((&c1), sizeof(signed int*), lua_cn_get_stack_depth());

  int **c2 = &c1;
  lua_cn_ghost_add((&c2), sizeof(signed int**), lua_cn_get_stack_depth());

  int ***c = &c2;
  lua_cn_ghost_add((&c), sizeof(signed int***), lua_cn_get_stack_depth());


  struct s s0 = { .a = 0, .b = 0 };
  lua_cn_ghost_add((&s0), sizeof(struct s), lua_cn_get_stack_depth());


  struct s s1val = { .b = 45 };
  lua_cn_ghost_add((&s1val), sizeof(struct s), lua_cn_get_stack_depth());

  struct s* s1 = &s1val;
  lua_cn_ghost_add((&s1), sizeof(struct s*), lua_cn_get_stack_depth());


  struct s ss2 = { .a = 0, .b = 0 };
  lua_cn_ghost_add((&ss2), sizeof(struct s), lua_cn_get_stack_depth());

  struct s* s2 = &ss2;
  lua_cn_ghost_add((&s2), sizeof(struct s*), lua_cn_get_stack_depth());


  (
  ({
    ghost_call_site = EMPTY;
    0;
  })
  , callme(CN_LOAD(a), CN_LOAD(b), CN_LOAD(c), CN_LOAD(s0), CN_LOAD(s1), CN_LOAD(s2)));

  { __cn_ret = 0; 
  lua_cn_ghost_remove((&a), sizeof(signed int));


  lua_cn_ghost_remove((&bb), sizeof(signed int));


  lua_cn_ghost_remove((&b), sizeof(signed int*));


  lua_cn_ghost_remove((&cccc), sizeof(signed int));


  lua_cn_ghost_remove((&c1), sizeof(signed int*));


  lua_cn_ghost_remove((&c2), sizeof(signed int**));


  lua_cn_ghost_remove((&c), sizeof(signed int***));


  lua_cn_ghost_remove((&s0), sizeof(struct s));


  lua_cn_ghost_remove((&s1val), sizeof(struct s));


  lua_cn_ghost_remove((&s1), sizeof(struct s*));


  lua_cn_ghost_remove((&ss2), sizeof(struct s));


  lua_cn_ghost_remove((&s2), sizeof(struct s*));
  goto __cn_epilogue; }

  lua_cn_ghost_remove((&a), sizeof(signed int));


  lua_cn_ghost_remove((&bb), sizeof(signed int));


  lua_cn_ghost_remove((&b), sizeof(signed int*));


  lua_cn_ghost_remove((&cccc), sizeof(signed int));


  lua_cn_ghost_remove((&c1), sizeof(signed int*));


  lua_cn_ghost_remove((&c2), sizeof(signed int**));


  lua_cn_ghost_remove((&c), sizeof(signed int***));


  lua_cn_ghost_remove((&s0), sizeof(struct s));


  lua_cn_ghost_remove((&s1val), sizeof(struct s));


  lua_cn_ghost_remove((&s1), sizeof(struct s*));


  lua_cn_ghost_remove((&ss2), sizeof(struct s));


  lua_cn_ghost_remove((&s2), sizeof(struct s*));
  
  __cn_epilogue:

  lua_cn_unload_runtime();
  lua_deinit();

  return __cn_ret;
}


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_callme_push_frame(signed int a, signed int* b, signed int*** c, struct s s0, struct s* s1, struct s* s2)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "callme");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, a);
  lua_pushinteger(L, lua_convert_ptr_to_int(b));
  lua_pushinteger(L, lua_convert_ptr_to_int(c));
  lua_cn_push_s(&s0);
  lua_pushinteger(L, lua_convert_ptr_to_int(s1));
  lua_pushinteger(L, lua_convert_ptr_to_int(s2));
  lua_pcall(L, 6, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_callme_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "callme");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_callme_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "callme");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_push_s(struct s* data)
{
  struct lua_State* L = lua_get_state();

  lua_newtable(L);

  lua_pushinteger(L, data->a);
  lua_setfield(L, -2, "a");

  lua_pushinteger(L, data->b);
  lua_setfield(L, -2, "b");

  lua_pushinteger(L, lua_convert_ptr_to_int(data->s));
  lua_setfield(L, -2, "s");
}
static void lua_cn_push_s_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct s));
  lua_setfield(L, -2, "s");
  lua_pop(L, 3);
}
static void lua_cn_push_s_offsets()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "offsets");

  lua_newtable(L);
  lua_pushinteger(L, offsetof(struct s, a));
  lua_setfield(L, -2, "a");
  lua_pushinteger(L, offsetof(struct s, b));
  lua_setfield(L, -2, "b");
  lua_pushinteger(L, offsetof(struct s, s));
  lua_setfield(L, -2, "s");

  lua_setfield(L, -2, "s");
  lua_pop(L, 3);
}
static void lua_cn_push_runtime_metadata()
{
  // Sizes
  lua_cn_push_s_size();

  // Offsets
  lua_cn_push_s_offsets();
}
static signed int lua_cn_get_s()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct s* data = (struct s*) ptr;
  lua_cn_push_s(data);
  return 1;
}