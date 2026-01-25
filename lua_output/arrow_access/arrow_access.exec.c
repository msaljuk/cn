#define __CN_INSTRUMENT
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>
typedef __cerbty_intptr_t intptr_t;
typedef __cerbty_uintptr_t uintptr_t;
typedef __cerbty_intmax_t intmax_t;
typedef __cerbty_uintmax_t uintmax_t;
static const int __cerbvar_INT_MAX = 0x7fffffff;
static const int __cerbvar_INT_MIN = ~0x7fffffff;
static const unsigned long long __cerbvar_SIZE_MAX = ~(0ULL);
_Noreturn void abort(void);
/* ORIGINAL C STRUCTS AND UNIONS */

struct s {
  signed int x;
  signed int y;
};


/* CN VERSIONS OF C STRUCTS */

struct s_cn {
  cn_bits_i32* x;
  cn_bits_i32* y;
};



/* OWNERSHIP FUNCTIONS */

static struct s_cn* owned_struct_s(cn_pointer*, enum spec_mode, struct loop_ownership*);
/* CONVERSION FUNCTIONS */

/* GENERATED STRUCT FUNCTIONS */

static struct s_cn* default_struct_s_cn();
static void* cn_map_get_struct_s_cn(cn_map*, cn_integer*);
static cn_bool* struct_s_cn_equality(void*, void*);
static struct s convert_from_struct_s_cn(struct s_cn*);
static struct s_cn* convert_to_struct_s_cn(struct s);
/* RECORD FUNCTIONS */

/* CN FUNCTIONS */

static cn_bool* addr_eq(cn_pointer*, cn_pointer*);
static cn_bool* prov_eq(cn_pointer*, cn_pointer*);
static cn_bool* ptr_eq(cn_pointer*, cn_pointer*);
static cn_bool* is_null(cn_pointer*);
static cn_bool* not(cn_bool*);
static cn_bits_u8* MINu8();
static cn_bits_u8* MAXu8();
static cn_bits_u16* MINu16();
static cn_bits_u16* MAXu16();
static cn_bits_u32* MINu32();
static cn_bits_u32* MAXu32();
static cn_bits_u64* MINu64();
static cn_bits_u64* MAXu64();
static cn_bits_i8* MINi8();
static cn_bits_i8* MAXi8();
static cn_bits_i16* MINi16();
static cn_bits_i16* MAXi16();
static cn_bits_i32* MINi32();
static cn_bits_i32* MAXi32();
static cn_bits_i64* MINi64();
static cn_bits_i64* MAXi64();

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
#ifndef offsetof
#define offsetof(st, m) ((__cerbty_size_t)((char *)&((st *)0)->m - (char *)0))
#endif
#pragma GCC diagnostic ignored "-Wattributes"

/* GLOBAL ACCESSORS */
void* memcpy(void* dest, const void* src, __cerbty_size_t count );

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
  cn_bump_frame_id __cn_bump_count_a_667 = cn_bump_get_frame_id();
  ghost_stack_depth_incr();
  ghost_call_site = CLEARED;
  
  struct s origin = { .x = 0, .y = 0 };
c_add_to_ghost_state((&origin), sizeof(struct s), get_cn_stack_depth());


cn_pointer* origin_addr_cn = convert_to_cn_pointer((&origin));

  update_cn_error_message_info("  /*@ assert (origin.x == 0i32); @*/ // -- member\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:6-35");

struct s_cn* read_origin0 = convert_to_struct_s_cn(cn_pointer_deref(convert_to_cn_pointer((&origin)), struct s));

update_cn_error_message_info("  /*@ assert (origin.x == 0i32); @*/ // -- member\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:7-33");

update_cn_error_message_info("  /*@ assert (origin.x == 0i32); @*/ // -- member\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:7-33");

cn_assert(cn_bits_i32_equality(read_origin0->x, convert_to_cn_bits_i32(0LL)), STATEMENT);

cn_pop_msg_info();

cn_pop_msg_info();

cn_pop_msg_info();
 // -- member
  struct s *p = &origin;
c_add_to_ghost_state((&p), sizeof(struct s*), get_cn_stack_depth());


cn_pointer* p_addr_cn = convert_to_cn_pointer((&p));

  struct s *q = &origin;
c_add_to_ghost_state((&q), sizeof(struct s*), get_cn_stack_depth());


