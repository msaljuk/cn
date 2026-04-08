#include <lua_wrappers.h>
#include <cn-executable/utils.h>

#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct s {
  signed int a;
  signed int b;
  struct s* s;
};

struct q {
  signed int a;
  struct s b;
};

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_callme_push_frame(signed int, signed int*, signed int***, struct s, struct s*, struct s*, signed int*, struct q*, struct q);
static void lua_cn_callme_precondition();
static void lua_cn_callme_postcondition();
static void lua_cn_main_push_frame();
static void lua_cn_main_precondition();
static void lua_cn_main_postcondition();
static signed int lua_cn_push_q_size();
static signed int lua_cn_push_s_size();
static void lua_cn_push_q_offsets();
static void lua_cn_push_s_offsets();
static void lua_cn_push_q(struct q*);
static void lua_cn_push_s(struct s*);
static void lua_cn_push_runtime_metadata();
static signed int lua_cn_get_q();
static signed int lua_cn_get_s();

# 1 "./lua_gen_output/canonical_example.c"
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
# 1 "./lua_gen_output/canonical_example.c" 2
struct s;
struct q;

void callme(int a, int *b, int ***c, struct s s0, struct s *s1, struct s *s2, int *x, struct q* qp, struct q qs)
/*@
requires
    take bb   = Owned<int>(b);
    take s1_b = Owned<int>(member_shift<struct s>(s1, b));
    take ss2  = Owned(s2);
    take cc   = Owned(c);
    take ccc  = Owned(cc);
    take cccc = Owned(ccc);
    take y = Owned(x);
    take q = Owned(qp);
    a == 42i32;
    bb == 43i32;
    cccc == 44i32;
    s0.a == s0.b;
    s1_b == 45i32;
    ss2.a == ss2.b;
    y == 5i32;
    q.a == 0i32;
ensures
    take bb_   = Owned<int>(b);
    take s1_b_ = Owned<int>(member_shift<struct s>(s1, b));
    take ss2_  = Owned(s2);
    take cc_   = Owned(c);
    take ccc_  = Owned(cc_);
    take cccc_ = Owned(ccc);
    take y_ = Owned(x);
    take q_ = Owned(qp);
    a == 42i32;
    bb_ == 43i32;
    cccc_ == 44i32;
    s0.a == s0.b;
    s1_b_ == 45i32;
    ss2_.a == ss2.b;
    y_ == 5i32;
    q_.a == 0i32;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_callme_push_frame(a, b, c, s0, s1, s2, x, qp, qs);
  lua_cn_callme_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&a), sizeof(signed int), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&b), sizeof(signed int*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&c), sizeof(signed int***), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&s0), sizeof(struct s), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&s1), sizeof(struct s*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&s2), sizeof(struct s*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&x), sizeof(signed int*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&qp), sizeof(struct q*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&qs), sizeof(struct q), lua_cn_get_stack_depth());
  
    int xxx = 1;
lua_cn_ghost_add((&xxx), sizeof(signed int), lua_cn_get_stack_depth());


lua_cn_ghost_remove((&xxx), sizeof(signed int));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&a), sizeof(signed int));

  lua_cn_ghost_remove((&b), sizeof(signed int*));

  lua_cn_ghost_remove((&c), sizeof(signed int***));

  lua_cn_ghost_remove((&s0), sizeof(struct s));

  lua_cn_ghost_remove((&s1), sizeof(struct s*));

  lua_cn_ghost_remove((&s2), sizeof(struct s*));

  lua_cn_ghost_remove((&x), sizeof(signed int*));

  lua_cn_ghost_remove((&qp), sizeof(struct q*));

  lua_cn_ghost_remove((&qs), sizeof(struct q));

  lua_cn_callme_postcondition();

  lua_cn_frame_pop_function();
}


int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./lua_gen_output/gen/canonical_example.lua", 0, 1, 1024, 0, 0);
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


    int x = 5;
lua_cn_ghost_add((&x), sizeof(signed int), lua_cn_get_stack_depth());


    struct q q = { .a = 0 };
lua_cn_ghost_add((&q), sizeof(struct q), lua_cn_get_stack_depth());


    struct q s = { .a = 5 };
lua_cn_ghost_add((&s), sizeof(struct q), lua_cn_get_stack_depth());


    (
({
  ghost_call_site = EMPTY;
  0;
})
, callme(CN_LOAD(a), CN_LOAD(b), CN_LOAD(c), CN_LOAD(s0), CN_LOAD(s1), CN_LOAD(s2), &x, &q, CN_LOAD(s)));

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


lua_cn_ghost_remove((&x), sizeof(signed int));


lua_cn_ghost_remove((&q), sizeof(struct q));


lua_cn_ghost_remove((&s), sizeof(struct q));
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


lua_cn_ghost_remove((&x), sizeof(signed int));


lua_cn_ghost_remove((&q), sizeof(struct q));


lua_cn_ghost_remove((&s), sizeof(struct q));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_unload_runtime();

  lua_deinit();

return __cn_ret;

}


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_callme_push_frame(signed int a, signed int* b, signed int*** c, struct s s0, struct s* s1, struct s* s2, signed int* x, struct q* qp, struct q qs)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "callme");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, a);
  lua_pushinteger(L, lua_convert_ptr_to_int(b));
  lua_pushinteger(L, lua_convert_ptr_to_int(c));
  lua_cn_push_s((&s0));
  lua_pushinteger(L, lua_convert_ptr_to_int(s1));
  lua_pushinteger(L, lua_convert_ptr_to_int(s2));
  lua_pushinteger(L, lua_convert_ptr_to_int(x));
  lua_pushinteger(L, lua_convert_ptr_to_int(qp));
  lua_cn_push_q((&qs));
  lua_pcall(L, 9, 0, 0);
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
static signed int lua_cn_push_q_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct q));
  lua_setfield(L, -2, "q");
  lua_pop(L, 3);
  return 1;
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
static void lua_cn_push_q_offsets()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "offsets");
  lua_newtable(L);
  lua_pushinteger(L, offsetof(struct q, a));
  lua_setfield(L, -2, "a");
  lua_pushinteger(L, offsetof(struct q, b));
  lua_setfield(L, -2, "b");
  lua_setfield(L, -2, "q");
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
static void lua_cn_push_q(struct q* data)
{
  struct lua_State* L = lua_get_state();
  lua_newtable(L);
  lua_pushinteger(L, data->a);
  lua_setfield(L, -2, "a");
  lua_cn_push_s((&data->b));
  lua_setfield(L, -2, "b");
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
static void lua_cn_push_runtime_metadata()
{
  {
    lua_cn_register_c_func("get_s", lua_cn_get_s);
    lua_cn_register_c_func("get_q", lua_cn_get_q);
  }
  {
    lua_cn_push_s_size();
    lua_cn_push_q_size();
  }
  {
    lua_cn_push_s_offsets();
    lua_cn_push_q_offsets();
  }
}
static signed int lua_cn_get_q()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct q* data = (struct q*) ptr;
  lua_cn_push_q(data);
  return 1;
}
static signed int lua_cn_get_s()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct s* data = (struct s*) ptr;
  lua_cn_push_s(data);
  return 1;
}

