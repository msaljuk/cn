#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

int f1 (int x, int y) {
  signed int __cn_ret;
  
  /* C OWNERSHIP */
  lua_cn_ghost_add((&x), sizeof(signed int), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&y), sizeof(signed int), lua_cn_get_stack_depth());
  
  if (CN_LOAD(x) > CN_LOAD(y)) {
    __cn_ret = CN_LOAD(x) - 1;
  }
  else {
    __cn_ret = CN_LOAD(y);
  }
  
  /* C OWNERSHIP */
  lua_cn_ghost_remove((&x), sizeof(signed int));
  lua_cn_ghost_remove((&y), sizeof(signed int));

  return __cn_ret;
}

extern int f2 (int x, int y);
/*@
spec f2 (i32 x, i32 y);
  requires true;
  ensures true;
@*/

// FOR TESTING, ADDING DUMMY IMPLEMENTATION OF f2 so that linking succeeds
int f2(int x, int y) {
    return x + y;
}

typedef int int_binop1 (int, int);

typedef int_binop1 *int_binop;

int_binop g1 = f2;

/*@
predicate (void) Is_Known_Binop (pointer f) {
  assert (ptr_eq(f, &f1) || ptr_eq(f, &f2));
  return;
}
@*/

void lua_cn_get_int_binop_postcondition(int_binop ptr);

int_binop get_int_binop (int x)
/*@ ensures take X = Is_Known_Binop (return); @*/
{
  lua_cn_frame_push_function();

  /* EXECUTABLE CN PRECONDITION */
  signed int (* __cn_ret) (signed int, signed int);
  
  /* C OWNERSHIP */
  lua_cn_ghost_add((&x), sizeof(signed int), lua_cn_get_stack_depth());
  
  if (CN_LOAD(x) == 0) {
    __cn_ret = f1;
  }
  else {
    __cn_ret = f2;
  }

  /* C OWNERSHIP */
  lua_cn_ghost_remove((&x), sizeof(signed int));

  /** CN POSTCONDITION */
  lua_cn_get_int_binop_postcondition(__cn_ret);

  lua_cn_frame_pop_function();

  return __cn_ret;
}

int call_site (int x, int y) {
  lua_cn_frame_push_function();

  signed int __cn_ret;
  
  /* C OWNERSHIP */
  lua_cn_ghost_add((&x), sizeof(signed int), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&y), sizeof(signed int), lua_cn_get_stack_depth());
  
  int_binop g2;
  lua_cn_ghost_add((&g2), sizeof(signed int (*) (signed int, signed int)), lua_cn_get_stack_depth());

  int z;
  lua_cn_ghost_add((&z), sizeof(signed int), lua_cn_get_stack_depth());

  CN_STORE(g2, (get_int_binop(CN_LOAD(y))));

  // I don't quite understand this section. What does split_case mean here?
  update_cn_error_message_info("  /*@ split_case (ptr_eq (g2, &f1)); @*/\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/fun_ptr_extern.c:50:6-39");
  cn_pop_msg_info();

  CN_STORE(z, CN_LOAD(g2) (CN_LOAD(x), CN_LOAD(y)));

  __cn_ret = CN_LOAD(z); 

  lua_cn_ghost_remove((&g2), sizeof(signed int (*) (signed int, signed int)));
  lua_cn_ghost_remove((&z), sizeof(signed int));
  lua_cn_ghost_remove((&g2), sizeof(signed int (*) (signed int, signed int)));
  lua_cn_ghost_remove((&z), sizeof(signed int));
  lua_cn_ghost_remove((&x), sizeof(signed int));
  lua_cn_ghost_remove((&y), sizeof(signed int));

  lua_cn_frame_pop_function();

  return __cn_ret;
}

int main(void)
{
  signed int __cn_ret = 0;
  
  lua_init();
  lua_cn_load_runtime("./lua_output/fun_ptr_extern/fun_ptr_extern.lua");
  
  lua_cn_ghost_add((&g1), sizeof(signed int (*) (signed int, signed int)), lua_cn_get_stack_depth());

  int r = call_site(5, 42);
  lua_cn_ghost_add((&r), sizeof(signed int), lua_cn_get_stack_depth());

  lua_cn_ghost_remove((&r), sizeof(signed int));
  lua_cn_ghost_remove((&g1), sizeof(signed int (*) (signed int, signed int)));

  lua_cn_unload_runtime();
  lua_deinit();

  return __cn_ret;
}

void lua_cn_get_int_binop_postcondition(int_binop ret) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "get_int_binop");
  lua_getfield(L, -1, "postcondition");

  lua_pushinteger(L, lua_convert_ptr_to_int(ret));
  lua_pushinteger(L, lua_convert_ptr_to_int(f1));
  lua_pushinteger(L, lua_convert_ptr_to_int(f2));

  if (lua_pcall(L, 3, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling CN.get_int_binop.postcondition: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}
