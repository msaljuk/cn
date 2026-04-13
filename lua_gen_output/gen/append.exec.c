#include <lua_wrappers.h>
#include <cn-executable/utils.h>

#include <cn-executable/cerb_types.h>

/* ORIGINAL C STRUCTS AND UNIONS */

struct int_list {
  signed int head;
  struct int_list* tail;
};

struct int_list_pair {
  struct int_list* fst;
  struct int_list* snd;
};

enum CN_GHOST_ENUM {
  CLEARED,
  EMPTY
};
enum CN_GHOST_ENUM ghost_call_site;
/* HELPER FUNCTION DECLARATIONS */
static void lua_cn_IntList_append_push_frame(struct int_list*, struct int_list*);
static void lua_cn_IntList_append_precondition();
static void lua_cn_IntList_append_postcondition(struct int_list*);
static void lua_cn_split_push_frame(struct int_list*);
static void lua_cn_split_precondition();
static void lua_cn_split_postcondition(struct int_list_pair);
static void lua_cn_main_push_frame();
static void lua_cn_main_precondition();
static void lua_cn_main_postcondition(signed int);
static signed int lua_cn_push_int_list_pair_size();
static signed int lua_cn_push_int_list_size();
static void lua_cn_push_int_list_pair_offsets();
static void lua_cn_push_int_list_offsets();
static void lua_cn_push_int_list_pair(struct int_list_pair*);
static void lua_cn_push_int_list(struct int_list*);
static void lua_cn_push_runtime_metadata();
static signed int lua_cn_get_int_list_pair();
static signed int lua_cn_get_int_list();

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

/*@
datatype seq {
  Seq_Nil {},
  Seq_Cons {i32 head, datatype seq tail}
}

function [rec] (datatype seq) append(datatype seq xs, datatype seq ys) {
  match xs {
    Seq_Nil {} => {
      ys
    }
    Seq_Cons {head : h, tail : zs}  => {
      Seq_Cons {head: h, tail: append(zs, ys)}
    }
  }
}

predicate [rec] (datatype seq) IntList(pointer p) {
  if (is_null(p)) {
    return Seq_Nil{};
  } else {
    take H = RW<struct int_list>(p);
    take tl = IntList(H.tail);
    return (Seq_Cons { head: H.head, tail: tl });
  }
}
@*/

struct int_list* IntList_append(struct int_list* xs, struct int_list* ys)
/*@ requires take L1 = IntList(xs);
             take L2 = IntList(ys);
    ensures take L3 = IntList(return);
            L3 == append(L1, L2); @*/
{
  /* EXECUTABLE CN PRECONDITION */
  struct int_list* __cn_ret;
  lua_cn_IntList_append_push_frame(xs, ys);
  lua_cn_IntList_append_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&xs), sizeof(struct int_list*), lua_cn_get_stack_depth());
  lua_cn_ghost_add((&ys), sizeof(struct int_list*), lua_cn_get_stack_depth());
  
  if (CN_LOAD(xs) == 0) {
    
    { __cn_ret = CN_LOAD(ys); goto __cn_epilogue; }
  } else {
    
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

  lua_cn_IntList_append_postcondition(__cn_ret);

  lua_cn_frame_pop_function();

return __cn_ret;

}

/*@
function [rec] ({datatype seq fst, datatype seq snd}) split_cn(datatype seq xs)
{
  match xs {
    Seq_Nil {} => {
      {fst: Seq_Nil{}, snd: Seq_Nil{}}
    }
    Seq_Cons {head: h1, tail: Seq_Nil{}} => {
      {fst: Seq_Nil{}, snd: xs}
    }
    Seq_Cons {head: h1, tail: Seq_Cons {head : h2, tail : tl2 }} => {
      let P = split_cn(tl2);
      {fst: Seq_Cons { head: h1, tail: P.fst},
       snd: Seq_Cons { head: h2, tail: P.snd}}
    }
  }
}
@*/


struct int_list_pair;