cn_pointer* q_addr_cn = convert_to_cn_pointer((&q));


  update_cn_error_message_info("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n     ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:6-31");

cn_pointer* read_p0 = convert_to_cn_pointer(cn_pointer_deref(convert_to_cn_pointer((&p)), struct s*));

struct s_cn* deref_read_p00 = convert_to_struct_s_cn(cn_pointer_deref(read_p0, struct s));

update_cn_error_message_info("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:7-29");

update_cn_error_message_info("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:7-29");

cn_assert(cn_bits_i32_equality(deref_read_p00->x, convert_to_cn_bits_i32(0LL)), STATEMENT);

cn_pop_msg_info();

cn_pop_msg_info();

cn_pop_msg_info();
 // Arrow access
  update_cn_error_message_info("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:6-33");

cn_pointer* read_p1 = convert_to_cn_pointer(cn_pointer_deref(convert_to_cn_pointer((&p)), struct s*));

struct s_cn* deref_read_p10 = convert_to_struct_s_cn(cn_pointer_deref(read_p1, struct s));

update_cn_error_message_info("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n      ^~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:7-31");

update_cn_error_message_info("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n      ^~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:7-31");

cn_assert(cn_bits_i32_equality(deref_read_p10->x, convert_to_cn_bits_i32(0LL)), STATEMENT);

cn_pop_msg_info();

cn_pop_msg_info();

cn_pop_msg_info();
 // ... desugared as this
  CN_STORE((*CN_LOAD(p)).y, 7);
  update_cn_error_message_info("  /*@ assert (q->y == 7i32); @*/\n     ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:6-31");

cn_pointer* read_q0 = convert_to_cn_pointer(cn_pointer_deref(convert_to_cn_pointer((&q)), struct s*));

struct s_cn* deref_read_q00 = convert_to_struct_s_cn(cn_pointer_deref(read_q0, struct s));

update_cn_error_message_info("  /*@ assert (q->y == 7i32); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:7-29");

update_cn_error_message_info("  /*@ assert (q->y == 7i32); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:7-29");

cn_assert(cn_bits_i32_equality(deref_read_q00->y, convert_to_cn_bits_i32(7LL)), STATEMENT);

cn_pop_msg_info();

cn_pop_msg_info();

cn_pop_msg_info();


c_remove_from_ghost_state((&origin), sizeof(struct s));


c_remove_from_ghost_state((&p), sizeof(struct s*));


c_remove_from_ghost_state((&q), sizeof(struct s*));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

{
  ghost_stack_depth_decr();
  cn_postcondition_leak_check();
}

  cn_bump_free_after(__cn_bump_count_a_667);
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
  cn_bump_frame_id __cn_bump_count_a_711 = cn_bump_get_frame_id();
  ghost_stack_depth_incr();
  cn_pointer* origin_cn = convert_to_cn_pointer(origin);
  ghost_call_site = CLEARED;
  update_cn_error_message_info("  take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:22:8:");
  struct s_cn* Or_cn = owned_struct_s(origin_cn, PRE, 0);
  cn_pop_msg_info();
  update_cn_error_message_info("  origin->y == 0i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:23:3-21");
  cn_assert(cn_bits_i32_equality(Or_cn->y, convert_to_cn_bits_i32(0LL)), PRE);
  cn_pop_msg_info();
  
	/* C OWNERSHIP */

  c_add_to_ghost_state((&origin), sizeof(struct s*), get_cn_stack_depth());
  cn_pointer* origin_addr_cn = convert_to_cn_pointer((&origin));
  
  CN_STORE(CN_LOAD(origin)->y, 7);

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  c_remove_from_ghost_state((&origin), sizeof(struct s*));

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

  cn_bump_free_after(__cn_bump_count_a_711);
}

/* RECORD */

/* CONVERSION */

/* GENERATED STRUCT FUNCTIONS */

