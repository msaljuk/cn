#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

typedef unsigned long long u64;
typedef unsigned int u32;

enum flags {
  flag_1 = 1,
  flag_4 = 4,
};

void foo(enum flags flag, u32 level) {
  lua_cn_ghost_add((&flag), sizeof(enum flags), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&level), sizeof(unsigned int), lua_cn_get_stack_depth());
  
  bool table = (1 == 1);
  lua_cn_ghost_add((&table), sizeof(_Bool), lua_cn_get_stack_depth());

  if (CN_LOAD(table) && (CN_LOAD(flag) & flag_1)) {
    lua_cn_ghost_remove((&table), sizeof(_Bool));
  }

  lua_cn_ghost_remove((&table), sizeof(_Bool));
  lua_cn_ghost_remove((&flag), sizeof(enum flags));
  lua_cn_ghost_remove((&level), sizeof(unsigned int));
}

int main(void)
/*@ trusted; @*/
{
  lua_init();
  lua_cn_load_runtime("./lua_output/enum_and_and/enum_and_and.lua");

  foo(flag_1, 1);

  lua_cn_unload_runtime();
  lua_deinit();
  
  return 0;
}