// split [] = ([], [])
// split [x] = ([], [x])
// split (x :: y :: zs) = let (xs, ys) = split(zs) in
//                        (x :: xs, y :: ys)



struct int_list_pair split(struct int_list *xs)
/*@ requires take Xs = IntList(xs);
    ensures take Ys = IntList(return.fst);
            take Zs = IntList(return.snd); @*/
{
  /* EXECUTABLE CN PRECONDITION */
  struct int_list_pair __cn_ret;
  lua_cn_split_push_frame(xs);
  lua_cn_split_precondition();
  
	/* C OWNERSHIP */

  lua_cn_ghost_add((&xs), sizeof(struct int_list*), lua_cn_get_stack_depth());
  
  if (CN_LOAD(xs) == 0) {
    struct int_list_pair r = {.fst = 0, .snd = 0};
lua_cn_ghost_add((&r), sizeof(struct int_list_pair), lua_cn_get_stack_depth());

    { __cn_ret = CN_LOAD(r); 
lua_cn_ghost_remove((&r), sizeof(struct int_list_pair));
goto __cn_epilogue; }
  
lua_cn_ghost_remove((&r), sizeof(struct int_list_pair));
} else {
    if (CN_LOAD(CN_LOAD(xs)->tail) == 0) {
      struct int_list_pair r = {.fst = 0, .snd = CN_LOAD(xs)};
lua_cn_ghost_add((&r), sizeof(struct int_list_pair), lua_cn_get_stack_depth());

      { __cn_ret = CN_LOAD(r); 
lua_cn_ghost_remove((&r), sizeof(struct int_list_pair));
goto __cn_epilogue; }
    
lua_cn_ghost_remove((&r), sizeof(struct int_list_pair));
} else {
      struct int_list *cdr = CN_LOAD(CN_LOAD(xs)->tail);
lua_cn_ghost_add((&cdr), sizeof(struct int_list*), lua_cn_get_stack_depth());

      struct int_list_pair p = (
({
  ghost_call_site = EMPTY;
  0;
})
, split(CN_LOAD(CN_LOAD(CN_LOAD(xs)->tail)->tail)));
lua_cn_ghost_add((&p), sizeof(struct int_list_pair), lua_cn_get_stack_depth());

      CN_STORE(CN_LOAD(xs)->tail, CN_LOAD(p.fst));
      CN_STORE(CN_LOAD(cdr)->tail, CN_LOAD(p.snd));
      struct int_list_pair r = {.fst = CN_LOAD(xs), .snd = CN_LOAD(cdr)};
lua_cn_ghost_add((&r), sizeof(struct int_list_pair), lua_cn_get_stack_depth());

      { __cn_ret = CN_LOAD(r); 
lua_cn_ghost_remove((&cdr), sizeof(struct int_list*));


lua_cn_ghost_remove((&p), sizeof(struct int_list_pair));


lua_cn_ghost_remove((&r), sizeof(struct int_list_pair));
goto __cn_epilogue; }
    
lua_cn_ghost_remove((&cdr), sizeof(struct int_list*));


lua_cn_ghost_remove((&p), sizeof(struct int_list_pair));


lua_cn_ghost_remove((&r), sizeof(struct int_list_pair));
}
  }

/* EXECUTABLE CN POSTCONDITION */
__cn_epilogue:

  
	/* C OWNERSHIP */


  lua_cn_ghost_remove((&xs), sizeof(struct int_list*));

  lua_cn_split_postcondition(__cn_ret);

  lua_cn_frame_pop_function();

return __cn_ret;

}