static struct s_cn* default_struct_s_cn()
{
  struct s_cn* a_844 = (struct s_cn*) cn_bump_malloc(sizeof(struct s_cn));
  a_844->x = default_cn_bits_i32();
  a_844->y = default_cn_bits_i32();
  return a_844;
}
static void* cn_map_get_struct_s_cn(cn_map* m, cn_integer* key)
{
  void* ret = ht_get(m, (&key->val));
  if (0 == ret)
    return (void*) default_struct_s_cn();
  else
    return ret;
}
static cn_bool* struct_s_cn_equality(void* x, void* y)
{
  struct s_cn* x_cast = (struct s_cn*) x;
  struct s_cn* y_cast = (struct s_cn*) y;
  return cn_bool_and(cn_bool_and(convert_to_cn_bool(true), cn_bits_i32_equality(x_cast->x, y_cast->x)), cn_bits_i32_equality(x_cast->y, y_cast->y));
}
static struct s convert_from_struct_s_cn(struct s_cn* s)
{
  struct s res;
  res.x = convert_from_cn_bits_i32(s->x);
  res.y = convert_from_cn_bits_i32(s->y);
  return res;
}
static struct s_cn* convert_to_struct_s_cn(struct s s)
{
  struct s_cn* res = (struct s_cn*) cn_bump_malloc(sizeof(struct s_cn));
  res->x = convert_to_cn_bits_i32(s.x);
  res->y = convert_to_cn_bits_i32(s.y);
  return res;
}
/* OWNERSHIP FUNCTIONS */

/* OWNERSHIP FUNCTIONS */

static struct s_cn* owned_struct_s(cn_pointer* cn_ptr, enum spec_mode spec_mode, struct loop_ownership* loop_ownership)
{
  void* generic_c_ptr = (void*) (struct s*) cn_ptr->ptr;
  cn_get_or_put_ownership(spec_mode, generic_c_ptr, sizeof(struct s), loop_ownership);
  return convert_to_struct_s_cn((*(struct s*) cn_ptr->ptr));
}
/* CN FUNCTIONS */
static cn_bool* addr_eq(cn_pointer* arg1, cn_pointer* arg2)
{
  return cn_bits_u64_equality(cast_cn_pointer_to_cn_bits_u64(arg1), cast_cn_pointer_to_cn_bits_u64(arg2));
}
static cn_bool* prov_eq(cn_pointer* arg1, cn_pointer* arg2)
{
  return cn_alloc_id_equality(convert_to_cn_alloc_id(0), convert_to_cn_alloc_id(0));
}
static cn_bool* ptr_eq(cn_pointer* arg1, cn_pointer* arg2)
{
  return cn_pointer_equality(arg1, arg2);
}
static cn_bool* is_null(cn_pointer* arg)
{
  return cn_pointer_equality(arg, convert_to_cn_pointer(0));
}
static cn_bool* not(cn_bool* arg)
{
  return cn_bool_not(arg);
}
static cn_bits_u8* MINu8()
{
  return convert_to_cn_bits_u8(0UL);
}
static cn_bits_u8* MAXu8()
{
  return convert_to_cn_bits_u8(255UL);
}
static cn_bits_u16* MINu16()
{
  return convert_to_cn_bits_u16(0ULL);
}
static cn_bits_u16* MAXu16()
{
  return convert_to_cn_bits_u16(65535ULL);
}
static cn_bits_u32* MINu32()
{
  return convert_to_cn_bits_u32(0ULL);
}
static cn_bits_u32* MAXu32()
{
  return convert_to_cn_bits_u32(4294967295ULL);
}
static cn_bits_u64* MINu64()
{
  return convert_to_cn_bits_u64(0ULL);
}
static cn_bits_u64* MAXu64()
{
  return convert_to_cn_bits_u64(18446744073709551615ULL);
}
static cn_bits_i8* MINi8()
{
  return convert_to_cn_bits_i8((-127L - 1L));
}
static cn_bits_i8* MAXi8()
{
  return convert_to_cn_bits_i8(127L);
}
static cn_bits_i16* MINi16()
{
  return convert_to_cn_bits_i16((-32767LL - 1LL));
}
static cn_bits_i16* MAXi16()
{
  return convert_to_cn_bits_i16(32767LL);
}
static cn_bits_i32* MINi32()
{
  return convert_to_cn_bits_i32((-2147483647LL - 1LL));
}
static cn_bits_i32* MAXi32()
{
  return convert_to_cn_bits_i32(2147483647LL);
}
static cn_bits_i64* MINi64()
{
  return convert_to_cn_bits_i64((-9223372036854775807LL - 1LL));
}
static cn_bits_i64* MAXi64()
{
  return convert_to_cn_bits_i64(9223372036854775807LL);
}


/* CN PREDICATES */


/* CN LEMMAS */

