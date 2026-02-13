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
  lua_cn_frame_push_function_arrow_access_1();
  ghost_call_site = CLEARED;
  
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

{
  ghost_stack_depth_decr();
  cn_postcondition_leak_check();
}

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
  lua_cn_frame_push_function_arrow_access_2((&origin));
  cn_pointer* origin_cn = convert_to_cn_pointer(origin);
  ghost_call_site = CLEARED;
  update_cn_error_message_info("  take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:22:8:");
  struct s_cn* Or_cn = owned_struct_s(origin_cn, PRE, 0);
  cn_pop_msg_info();
  update_cn_error_message_info("  origin->y == 0i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:23:3-21");
  cn_assert(cn_bits_i32_equality(Or_cn->y, convert_to_cn_bits_i32(0LL)), PRE);
  cn_pop_msg_info();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&origin), sizeof(struct s*), lua_cn_get_stack_depth());
  
  CN_STORE(CN_LOAD(origin)->y, 7);

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&origin), sizeof(struct s*));

{
  update_cn_error_message_info("  take Or_ = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:25:8:");
  struct s_cn* Or__cn = owned_struct_s(origin_cn, POST, 0);
  cn_pop_msg_info();
  update_cn_error_message_info("  origin->y == 7i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:26:3-21");
  cn_assert(cn_bits_i32_equality(Or__cn->y, convert_to_cn_bits_i32(7LL)), POST);
  cn_pop_msg_info();
  update_cn_error_message_info("  (*origin).y == 7i32;\n  ^~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:27:3-23");
  cn_assert(cn_bits_i32_equality(Or__cn->y, convert_to_cn_bits_i32(7LL)), POST);
  cn_pop_msg_info();
  ghost_stack_depth_decr();
  cn_postcondition_leak_check();
}

  lua_cn_frame_pop_function();
}

