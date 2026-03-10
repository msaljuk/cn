#include <lua_wrappers.h>
#include <cn-executable/utils.h>

#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_acquire_random_integer_pointer_push_frame(signed int**);
static void lua_cn_acquire_random_integer_pointer_precondition();
static void lua_cn_acquire_random_integer_pointer_postcondition();

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
void acquire_random_integer_pointer (int *random)
/*@
requires
  take Or = RW<int>(random);
  *random == 0i32;
@*/
{
  /* EXECUTABLE CN PRECONDITION */
  lua_cn_acquire_random_integer_pointer_push_frame((&random));
  lua_cn_acquire_random_integer_pointer_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&random), sizeof(signed int*), lua_cn_get_stack_depth());
  

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&random), sizeof(signed int*));

  lua_cn_acquire_random_integer_pointer_postcondition();

  lua_cn_frame_pop_function();
}


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_acquire_random_integer_pointer_push_frame(signed int** random_addr)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "acquire_random_integer_pointer");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(random_addr));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_acquire_random_integer_pointer_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "acquire_random_integer_pointer");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_acquire_random_integer_pointer_postcondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "acquire_random_integer_pointer");
  lua_getfield(L, -1, "postcondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}

