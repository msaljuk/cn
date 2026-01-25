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


/* CN VERSIONS OF C STRUCTS */



/* OWNERSHIP FUNCTIONS */

/* CONVERSION FUNCTIONS */

/* GENERATED STRUCT FUNCTIONS */

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

static void Is_Known_Binop(cn_pointer*, enum spec_mode, struct loop_ownership*);
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

# 1 "./tests/cn/fun_ptr_extern.c"
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
# 1 "./tests/cn/fun_ptr_extern.c" 2

int
f1 (int x, int y) {
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret;
  
	/* C OWNERSHIP */

  c_add_to_ghost_state((&x), sizeof(signed int), get_cn_stack_depth());
  cn_pointer* x_addr_cn = convert_to_cn_pointer((&x));
  c_add_to_ghost_state((&y), sizeof(signed int), get_cn_stack_depth());
  cn_pointer* y_addr_cn = convert_to_cn_pointer((&y));
  
  if (CN_LOAD(x) > CN_LOAD(y)) {
    { __cn_ret = CN_LOAD(x) - 1; goto __cn_epilogue; }
  }
  else {
    { __cn_ret = CN_LOAD(y); goto __cn_epilogue; }
  }

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  c_remove_from_ghost_state((&x), sizeof(signed int));

  c_remove_from_ghost_state((&y), sizeof(signed int));

return __cn_ret;

}

extern int f2 (int x, int y);
/*@
spec f2 (i32 x, i32 y);
  requires true;
  ensures true;
@*/

typedef int int_binop1 (int, int);

typedef int_binop1 *int_binop;

int_binop g1 = f2;

/*@
predicate (void) Is_Known_Binop (pointer f) {
  assert (ptr_eq(f, &f1) || ptr_eq(f, &f2));
  return;
}
@*/

int_binop
get_int_binop (int x)
/*@ ensures take X = Is_Known_Binop (return); @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int (* __cn_ret) (signed int, signed int);
  cn_bump_frame_id __cn_bump_count_a_696 = cn_bump_get_frame_id();
  ghost_stack_depth_incr();
  cn_bits_i32* x_cn = convert_to_cn_bits_i32(x);
  ghost_call_site = CLEARED;
  
	/* C OWNERSHIP */

  c_add_to_ghost_state((&x), sizeof(signed int), get_cn_stack_depth());
  cn_pointer* x_addr_cn = convert_to_cn_pointer((&x));
  
  if (CN_LOAD(x) == 0) {
    { __cn_ret = f1; goto __cn_epilogue; }
  }
  else {
    { __cn_ret = f2; goto __cn_epilogue; }
  }

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  c_remove_from_ghost_state((&x), sizeof(signed int));

{
  cn_pointer* return_cn = convert_to_cn_pointer(__cn_ret);
  update_cn_error_message_info("/*@ ensures take X = Is_Known_Binop (return); @*/\n                 ^./tests/cn/fun_ptr_extern.c:34:18:");
  Is_Known_Binop(return_cn, POST, 0);
  cn_pop_msg_info();
  ghost_stack_depth_decr();
  cn_postcondition_leak_check();
}

  cn_bump_free_after(__cn_bump_count_a_696);

return __cn_ret;

}

int
call_site (int x, int y) {
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret;
  cn_bump_frame_id __cn_bump_count_a_736 = cn_bump_get_frame_id();
  ghost_stack_depth_incr();
  cn_bits_i32* x_cn = convert_to_cn_bits_i32(x);
  cn_bits_i32* y_cn = convert_to_cn_bits_i32(y);
  ghost_call_site = CLEARED;
  
	/* C OWNERSHIP */

  c_add_to_ghost_state((&x), sizeof(signed int), get_cn_stack_depth());
  cn_pointer* x_addr_cn = convert_to_cn_pointer((&x));
  c_add_to_ghost_state((&y), sizeof(signed int), get_cn_stack_depth());
  cn_pointer* y_addr_cn = convert_to_cn_pointer((&y));
  
  int_binop g2;
c_add_to_ghost_state((&g2), sizeof(signed int (*) (signed int, signed int)), get_cn_stack_depth());


cn_pointer* g2_addr_cn = convert_to_cn_pointer((&g2));

  int z;
c_add_to_ghost_state((&z), sizeof(signed int), get_cn_stack_depth());


cn_pointer* z_addr_cn = convert_to_cn_pointer((&z));


  CN_STORE(g2, (
({
  ghost_call_site = EMPTY;
  0;
})
, get_int_binop(CN_LOAD(y))));
  update_cn_error_message_info("  /*@ split_case (ptr_eq (g2, &f1)); @*/\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/fun_ptr_extern.c:50:6-39");

cn_pop_msg_info();

  CN_STORE(z, (
({
  ghost_call_site = EMPTY;
  0;
})
, CN_LOAD(g2) (CN_LOAD(x), CN_LOAD(y))));

  { __cn_ret = CN_LOAD(z); 
c_remove_from_ghost_state((&g2), sizeof(signed int (*) (signed int, signed int)));


c_remove_from_ghost_state((&z), sizeof(signed int));
goto __cn_epilogue; }

c_remove_from_ghost_state((&g2), sizeof(signed int (*) (signed int, signed int)));


c_remove_from_ghost_state((&z), sizeof(signed int));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  c_remove_from_ghost_state((&x), sizeof(signed int));

  c_remove_from_ghost_state((&y), sizeof(signed int));

{
  cn_bits_i32* return_cn = convert_to_cn_bits_i32(__cn_ret);
  ghost_stack_depth_decr();
  cn_postcondition_leak_check();
}

  cn_bump_free_after(__cn_bump_count_a_736);

return __cn_ret;

}

int main(void)
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  initialise_ownership_ghost_state();
  initialise_ghost_stack_depth();
  alloc_ghost_array(0);
  initialise_exec_c_locs_mode(0);
  initialise_ownership_stack_mode(0);
  c_add_to_ghost_state((&g1), sizeof(signed int (*) (signed int, signed int)), get_cn_stack_depth());
  
  int r = (
({
  ghost_call_site = EMPTY;
  0;
})
, call_site(5, 42));
c_add_to_ghost_state((&r), sizeof(signed int), get_cn_stack_depth());


cn_pointer* r_addr_cn = convert_to_cn_pointer((&r));


c_remove_from_ghost_state((&r), sizeof(signed int));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  c_remove_from_ghost_state((&g1), sizeof(signed int (*) (signed int, signed int)));

  free_ghost_array();

return __cn_ret;

}

/* RECORD */

/* CONVERSION */

/* GENERATED STRUCT FUNCTIONS */

/* OWNERSHIP FUNCTIONS */

/* OWNERSHIP FUNCTIONS */

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

static void Is_Known_Binop(cn_pointer* f, enum spec_mode spec_mode, struct loop_ownership* loop_ownership)
{
  update_cn_error_message_info("  assert (ptr_eq(f, &f1) || ptr_eq(f, &f2));\n  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/fun_ptr_extern.c:27:3-28:9");
  cn_assert(cn_bool_or(ptr_eq(f, f1), ptr_eq(f, f2)), spec_mode);
  cn_pop_msg_info();
  return;
}

/* CN LEMMAS */

