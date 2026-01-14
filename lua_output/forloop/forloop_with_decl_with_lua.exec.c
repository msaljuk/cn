#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

void lua_cn_for_with_decl_loop_check_a(int* i, int* acc);

int for_with_decl()
{
  lua_cn_frame_push_function();

  signed int ret;
  
  int acc = 0;
  lua_cn_ghost_add((&acc), sizeof(signed int), lua_cn_get_stack_depth());

  // This is unideal. For now, our contract has been to push everything CN related
  // into Lua but keep the ownership state, error handling etc in C. Loops are
  // annoying in that they have a whole ownership structure that we have to allocate
  // but then we also use it for CN ownership checking. 
  // It's gross to retain the allocation part here and do everything else in Lua. Need to commit
  // one way or the other.
  cn_bump_frame_id loop_id;

  for (
    signed int i = (lua_cn_ghost_add((&i), sizeof(signed int), lua_cn_get_stack_depth()), 0);
    //@note from saljuk:
    // My understanding of the C instrumentation is that we were doing the loop checks here AND
    // then doing the loop condition. This mean that we'd unconditionally bump the frame for a new
    // iteration and then be off by 1 at the last check, requiring an extra free after the loop.
    // To me, rearranging things like this to ensure we only do the bump if we will actually
    // go inside the loop feels cleaner.
    (CN_LOAD(i) < 10) &&
    ({
      /*@ inv 0i32 <= i; i <= 10i32;
        acc <= 10i32; @*/
      loop_id = cn_bump_get_frame_id();
      lua_cn_for_with_decl_loop_check_a(&i, &acc);
      true;
    }); 
    CN_POSTFIX(i, ++))
  {
    CN_STORE(acc, CN_LOAD(i));
    lua_cn_frame_pop_loop();
    cn_bump_free_after(loop_id);
  }

  ret = CN_LOAD(acc);
  lua_cn_ghost_remove((&acc), sizeof(signed int));

  lua_cn_frame_pop_function();

  return ret;
}

int main(void)
/*@ trusted; @*/
{
  signed int ret = 0;

  lua_init();
  lua_cn_load_runtime("./lua_output/forloop/forloop_with_decl.lua");
  
  int r = for_with_decl();

  lua_cn_unload_runtime();
  lua_deinit();

  return ret;
}

void lua_cn_for_with_decl_loop_check_a(int* i, int* acc) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "for_with_decl");
  lua_getfield(L, -1, "loop_check");
  lua_getfield(L, -1, "a");

  lua_pushinteger(L, lua_convert_ptr_to_int(i));
  lua_pushinteger(L, lua_convert_ptr_to_int(acc));

  if (lua_pcall(L, 2, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling for_with_decl.loop_check.a: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}