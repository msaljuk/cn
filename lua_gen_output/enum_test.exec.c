#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
# 1 "./lua_gen_output/enum_test.c"
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
# 1 "./lua_gen_output/enum_test.c" 2
# 1 "/Users/saljukgondal/.opam/5.2.0/lib/cerberus-lib/runtime/libc/include/assert.h" 1
// 7.2 Diagnostics<assert.h>

// 7.2.1 assert must be redefined each time
# 2 "./lua_gen_output/enum_test.c" 2

enum flags {
  flag_1 = 1,
  flag_4 = 4,
};

int flag_to_int(enum flags flag)
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret;
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&flag), sizeof(enum flags), lua_cn_get_stack_depth());
  
  switch (CN_LOAD(flag)) {
    case flag_1:
      { __cn_ret = 1; goto __cn_epilogue; }
    case flag_4:
      { __cn_ret = 4; goto __cn_epilogue; }
    default:
      ; // @note saljuk: Weird that the CN parser requires this, otherwise it thinks there's nothing here.
      /*@ assert(false); @*/ // <-- should be unreachable
      break;
  }

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&flag), sizeof(enum flags));

return __cn_ret;

}

int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./enum_test.lua", 0, 0, 0, 0, 0);
  
  (
({
  ghost_call_site = EMPTY;
  0;
})
, flag_to_int(flag_1));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_unload_runtime();

  lua_deinit();

return __cn_ret;

}

