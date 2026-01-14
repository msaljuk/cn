#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

void lua_cn_divison_precondition(unsigned int* x, int* y);
void lua_cn_divison_postcondition(unsigned int* ret);

/* Integer promotions in divisions are subtle. The result of a division will be the larger type,
according to the following hierarchy `iN <: uN` and `uN <: i(2N)`  (and of course `iN <: i(2N)` and `uN <: u2N`).

Important: (1) signed integers must be non-negative to convert to unsigned (2) if one of the operands
is unsigned, the result will be unsigned, so any signed values must be non-negative. */

unsigned int division(unsigned int x, int y)
/*@ requires y > 0i32;
    ensures return == x/(u32)y; @*/
{
  lua_cn_frame_push_function();

  unsigned int __cn_ret;

  /* EXECUTABLE CN PRECONDITION */
  lua_cn_divison_precondition(&x, &y);
  
	/* C OWNERSHIP */
  lua_cn_ghost_add((&x), sizeof(unsigned int), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&y), sizeof(signed int), lua_cn_get_stack_depth());
  
  __cn_ret = CN_LOAD(x)/CN_LOAD(y);
  
	/* C OWNERSHIP */
  lua_cn_ghost_remove((&x), sizeof(unsigned int));
  lua_cn_ghost_remove((&y), sizeof(signed int));

  lua_cn_divison_postcondition(&__cn_ret);

  lua_cn_frame_pop_function();

  return __cn_ret;
}

int main(void)
{
  signed int __ret;

  lua_init();
  lua_cn_load_runtime("./lua_output/division_casting/division_casting.lua", 0, 0, 0, 0, 0);

  unsigned int x = 5;
  lua_cn_ghost_add((&x), sizeof(unsigned int), lua_cn_get_stack_depth());

  int y = 3;
  lua_cn_ghost_add((&y), sizeof(signed int), lua_cn_get_stack_depth());

  unsigned int z = division(CN_LOAD(x), CN_LOAD(y));
  lua_cn_ghost_add((&z), sizeof(unsigned int), lua_cn_get_stack_depth());

  lua_cn_ghost_remove((&x), sizeof(unsigned int));
  lua_cn_ghost_remove((&y), sizeof(signed int));
  lua_cn_ghost_remove((&z), sizeof(unsigned int));

  lua_cn_unload_runtime();
  lua_deinit();

  return __ret;
}

void lua_cn_divison_precondition(unsigned int* x, int* y) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "divison");
  lua_getfield(L, -1, "precondition");

  lua_pushinteger(L, lua_convert_ptr_to_int(x));
  lua_pushinteger(L, lua_convert_ptr_to_int(y));

  if (lua_pcall(L, 2, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling divison.precondition: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}

void lua_cn_divison_postcondition(unsigned int* ret) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "divison");
  lua_getfield(L, -1, "postcondition");

  lua_pushinteger(L, lua_convert_ptr_to_int(ret));

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling CN.divison.postcondition: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}
