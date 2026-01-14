#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

/*@
function (boolean) bw_compl_expr() {
    let x = 2i32;
    ~(x+x) == -5i32
}
@*/

void lua_cn_main_assert_a();
void lua_cn_main_assert_b();
void lua_cn_main_assert_c(int y);

int main()
{
  signed int ret = 0;

  lua_init();
  lua_cn_load_runtime("./lua_output/bitwise-compl/bitwise_compl.lua");

  lua_cn_frame_push();

  /*@ assert (~0i32 == -1i32); @*/
  lua_cn_main_assert_a();
  /*@ assert (bw_compl_expr()); @*/
  lua_cn_main_assert_b();

  int x = 0;
  lua_cn_ghost_add((&x), sizeof(signed int), get_cn_stack_depth());

  int y = ~CN_LOAD(x);
  lua_cn_ghost_add((&y), sizeof(signed int), get_cn_stack_depth());

  /*@ assert(y == -1i32); @*/
  lua_cn_main_assert_c(y);

  lua_cn_ghost_remove((&x), sizeof(signed int));
  lua_cn_ghost_remove((&y), sizeof(signed int));

  lua_cn_frame_pop();

  lua_cn_unload_runtime();
  lua_deinit();

  return ret;
}

void lua_cn_main_assert_a() {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "a");

  if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling main.assert.a: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}

void lua_cn_main_assert_b() {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "b");

  if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling main.assert.b: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}

void lua_cn_main_assert_c(int y) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "c");

  lua_pushinteger(L, y);

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling main.assert.c: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}
