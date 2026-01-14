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

static cn_bits_i32* owned_signed_int(cn_pointer*, enum spec_mode, struct loop_ownership*);
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

# 1 "./tests/cn/forloop_with_decl.c"
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
# 1 "./tests/cn/forloop_with_decl.c" 2
int for_with_decl()
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret;
  cn_bump_frame_id __cn_bump_count_a_616 = cn_bump_get_frame_id();
  ghost_stack_depth_incr();
  ghost_call_site = CLEARED;
  
  int acc = 0;
c_add_to_ghost_state((&acc), sizeof(signed int), get_cn_stack_depth());


cn_pointer* acc_addr_cn = convert_to_cn_pointer((&acc));

  {
cn_bump_frame_id __cn_bump_count_a_610;

struct loop_ownership* a_582;

cn_bits_i32* O_i3;

cn_bits_i32* O_acc3;
for(
signed int i = c_add_to_ghost_state((&i), sizeof(signed int), get_cn_stack_depth()), 0;
 ({
  __cn_bump_count_a_610 = cn_bump_get_frame_id();
  a_582 = initialise_loop_ownership_state();
  update_cn_error_message_info("  for(int i = 0; i < 10; i++)\n  ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:4:3-9:4");
  O_i3 = owned_signed_int(i_addr_cn, LOOP, a_582);
  cn_pop_msg_info();
  update_cn_error_message_info("  for(int i = 0; i < 10; i++)\n  ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:4:3-9:4");
  O_acc3 = owned_signed_int(acc_addr_cn, LOOP, a_582);
  cn_pop_msg_info();
  update_cn_error_message_info("  /*@ inv 0i32 <= i; i <= 10i32;\n          ^~~~~~~~~~ ./tests/cn/forloop_with_decl.c:5:11-21");
  cn_assert(cn_bits_i32_le(convert_to_cn_bits_i32(0LL), O_i3), LOOP);
  cn_pop_msg_info();
  update_cn_error_message_info("  /*@ inv 0i32 <= i; i <= 10i32;\n                     ^~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:5:22-33");
  cn_assert(cn_bits_i32_le(O_i3, convert_to_cn_bits_i32(10LL)), LOOP);
  cn_pop_msg_info();
  update_cn_error_message_info("          acc <= 10i32; @*/\n          ^~~~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:6:11-24");
  cn_assert(cn_bits_i32_le(O_acc3, convert_to_cn_bits_i32(10LL)), LOOP);
  cn_pop_msg_info();
  cn_loop_put_back_ownership(a_582);
  0;
})
, CN_LOAD(i) < 10; CN_POSTFIX(i, ++))
  /*@ inv 0i32 <= i; i <= 10i32;
          acc <= 10i32; @*/
  {
    CN_STORE(acc, CN_LOAD(i));
  cn_bump_free_after(__cn_bump_count_a_610);
}cn_bump_free_after(__cn_bump_count_a_610);

};
  { __cn_ret = CN_LOAD(acc); 
c_remove_from_ghost_state((&acc), sizeof(signed int));
goto __cn_epilogue; }

c_remove_from_ghost_state((&acc), sizeof(signed int));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

{
  cn_bits_i32* return_cn = convert_to_cn_bits_i32(__cn_ret);
  ghost_stack_depth_decr();
  cn_postcondition_leak_check();
}

  cn_bump_free_after(__cn_bump_count_a_616);

return __cn_ret;

}

int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  initialise_ownership_ghost_state();
  initialise_ghost_stack_depth();
  alloc_ghost_array(0);
  initialise_exec_c_locs_mode(0);
  initialise_ownership_stack_mode(0);
  
  int r = (
({
  ghost_call_site = EMPTY;
  0;
})
, for_with_decl());
c_add_to_ghost_state((&r), sizeof(signed int), get_cn_stack_depth());


cn_pointer* r_addr_cn = convert_to_cn_pointer((&r));


c_remove_from_ghost_state((&r), sizeof(signed int));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  free_ghost_array();

return __cn_ret;

}

/* RECORD */

/* CONVERSION */

/* GENERATED STRUCT FUNCTIONS */

/* OWNERSHIP FUNCTIONS */

/* OWNERSHIP FUNCTIONS */

static cn_bits_i32* owned_signed_int(cn_pointer* cn_ptr, enum spec_mode spec_mode, struct loop_ownership* loop_ownership)
{
  void* generic_c_ptr = (void*) (signed int*) cn_ptr->ptr;
  cn_get_or_put_ownership(spec_mode, generic_c_ptr, sizeof(signed int), loop_ownership);
  return convert_to_cn_bits_i32((*(signed int*) cn_ptr->ptr));
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

