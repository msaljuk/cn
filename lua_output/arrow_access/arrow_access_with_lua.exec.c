#include <lua_wrappers.h>
#include <cn-executable/utils.h>
#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct s {
  signed int x;
  signed int y;
};

static int lua_cn_read_s();

void lua_cn_arrow_access_1_assert_a(struct s* origin);
void lua_cn_arrow_access_1_assert_b(struct s* p);
void lua_cn_arrow_access_1_assert_c(struct s* q);
void lua_cn_arrow_access_1_assert_d(struct s* q);
void lua_cn_arrow_access_2_precondition(struct s* origin);
void lua_cn_arrow_access_2_postcondition();

void arrow_access_1()
{
  lua_cn_frame_push();
  
  struct s origin = { .x = 0, .y = 0 };

  lua_cn_ghost_add((&origin), sizeof(struct s), get_cn_stack_depth());

  lua_cn_arrow_access_1_assert_a(&origin);

  // -- member
  struct s *p = &origin;
  lua_cn_ghost_add((&p), sizeof(struct s*), get_cn_stack_depth());

  struct s *q = &origin;
  lua_cn_ghost_add((&q), sizeof(struct s*), get_cn_stack_depth());

  lua_cn_arrow_access_1_assert_b(p);
  // Arrow access  
  lua_cn_arrow_access_1_assert_c(q);
  
  // ... desugared as this
  CN_STORE((*CN_LOAD(p)).y, 7);

  lua_cn_arrow_access_1_assert_d(q);

  lua_cn_ghost_remove((&origin), sizeof(struct s));
  lua_cn_ghost_remove((&p), sizeof(struct s*));
  lua_cn_ghost_remove((&q), sizeof(struct s*));

  lua_cn_frame_pop();
}

void arrow_access_2 (struct s *origin)
/*@
requires
  take Or = RW<struct s>(origin);
  origin->y == 0i32;
ensures
  take Or_ = RW<struct s>(origin);
  origin->y == 7i32;
  (*origin).y == 7i32;
@*/
{
  lua_cn_frame_push();

  /* EXECUTABLE CN PRECONDITION */
  lua_cn_arrow_access_2_precondition(origin);
  
	/* C OWNERSHIP */
  c_add_to_ghost_state((&origin), sizeof(struct s*), get_cn_stack_depth());
  
  CN_STORE(CN_LOAD(origin)->y, 7);

	/* C OWNERSHIP */
  c_remove_from_ghost_state((&origin), sizeof(struct s*));

  /* EXECUTABLE CN POSTCONDITION */
  lua_cn_arrow_access_2_postcondition();

  lua_cn_frame_pop();
}

int main(void)
/*@ trusted; @*/
{
  lua_init();
  lua_cn_load_runtime("./lua_output/arrow_access/arrow_access.lua");
  lua_cn_register_c_func("read_s", lua_cn_read_s);
  
  arrow_access_1();

  struct s origin = {.x = 0, .y = 0};
  lua_cn_ghost_add((&origin), sizeof(struct s), lua_cn_get_stack_depth());
  arrow_access_2(&origin);
  lua_cn_ghost_remove((&origin), sizeof(struct s));

  lua_cn_unload_runtime();
  lua_deinit();

  return 0;
}

static int lua_cn_read_s() {
  lua_State* L = lua_get_state();

  int64_t ptr = luaL_checkinteger(L, 1);
  struct s *val = (struct s *)ptr;

  lua_pushinteger(L, lua_convert_ptr_to_int(&val->x));
  lua_pushinteger(L, sizeof(val->x));
  lua_pushinteger(L, lua_convert_ptr_to_int(&val->y));
  lua_pushinteger(L, sizeof(val->y));
  lua_pushinteger(L, sizeof(struct s));

  return 5;
}

void lua_cn_arrow_access_1_assert_a(struct s* origin) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "a");

  lua_pushinteger(L, lua_convert_ptr_to_int(origin));

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling arrow_access_1.assert.a: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 3);
}

void lua_cn_arrow_access_1_assert_b(struct s* p) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "b");

  lua_pushinteger(L, lua_convert_ptr_to_int(p));

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling arrow_access_1.assert.b: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 3);
}

void lua_cn_arrow_access_1_assert_c(struct s* q) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "c");

  lua_pushinteger(L, lua_convert_ptr_to_int(q));

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling arrow_access_1.assert.c: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 3);
}

void lua_cn_arrow_access_1_assert_d(struct s* q) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_1");
  lua_getfield(L, -1, "assert");
  lua_getfield(L, -1, "d");

  lua_pushinteger(L, lua_convert_ptr_to_int(q));

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling arrow_access_1.assert.d: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 3);
}

void lua_cn_arrow_access_2_precondition(struct s* origin) {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "precondition");

  lua_pushinteger(L, lua_convert_ptr_to_int(origin));

  if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling arrow_access_2.precondition: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}

void lua_cn_arrow_access_2_postcondition() {
  lua_State* L = lua_get_state();

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "arrow_access_2");
  lua_getfield(L, -1, "postcondition");

  if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
      fprintf(stderr, "Error calling CN.arrow_access_2.postcondition: %s\n", lua_tostring(L, -1));
      lua_pop(L, 1);
  }

  lua_pop(L, 2);
}

/**
 * QUESTIONS 
 * 
 * 1. What's up wiht the error messaging in the C instrumentation?
 * There's repeated error pushes of the same type in both arrow_access_1
 * and arrow_access_2
 */