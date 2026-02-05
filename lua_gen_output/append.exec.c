#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct int_list {
  signed int head;
  struct int_list* tail;
};

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
# 1 "./tests/cn/append.c"
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
# 1 "./tests/cn/append.c" 2
struct int_list;



struct int_list* IntList_append(struct int_list* xs, struct int_list* ys)
/*@ requires take L1 = IntList(xs);
             take L2 = IntList(ys);
    ensures take L3 = IntList(return);
            L3 == append(L1, L2); @*/
{
  /* EXECUTABLE CN PRECONDITION */
  struct int_list* __cn_ret;
  lua_cn_frame_push_function();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&xs), sizeof(struct int_list*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&ys), sizeof(struct int_list*), lua_cn_get_stack_depth());
  
  if (CN_LOAD(xs) == 0) {
    /*@ unfold append(L1, L2); @*/
    { __cn_ret = CN_LOAD(ys); goto __cn_epilogue; }
  } else {
    /*@ unfold append(L1, L2); @*/
    struct int_list *new_tail = (
({
  ghost_call_site = EMPTY;
  0;
})
, IntList_append(CN_LOAD(CN_LOAD(xs)->tail), CN_LOAD(ys)));
lua_cn_ghost_add((&new_tail), sizeof(struct int_list*), lua_cn_get_stack_depth());

    CN_STORE(CN_LOAD(xs)->tail, CN_LOAD(new_tail));
    { __cn_ret = CN_LOAD(xs); 
lua_cn_ghost_remove((&new_tail), sizeof(struct int_list*));
goto __cn_epilogue; }
  
lua_cn_ghost_remove((&new_tail), sizeof(struct int_list*));
}

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&xs), sizeof(struct int_list*));

  lua_cn_ghost_remove((&ys), sizeof(struct int_list*));

  lua_cn_frame_pop_function();

return __cn_ret;

}

int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./append.lua", 0, 0, 0, 0, 0);
  
  struct int_list i1 = {.head = 2, .tail = 0};
lua_cn_ghost_add((&i1), sizeof(struct int_list), lua_cn_get_stack_depth());

  struct int_list i3 = {.head = 4, .tail = 0};
lua_cn_ghost_add((&i3), sizeof(struct int_list), lua_cn_get_stack_depth());

  struct int_list i2 = {.head = 3, .tail = &i3};
lua_cn_ghost_add((&i2), sizeof(struct int_list), lua_cn_get_stack_depth());


  struct int_list *il3 = (
({
  ghost_call_site = EMPTY;
  0;
})
, IntList_append(&i1, &i2));
lua_cn_ghost_add((&il3), sizeof(struct int_list*), lua_cn_get_stack_depth());


lua_cn_ghost_remove((&i1), sizeof(struct int_list));


lua_cn_ghost_remove((&i3), sizeof(struct int_list));


lua_cn_ghost_remove((&i2), sizeof(struct int_list));


lua_cn_ghost_remove((&il3), sizeof(struct int_list*));

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  lua_cn_unload_runtime();

  lua_deinit();

return __cn_ret;

}

