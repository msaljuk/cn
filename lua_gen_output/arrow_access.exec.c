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
lua_State* L;
/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_arrow_access_1_push_frame();
static void lua_cn_arrow_access_1_precondition();
static void lua_cn_arrow_access_1_postcondition();
static void lua_cn_arrow_access_2_push_frame(struct s**);
static void lua_cn_arrow_access_2_precondition();
static void lua_cn_arrow_access_2_postcondition();
static void lua_cn_arrow_access_3_dummy_example_by_saljuk_push_frame(struct s**, signed int*, signed int**);
static void lua_cn_arrow_access_3_dummy_example_by_saljuk_precondition();
static void lua_cn_arrow_access_3_dummy_example_by_saljuk_postcondition();

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

  update_cn_error_message_info("  /*@ assert (origin.x == 0i32); @*/ // -- member\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:6-35");

struct s_cn* read_origin0 = convert_to_struct_s_cn(cn_pointer_deref(convert_to_cn_pointer((&origin)), struct s));

update_cn_error_message_info("  /*@ assert (origin.x == 0i32); @*/ // -- member\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:7-33");

cn_pop_msg_info();

cn_pop_msg_info();
 // -- member
  struct s *p = &origin;
lua_cn_ghost_add((&p), sizeof(struct s*), lua_cn_get_stack_depth());

  struct s *q = &origin;
lua_cn_ghost_add((&q), sizeof(struct s*), lua_cn_get_stack_depth());


  update_cn_error_message_info("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n     ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:6-31");

cn_pointer* read_p0 = convert_to_cn_pointer(cn_pointer_deref(convert_to_cn_pointer((&p)), struct s*));

struct s_cn* deref_read_p00 = convert_to_struct_s_cn(cn_pointer_deref(read_p0, struct s));

update_cn_error_message_info("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:7-29");

cn_pop_msg_info();

cn_pop_msg_info();
 // Arrow access
  update_cn_error_message_info("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:6-33");

cn_pointer* read_p1 = convert_to_cn_pointer(cn_pointer_deref(convert_to_cn_pointer((&p)), struct s*));

struct s_cn* deref_read_p10 = convert_to_struct_s_cn(cn_pointer_deref(read_p1, struct s));

update_cn_error_message_info("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n      ^~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:7-31");

cn_pop_msg_info();

cn_pop_msg_info();
 // ... desugared as this
  CN_STORE((*CN_LOAD(p)).y, 7);
  update_cn_error_message_info("  /*@ assert (q->y == 7i32); @*/\n     ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:6-31");

cn_pointer* read_q0 = convert_to_cn_pointer(cn_pointer_deref(convert_to_cn_pointer((&q)), struct s*));

struct s_cn* deref_read_q00 = convert_to_struct_s_cn(cn_pointer_deref(read_q0, struct s));

update_cn_error_message_info("  /*@ assert (q->y == 7i32); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:7-29");

cn_pop_msg_info();

cn_pop_msg_info();


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
  lua_cn_arrow_access_2_push_frame((&origin));
  lua_cn_arrow_access_2_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&origin), sizeof(struct s*), lua_cn_get_stack_depth());
  
  CN_STORE(CN_LOAD(origin)->y, 7);

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&origin), sizeof(struct s*));

  lua_cn_arrow_access_2_postcondition();

  lua_cn_frame_pop_function();
}

/* Same as arrow_access_2 but with added parameters to test frame push */
void arrow_access_3_dummy_example_by_saljuk (struct s *origin, int x, int* y)
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
  lua_cn_arrow_access_3_dummy_example_by_saljuk_push_frame((&origin), (&x), (&y));
  lua_cn_arrow_access_3_dummy_example_by_saljuk_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&origin), sizeof(struct s*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&x), sizeof(signed int), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&y), sizeof(signed int*), lua_cn_get_stack_depth());
  
  CN_STORE(CN_LOAD(origin)->y, 7);

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&origin), sizeof(struct s*));

  lua_cn_ghost_remove((&x), sizeof(signed int));

  lua_cn_ghost_remove((&y), sizeof(signed int*));

  lua_cn_arrow_access_3_dummy_example_by_saljuk_postcondition();

  lua_cn_frame_pop_function();
}


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_arrow_access_1_push_frame()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "push_frame");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_1_precondition()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_1_postcondition()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_2_push_frame(struct s** origin_addr)
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(origin_addr));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_2_precondition()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_2_postcondition()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_3_dummy_example_by_saljuk_push_frame(struct s** origin_addr, signed int* x_addr, signed int** y_addr)
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_3_dummy_example_by_saljuk");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(origin_addr));
  lua_pushinteger(L, lua_convert_ptr_to_int(x_addr));
  lua_pushinteger(L, lua_convert_ptr_to_int(y_addr));
  lua_pcall(L, 3, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_3_dummy_example_by_saljuk_precondition()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_3_dummy_example_by_saljuk");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_arrow_access_3_dummy_example_by_saljuk_postcondition()
{
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_3_dummy_example_by_saljuk");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}