int main(void)
/*@ trusted; @*/
{
  /* EXECUTABLE CN PRECONDITION */
  signed int __cn_ret = 0;
  lua_init();
  lua_cn_load_runtime("./lua_gen_output/gen/append.lua", 0, -1, -1, 0, 0);
  lua_cn_push_runtime_metadata();
  
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


/* HELPER FUNCTION DEFINITIONS */
static void lua_cn_IntList_append_push_frame(struct int_list* xs, struct int_list* ys)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "IntList_append");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(xs));
  lua_pushinteger(L, lua_convert_ptr_to_int(ys));
  lua_pcall(L, 2, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_IntList_append_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "IntList_append");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_IntList_append_postcondition(struct int_list* __cn_ret)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "IntList_append");
  lua_getfield(L, -1, "postcondition");
  lua_pushinteger(L, lua_convert_ptr_to_int(__cn_ret));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_split_push_frame(struct int_list* xs)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "split");
  lua_getfield(L, -1, "push_frame");
  lua_pushinteger(L, lua_convert_ptr_to_int(xs));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_split_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "split");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_split_postcondition(struct int_list_pair __cn_ret)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "split");
  lua_getfield(L, -1, "postcondition");
  lua_cn_push_int_list_pair((&__cn_ret));
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_main_push_frame()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "push_frame");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_main_precondition()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "precondition");
  lua_pcall(L, 0, 0, 0);
  lua_pop(L, 1);
}
static void lua_cn_main_postcondition(signed int __cn_ret)
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "main");
  lua_getfield(L, -1, "postcondition");
  lua_pushinteger(L, __cn_ret);
  lua_pcall(L, 1, 0, 0);
  lua_pop(L, 1);
}
static signed int lua_cn_push_int_list_pair_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct int_list_pair));
  lua_setfield(L, -2, "int_list_pair");
  lua_pop(L, 3);
  return 1;
}
static signed int lua_cn_push_int_list_size()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "sizeof");
  lua_pushinteger(L, sizeof(struct int_list));
  lua_setfield(L, -2, "int_list");
  lua_pop(L, 3);
  return 1;
}
static void lua_cn_push_int_list_pair_offsets()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "offsets");
  lua_newtable(L);
  lua_pushinteger(L, offsetof(struct int_list_pair, fst));
  lua_setfield(L, -2, "fst");
  lua_pushinteger(L, offsetof(struct int_list_pair, snd));
  lua_setfield(L, -2, "snd");
  lua_setfield(L, -2, "int_list_pair");
  lua_pop(L, 3);
}
static void lua_cn_push_int_list_offsets()
{
  struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "offsets");
  lua_newtable(L);
  lua_pushinteger(L, offsetof(struct int_list, head));
  lua_setfield(L, -2, "head");
  lua_pushinteger(L, offsetof(struct int_list, tail));
  lua_setfield(L, -2, "tail");
  lua_setfield(L, -2, "int_list");
  lua_pop(L, 3);
}
static void lua_cn_push_int_list_pair(struct int_list_pair* data)
{
  struct lua_State* L = lua_get_state();
  lua_newtable(L);
  lua_pushinteger(L, lua_convert_ptr_to_int(data->fst));
  lua_setfield(L, -2, "fst");
  lua_pushinteger(L, lua_convert_ptr_to_int(data->snd));
  lua_setfield(L, -2, "snd");
}
static void lua_cn_push_int_list(struct int_list* data)
{
  struct lua_State* L = lua_get_state();
  lua_newtable(L);
  lua_pushinteger(L, data->head);
  lua_setfield(L, -2, "head");
  lua_pushinteger(L, lua_convert_ptr_to_int(data->tail));
  lua_setfield(L, -2, "tail");
}
static void lua_cn_push_runtime_metadata()
{
  {
    lua_cn_register_c_func("get_int_list", lua_cn_get_int_list);
    lua_cn_register_c_func("get_int_list_pair", lua_cn_get_int_list_pair);
  }
  {
    lua_cn_push_int_list_size();
    lua_cn_push_int_list_pair_size();
  }
  {
    lua_cn_push_int_list_offsets();
    lua_cn_push_int_list_pair_offsets();
  }
}
static signed int lua_cn_get_int_list_pair()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct int_list_pair* data = (struct int_list_pair*) ptr;
  lua_cn_push_int_list_pair(data);
  return 1;
}
static signed int lua_cn_get_int_list()
{
  struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct int_list* data = (struct int_list*) ptr;
  lua_cn_push_int_list(data);
  return 1;
}

